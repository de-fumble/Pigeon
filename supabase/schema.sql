-- =============================================================================
-- Pigeon Arena — Supabase schema
-- =============================================================================
-- Prediction markets + social feed ("Arena") + NGN wallet.
--
-- Conventions
--   * Money is stored as BIGINT kobo (₦1 = 100 kobo). Never floats.
--   * One share pays out ₦100 (10,000 kobo) if its option wins, ₦0 otherwise.
--     Option prices are probabilities in [0, 1]; ₦ price per share = price * 100.
--   * Prices come from an LMSR automated market maker. The admin "Market Seed"
--     is the house subsidy: liquidity_b = seed / (₦100 * ln(#options)), which
--     caps the house's worst-case loss on a market at exactly the seed.
--   * Clients never write balances, trades, positions or ledger rows. All money
--     movement goes through the SECURITY DEFINER functions in section 9.
--   * Payment-provider work (virtual accounts, bank-name resolution, direct
--     debit mandates, payouts, webhooks) runs in Edge Functions with the
--     service_role key and calls the service-only RPCs below.
--
-- Run once (SQL editor or `supabase db push` as a migration). If the project
-- already has tables from an earlier setup (e.g. `profiles`), section 1b renames
-- them to legacy_<name> instead of failing, and section 18 creates profiles and
-- wallets for users who signed up before this schema existed. The script ends by
-- printing a report of everything it did.
-- After running, grant yourself admin:
--   insert into public.user_roles (user_id, role) values ('<your auth uid>', 'admin');
-- =============================================================================


-- -----------------------------------------------------------------------------
-- 1. Extensions & schemas
-- -----------------------------------------------------------------------------
create extension if not exists pg_trgm with schema extensions;

-- Internal helpers live in `private`, which PostgREST does not expose.
create schema if not exists private;
revoke all on schema private from public;
grant usage on schema private to anon, authenticated, service_role;
alter default privileges in schema private revoke execute on functions from public;


-- -----------------------------------------------------------------------------
-- 1b. Pre-flight: make room for this schema in a project that already has
--     objects from an earlier setup. Nothing is deleted:
--       * clashing tables/views are renamed to legacy_<name> (data kept);
--       * clashing enum types are dropped if unused, otherwise renamed;
--       * old triggers on auth.users that write to a renamed table are removed,
--         since they would break sign-up against the new tables.
--     Every action is recorded in the report printed at the end of the script.
-- -----------------------------------------------------------------------------
create temp table pigeon_install_report (
  step   serial,
  action text not null,
  detail text not null
);

do $$
declare
  v_relations text[] := array[
    'profiles', 'profile_private', 'user_roles', 'interests', 'user_interests',
    'categories', 'topics', 'teams', 'events', 'markets', 'market_outcomes',
    'market_links', 'market_price_history', 'topic_markets', 'shelves', 'shelf_items',
    'banners', 'platform_settings', 'wallets', 'banks', 'bank_accounts',
    'virtual_accounts', 'direct_debit_mandates', 'deposits', 'withdrawals', 'trades',
    'positions', 'wallet_transactions', 'posts', 'post_reactions', 'post_hides',
    'notifications', 'notification_preferences', 'push_tokens', 'recent_searches',
    'admin_audit_log', 'market_feed', 'my_positions', 'my_wallet', 'feed_posts'
  ];
  v_types text[] := array[
    'app_role', 'market_status', 'market_type', 'event_status', 'trade_side',
    'ledger_entry_type', 'deposit_method', 'payment_status', 'mandate_status',
    'notification_type', 'reaction_type', 'app_surface', 'shelf_layout', 'device_platform'
  ];
  v_renamed text[] := '{}';
  v_rel     record;
  v_dep     record;
  v_trg     record;
  v_pol     record;
  t         text;
begin
  if exists (
    select 1 from pg_proc p join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'private' and p.proname = 'wallet_apply'
  ) then
    raise exception 'The Pigeon schema is already installed in this database; nothing to do.';
  end if;

  foreach t in array v_relations loop
    select c.oid, c.relkind into v_rel
    from pg_class c
    where c.relnamespace = 'public'::regnamespace and c.relname = t;
    continue when not found;

    if to_regclass(format('public.%I', 'legacy_' || t)) is not null then
      raise exception 'Both public.% and public.legacy_% exist. Rename or drop one of them, then run this script again.', t, t;
    end if;

    -- Free the names of its indexes and owned sequences too (e.g. profiles_pkey).
    for v_dep in
      select ic.relname as name, 'index' as kind
      from pg_index i join pg_class ic on ic.oid = i.indexrelid
      where i.indrelid = v_rel.oid
      union all
      select sc.relname, 'sequence'
      from pg_depend d join pg_class sc on sc.oid = d.objid
      where d.refobjid = v_rel.oid and sc.relkind = 'S' and d.deptype in ('a', 'i')
    loop
      execute format('alter %s public.%I rename to %I', v_dep.kind, v_dep.name, left('legacy_' || v_dep.name, 63));
    end loop;

    execute format('alter %s public.%I rename to %I',
      case v_rel.relkind when 'v' then 'view' when 'm' then 'materialized view' else 'table' end,
      t, 'legacy_' || t);
    v_renamed := v_renamed || t;
    insert into pigeon_install_report (action, detail)
    values ('renamed', format('public.%s → public.legacy_%s (data kept; drop it once you no longer need it)', t, t));
  end loop;

  foreach t in array v_types loop
    continue when to_regtype(format('public.%I', t)) is null;
    begin
      execute format('drop type public.%I', t);
      insert into pigeon_install_report (action, detail)
      values ('dropped', format('unused type public.%s', t));
    exception when dependent_objects_still_exist then
      execute format('alter type public.%I rename to %I', t, 'legacy_' || t);
      insert into pigeon_install_report (action, detail)
      values ('renamed', format('type public.%s → public.legacy_%s', t, t));
    end;
  end loop;

  if cardinality(v_renamed) > 0 then
    for v_trg in
      select tg.tgname, p.oid as fn_oid, n.nspname as fn_schema, p.proname as fn_name,
             p.proowner, p.prosrc
      from pg_trigger tg
      join pg_proc p on p.oid = tg.tgfoid
      join pg_namespace n on n.oid = p.pronamespace
      where tg.tgrelid = 'auth.users'::regclass and not tg.tgisinternal
    loop
      continue when v_trg.prosrc !~* ('\m(' || array_to_string(v_renamed, '|') || ')\M');
      begin
        execute format('drop trigger %I on auth.users', v_trg.tgname);
        insert into pigeon_install_report (action, detail)
        values ('removed', format('trigger %s on auth.users (it wrote to the old tables); its function %I.%I() is left in place',
                                  v_trg.tgname, v_trg.fn_schema, v_trg.fn_name));
      exception when insufficient_privilege then
        -- Can't drop a trigger on auth.users here: switch its function off instead.
        if not pg_has_role(current_user, v_trg.proowner, 'member') then
          raise exception 'Trigger % on auth.users writes to the old tables and % cannot remove it. Delete it under Database → Triggers, then run this script again.',
            v_trg.tgname, current_user;
        end if;
        insert into pigeon_install_report (action, detail)
        values ('disabled', format(E'function %I.%I() (trigger %s on auth.users) now does nothing. Original definition:\n%s',
                                   v_trg.fn_schema, v_trg.fn_name, v_trg.tgname, pg_get_functiondef(v_trg.fn_oid)));
        execute format('create or replace function %I.%I() returns trigger language plpgsql as %L',
                       v_trg.fn_schema, v_trg.fn_name, 'begin return new; end;');
      end;
    end loop;
  end if;

  for v_pol in
    select policyname, cmd
    from pg_policies
    where schemaname = 'storage' and tablename = 'objects'
      and (coalesce(qual, '') || ' ' || coalesce(with_check, '')) ~ '''(avatars|media)'''
  loop
    insert into pigeon_install_report (action, detail)
    values ('review', format('existing storage policy "%s" (%s) also covers the avatars/media bucket and may allow more than this schema intends',
                             v_pol.policyname, v_pol.cmd));
  end loop;
end;
$$;


-- -----------------------------------------------------------------------------
-- 2. Enums
-- -----------------------------------------------------------------------------
create type public.app_role as enum ('admin', 'moderator');

-- Admin UI statuses: Active, Live, Paused, Inactive, Coming soon (+ Hide / Conclude).
-- "Hidden" is a separate flag (markets.is_hidden), not a status.
create type public.market_status as enum (
  'draft',        -- being built in the admin panel, invisible to users
  'coming_soon',  -- listed, options shown without prices, not tradable
  'active',       -- tradable
  'live',         -- tradable, underlying event in progress
  'paused',       -- listed, trading temporarily halted
  'inactive',     -- delisted, not tradable
  'closed',       -- trading ended, awaiting resolution
  'resolved',     -- winner chosen, inside the settlement window
  'settled',      -- payouts done
  'voided'        -- cancelled, stakes refunded
);

create type public.market_type as enum ('binary', 'multiple_choice');
create type public.event_status as enum ('scheduled', 'live', 'finished', 'postponed', 'cancelled');
create type public.trade_side as enum ('buy', 'sell');

create type public.ledger_entry_type as enum (
  'deposit', 'withdrawal', 'withdrawal_reversal',
  'trade_buy', 'trade_sell', 'trade_fee',
  'payout', 'refund', 'adjustment'
);

create type public.deposit_method as enum ('bank_transfer', 'direct_debit');
create type public.payment_status as enum ('pending', 'processing', 'successful', 'failed', 'reversed');
create type public.mandate_status as enum ('pending', 'active', 'cancelled', 'failed', 'expired');

create type public.notification_type as enum (
  'new_market', 'trade_buy', 'trade_sell',
  'market_won', 'market_lost', 'market_voided',
  'deposit_successful', 'deposit_failed',
  'withdrawal_initiated', 'withdrawal_successful', 'withdrawal_failed',
  'bank_account_linked', 'system'
);

-- Arena reactions (assets/icons/culturefeed): 👀 👌 🤡 💔 😊 🧢
create type public.reaction_type as enum ('eyes', 'ok_hand', 'clown', 'broken_heart', 'smile', 'cap');

create type public.app_surface as enum ('arena', 'markets', 'search');
create type public.shelf_layout as enum ('list', 'card', 'grid');
create type public.device_platform as enum ('ios', 'android', 'web');


-- -----------------------------------------------------------------------------
-- 3. Users, roles, onboarding
-- -----------------------------------------------------------------------------

-- Public profile. Readable by everyone (the Arena feed is visible signed-out).
create table public.profiles (
  id                    uuid primary key references auth.users (id) on delete cascade,
  username              text not null unique,
  bio                   text,
  avatar_url            text,
  avatar_color          text,
  is_official           boolean not null default false,  -- @PigeonUniverse, @Sports, @Politics …
  is_verified           boolean not null default false,
  posts_count           integer not null default 0,
  trades_count          integer not null default 0,      -- profile "ACTIVITY"
  trade_volume_kobo     bigint  not null default 0,      -- profile "VOLUME"
  last_seen_at          timestamptz,
  deletion_requested_at timestamptz,
  created_at            timestamptz not null default now(),  -- profile "Joined"
  updated_at            timestamptz not null default now(),
  constraint profiles_username_format check (username ~ '^[a-z0-9_.]{3,30}$'),
  constraint profiles_bio_length check (char_length(bio) <= 160),
  constraint profiles_avatar_color_hex check (avatar_color ~ '^#[0-9A-Fa-f]{6}$')
);
comment on table public.profiles is 'Public user profile; one row per auth.users row, created by trigger.';

-- PII, visible only to its owner. email/phone mirror auth.users.
create table public.profile_private (
  id         uuid primary key references public.profiles (id) on delete cascade,
  email      text,
  phone      text,
  dob        date,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
comment on table public.profile_private is 'Owner-only PII: contact details mirrored from auth.users and date of birth.';

create table public.user_roles (
  user_id    uuid not null references public.profiles (id) on delete cascade,
  role       public.app_role not null,
  granted_by uuid references public.profiles (id) on delete set null,
  created_at timestamptz not null default now(),
  primary key (user_id, role)
);

-- Sign-up "Pick what you're into" options.
create table public.interests (
  label      text primary key,
  emoji      text,
  sort_order integer not null default 0
);

-- Column is named `category` to match AuthService.saveInterests().
create table public.user_interests (
  user_id    uuid not null references public.profiles (id) on delete cascade,
  category   text not null references public.interests (label) on update cascade,
  created_at timestamptz not null default now(),
  primary key (user_id, category)
);


-- -----------------------------------------------------------------------------
-- 4. Taxonomy & curation (admin: Categories, Topics & Shelves, Banners)
-- -----------------------------------------------------------------------------

-- Two levels: top-level categories (Politics, Sports, …) and subcategories
-- (Sports → Football, Basketball, …).
create table public.categories (
  id         uuid primary key default gen_random_uuid(),
  parent_id  uuid references public.categories (id) on delete cascade,
  name       text not null,
  slug       text not null unique,
  emoji      text,
  icon_url   text,
  color      text,
  sort_order integer not null default 0,
  is_active  boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint categories_unique_name unique nulls not distinct (parent_id, name)
);

-- Topic chips inside a category tab (World Cup, Elections, AI, …).
create table public.topics (
  id          uuid primary key default gen_random_uuid(),
  category_id uuid references public.categories (id) on delete set null,
  name        text not null,
  slug        text not null unique,
  description text,
  emoji       text,
  image_url   text,
  sort_order  integer not null default 0,
  is_active   boolean not null default true,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

create table public.teams (
  id           uuid primary key default gen_random_uuid(),
  category_id  uuid references public.categories (id) on delete set null,
  name         text not null,
  short_name   text,              -- 'MAN', 'ARS'
  badge_url    text,
  color        text,
  external_ref text unique,       -- id in the sports-data provider
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now()
);

-- A real-world event several markets can hang off (a fixture, an election).
-- Live score fields are written by a sports-data Edge Function.
create table public.events (
  id           uuid primary key default gen_random_uuid(),
  category_id  uuid references public.categories (id) on delete set null,
  title        text not null,
  image_url    text,
  status       public.event_status not null default 'scheduled',
  starts_at    timestamptz,
  ends_at      timestamptz,
  home_team_id uuid references public.teams (id) on delete set null,
  away_team_id uuid references public.teams (id) on delete set null,
  home_score   smallint,
  away_score   smallint,
  live_period  text,              -- '1H', 'Q1'
  live_clock   text,              -- '5:17'
  external_ref text unique,
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now()
);


-- -----------------------------------------------------------------------------
-- 5. Markets
-- -----------------------------------------------------------------------------
create table public.markets (
  id                  uuid primary key default gen_random_uuid(),
  slug                text unique,
  title               text not null check (char_length(title) between 3 and 200),
  description         text,
  market_type         public.market_type not null default 'multiple_choice',
  status              public.market_status not null default 'draft',
  is_hidden           boolean not null default false,
  is_featured         boolean not null default false,
  category_id         uuid not null references public.categories (id),
  subcategory_id      uuid references public.categories (id),
  event_id            uuid references public.events (id) on delete set null,
  image_url           text,
  period              text,          -- sports: '1H', 'FT', …
  resolution_criteria text,          -- "Resolution" sheet
  settlement_terms    text,          -- "Settlement" sheet
  wager_terms         text,          -- "Wage terms" sheet
  opens_at            timestamptz,
  closes_at           timestamptz,
  seed_kobo           bigint not null default 0 check (seed_kobo >= 0),
  liquidity_b         numeric(30, 10),   -- LMSR b, fixed on first publish
  fee_bps             integer check (fee_bps between 0 and 10000),  -- overrides platform default
  volume_kobo         bigint  not null default 0,
  fees_collected_kobo bigint  not null default 0,
  buys_count          integer not null default 0,
  sells_count         integer not null default 0,
  traders_count       integer not null default 0,
  last_traded_at      timestamptz,
  resolved_outcome_id uuid,              -- FK added after market_outcomes
  resolution_notes    text,
  resolved_at         timestamptz,
  resolved_by         uuid references public.profiles (id) on delete set null,
  settled_at          timestamptz,
  voided_at           timestamptz,
  void_reason         text,
  created_by          uuid default auth.uid() references public.profiles (id) on delete set null,
  created_at          timestamptz not null default now(),
  updated_at          timestamptz not null default now(),
  search_vector       tsvector generated always as (
    to_tsvector('english'::regconfig, coalesce(title, '') || ' ' || coalesce(description, ''))
  ) stored,
  constraint markets_close_after_open check (closes_at is null or opens_at is null or closes_at > opens_at)
);

-- Options ("candidates"). shares_outstanding is the LMSR q vector.
create table public.market_outcomes (
  id                 uuid primary key default gen_random_uuid(),
  market_id          uuid not null references public.markets (id) on delete cascade,
  label              text not null,
  short_label        text,           -- 'BAT'
  image_url          text,
  emoji              text,
  color              text,
  sort_order         integer not null default 0,
  shares_outstanding numeric(30, 10) not null default 0 check (shares_outstanding >= 0),
  price              numeric(12, 10) check (price between 0 and 1),  -- null until published
  is_winner          boolean,
  created_at         timestamptz not null default now(),
  updated_at         timestamptz not null default now(),
  constraint market_outcomes_unique_label unique (market_id, label)
);

alter table public.markets
  add constraint markets_resolved_outcome_fk
  foreign key (resolved_outcome_id) references public.market_outcomes (id);

-- "Related News" → Link sources.
create table public.market_links (
  id          uuid primary key default gen_random_uuid(),
  market_id   uuid not null references public.markets (id) on delete cascade,
  url         text not null,
  title       text,
  source_name text,
  sort_order  integer not null default 0,
  created_at  timestamptz not null default now()
);

-- One row per option per trade; feeds the NOW / 1D chart.
create table public.market_price_history (
  id          bigint generated always as identity primary key,
  market_id   uuid not null references public.markets (id) on delete cascade,
  outcome_id  uuid not null references public.market_outcomes (id) on delete cascade,
  price       numeric(12, 10) not null,
  recorded_at timestamptz not null default now()
);

create table public.topic_markets (
  topic_id   uuid not null references public.topics (id) on delete cascade,
  market_id  uuid not null references public.markets (id) on delete cascade,
  sort_order integer not null default 0,
  primary key (topic_id, market_id)
);

-- Curated sections: "Nigerian Elections", "Fanbase — Gather Here", "Champions" …
create table public.shelves (
  id          uuid primary key default gen_random_uuid(),
  title       text not null,      -- admin-facing name
  heading     text not null,      -- user-facing heading
  surface     public.app_surface not null default 'arena',
  category_id uuid references public.categories (id) on delete cascade,  -- null = Home
  layout      public.shelf_layout not null default 'list',
  sort_order  integer not null default 0,
  is_active   boolean not null default true,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

-- A shelf item points at either a market or a topic ("Premier League" in Champions).
create table public.shelf_items (
  id         uuid primary key default gen_random_uuid(),
  shelf_id   uuid not null references public.shelves (id) on delete cascade,
  market_id  uuid references public.markets (id) on delete cascade,
  topic_id   uuid references public.topics (id) on delete cascade,
  sort_order integer not null default 0,
  created_at timestamptz not null default now(),
  constraint shelf_items_one_target check (num_nonnulls(market_id, topic_id) = 1)
);

create table public.banners (
  id         uuid primary key default gen_random_uuid(),
  surface    public.app_surface not null,   -- ARENA / MARKETS
  title      text,
  subtitle   text,
  image_url  text not null,
  market_id  uuid references public.markets (id) on delete cascade,
  link_url   text,
  sort_order integer not null default 0,
  is_active  boolean not null default true,
  starts_at  timestamptz,
  ends_at    timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);


-- -----------------------------------------------------------------------------
-- 6. Wallet, banking, payments
-- -----------------------------------------------------------------------------
create table public.platform_settings (
  id                  boolean primary key default true check (id),  -- singleton
  trade_fee_bps       integer  not null default 200 check (trade_fee_bps between 0 and 10000),
  withdrawal_fee_kobo bigint   not null default 2500 check (withdrawal_fee_kobo >= 0),
  min_trade_kobo      bigint   not null default 100 check (min_trade_kobo > 0),
  min_deposit_kobo    bigint   not null default 20000 check (min_deposit_kobo > 0),
  min_withdrawal_kobo bigint   not null default 20000 check (min_withdrawal_kobo > 0),
  min_age_years       integer  not null default 18,
  settlement_delay    interval not null default interval '10 minutes',
  -- What the user dashboard shows: 'stock' (built-in demo content) or 'live'
  -- (this database). Flipped from the Admin Panel via set_user_data_source().
  user_data_source    text     not null default 'stock' check (user_data_source in ('stock', 'live')),
  updated_at          timestamptz not null default now()
);

create table public.wallets (
  user_id      uuid primary key references public.profiles (id) on delete restrict,
  balance_kobo bigint not null default 0 check (balance_kobo >= 0),
  currency     char(3) not null default 'NGN',
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now()
);

create table public.banks (
  id         smallint generated always as identity primary key,
  name       text not null unique,
  code       text unique,          -- NIP/CBN code; fill from your payment provider's bank list
  logo_url   text,
  is_popular boolean not null default false,
  is_active  boolean not null default true,
  sort_order integer not null default 0
);

-- Inserted by an Edge Function after resolving the account name with the provider.
create table public.bank_accounts (
  id                      uuid primary key default gen_random_uuid(),
  user_id                 uuid not null references public.profiles (id) on delete restrict,
  bank_id                 smallint not null references public.banks (id),
  account_number          text not null check (account_number ~ '^[0-9]{10}$'),  -- NUBAN
  account_name            text not null,
  is_verified             boolean not null default false,
  verified_at             timestamptz,
  provider_recipient_code text,
  created_at              timestamptz not null default now(),  -- "Added" date
  updated_at              timestamptz not null default now(),
  deleted_at              timestamptz
);

-- Dedicated account number for "Bank Transfer" funding.
create table public.virtual_accounts (
  id                 uuid primary key default gen_random_uuid(),
  user_id            uuid not null references public.profiles (id) on delete restrict,
  bank_name          text not null,
  account_number     text not null unique,
  account_name       text not null,
  provider           text not null,
  provider_reference text,
  is_active          boolean not null default true,
  created_at         timestamptz not null default now(),
  updated_at         timestamptz not null default now()
);

create table public.direct_debit_mandates (
  id                 uuid primary key default gen_random_uuid(),
  user_id            uuid not null references public.profiles (id) on delete restrict,
  bank_account_id    uuid not null references public.bank_accounts (id) on delete restrict,
  provider           text not null,
  provider_reference text unique,
  status             public.mandate_status not null default 'pending',  -- "Approving activity"
  approved_at        timestamptz,
  cancelled_at       timestamptz,
  created_at         timestamptz not null default now(),
  updated_at         timestamptz not null default now()
);

create table public.deposits (
  id                 uuid primary key default gen_random_uuid(),
  user_id            uuid not null references public.profiles (id) on delete restrict,
  method             public.deposit_method not null,
  status             public.payment_status not null default 'pending',
  amount_kobo        bigint not null check (amount_kobo > 0),
  fee_kobo           bigint not null default 0 check (fee_kobo >= 0),
  mandate_id         uuid references public.direct_debit_mandates (id) on delete restrict,
  virtual_account_id uuid references public.virtual_accounts (id) on delete restrict,
  provider           text,
  provider_reference text unique,
  failure_reason     text,
  metadata           jsonb not null default '{}'::jsonb,
  completed_at       timestamptz,
  created_at         timestamptz not null default now(),
  updated_at         timestamptz not null default now(),
  constraint deposits_fee_lt_amount check (fee_kobo < amount_kobo),
  constraint deposits_source check (
    (method = 'direct_debit'  and mandate_id is not null) or
    (method = 'bank_transfer' and virtual_account_id is not null)
  )
);

create table public.withdrawals (
  id                 uuid primary key default gen_random_uuid(),
  user_id            uuid not null references public.profiles (id) on delete restrict,
  bank_account_id    uuid not null references public.bank_accounts (id) on delete restrict,
  status             public.payment_status not null default 'pending',
  amount_kobo        bigint not null check (amount_kobo > 0),
  fee_kobo           bigint not null default 0 check (fee_kobo >= 0),
  net_amount_kobo    bigint generated always as (amount_kobo - fee_kobo) stored,
  provider           text,
  provider_reference text unique,
  failure_reason     text,
  processed_at       timestamptz,
  created_at         timestamptz not null default now(),
  updated_at         timestamptz not null default now(),
  constraint withdrawals_fee_lt_amount check (fee_kobo < amount_kobo)
);


-- -----------------------------------------------------------------------------
-- 7. Trading
-- -----------------------------------------------------------------------------

-- Append-only.
create table public.trades (
  id             uuid primary key default gen_random_uuid(),
  user_id        uuid not null references public.profiles (id) on delete restrict,
  market_id      uuid not null references public.markets (id) on delete restrict,
  outcome_id     uuid not null references public.market_outcomes (id) on delete restrict,
  side           public.trade_side not null,
  shares         numeric(30, 10) not null check (shares > 0),
  amount_kobo    bigint not null check (amount_kobo >= 0),  -- buy: stake; sell: gross proceeds
  fee_kobo       bigint not null default 0 check (fee_kobo >= 0),
  net_kobo       bigint not null,                           -- buy: debited; sell: credited
  avg_price_kobo numeric(20, 4) not null,
  price_before   numeric(12, 10) not null,
  price_after    numeric(12, 10) not null,
  created_at     timestamptz not null default now()
);

create table public.positions (
  user_id           uuid not null references public.profiles (id) on delete restrict,
  outcome_id        uuid not null references public.market_outcomes (id) on delete restrict,
  market_id         uuid not null references public.markets (id) on delete restrict,
  shares            numeric(30, 10) not null default 0 check (shares >= 0),
  cost_basis_kobo   bigint not null default 0 check (cost_basis_kobo >= 0),  -- excl. fees
  fees_paid_kobo    bigint not null default 0,
  realized_pnl_kobo bigint not null default 0,
  payout_kobo       bigint,
  settled_at        timestamptz,
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now(),
  primary key (user_id, outcome_id)
);

-- Append-only ledger; wallets.balance_kobo always equals the latest balance_after_kobo.
create table public.wallet_transactions (
  id                 bigint generated always as identity primary key,
  user_id            uuid not null references public.wallets (user_id) on delete restrict,
  type               public.ledger_entry_type not null,
  amount_kobo        bigint not null check (amount_kobo <> 0),   -- signed
  balance_after_kobo bigint not null check (balance_after_kobo >= 0),
  trade_id           uuid references public.trades (id) on delete restrict,
  market_id          uuid references public.markets (id) on delete restrict,
  deposit_id         uuid references public.deposits (id) on delete restrict,
  withdrawal_id      uuid references public.withdrawals (id) on delete restrict,
  description        text,
  created_at         timestamptz not null default now()
);


-- -----------------------------------------------------------------------------
-- 8. Social (Arena), notifications, search
-- -----------------------------------------------------------------------------

-- Posts and replies (parent_id). market_id = embedded market / market discussion.
create table public.posts (
  id              uuid primary key default gen_random_uuid(),
  author_id       uuid not null references public.profiles (id) on delete cascade,
  body            text not null check (char_length(btrim(body)) between 1 and 2000),
  parent_id       uuid references public.posts (id) on delete cascade,
  quoted_post_id  uuid references public.posts (id) on delete set null,
  market_id       uuid references public.markets (id) on delete set null,
  category_id     uuid references public.categories (id) on delete set null,
  reply_count     integer not null default 0,
  reaction_count  integer not null default 0,
  reaction_counts jsonb   not null default '{}'::jsonb,  -- {"eyes": 54, "ok_hand": 93}
  is_hidden       boolean not null default false,       -- moderation
  deleted_at      timestamptz,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now()
);

create table public.post_reactions (
  post_id    uuid not null references public.posts (id) on delete cascade,
  user_id    uuid not null references public.profiles (id) on delete cascade,
  reaction   public.reaction_type not null,
  created_at timestamptz not null default now(),
  primary key (post_id, user_id, reaction)
);

-- "Hide post" — hides it from this user's feed only.
create table public.post_hides (
  user_id    uuid not null references public.profiles (id) on delete cascade,
  post_id    uuid not null references public.posts (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (user_id, post_id)
);

create table public.notifications (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null references public.profiles (id) on delete cascade,
  type       public.notification_type not null,
  title      text not null,
  body       text,
  market_id  uuid references public.markets (id) on delete set null,
  trade_id   uuid references public.trades (id) on delete set null,
  data       jsonb not null default '{}'::jsonb,
  read_at    timestamptz,
  created_at timestamptz not null default now()
);

-- Delivery channels (Settings → Notifications). In-app notifications are always stored.
create table public.notification_preferences (
  user_id       uuid primary key references public.profiles (id) on delete cascade,
  push_enabled  boolean not null default true,
  sms_enabled   boolean not null default true,
  email_enabled boolean not null default true,
  updated_at    timestamptz not null default now()
);

create table public.push_tokens (
  id           uuid primary key default gen_random_uuid(),
  user_id      uuid not null references public.profiles (id) on delete cascade,
  token        text not null unique,
  platform     public.device_platform not null,
  created_at   timestamptz not null default now(),
  last_seen_at timestamptz not null default now()
);

create table public.recent_searches (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null references public.profiles (id) on delete cascade,
  query      text not null check (char_length(query) between 1 and 200),
  created_at timestamptz not null default now(),
  constraint recent_searches_unique unique (user_id, query)
);

create table public.admin_audit_log (
  id          bigint generated always as identity primary key,
  actor_id    uuid references public.profiles (id) on delete set null,
  action      text not null,
  entity_type text not null,
  entity_id   uuid,
  details     jsonb not null default '{}'::jsonb,
  created_at  timestamptz not null default now()
);


-- -----------------------------------------------------------------------------
-- 9a. Indexes
-- -----------------------------------------------------------------------------
-- pg_trgm lives in `extensions` on current projects but in `public` on some older ones.
do $$
declare
  v_schema text := (
    select n.nspname from pg_extension e join pg_namespace n on n.oid = e.extnamespace
    where e.extname = 'pg_trgm'
  );
begin
  execute format('create index profiles_username_trgm_idx on public.profiles using gin (username %I.gin_trgm_ops)', v_schema);
  execute format('create index markets_title_trgm_idx on public.markets using gin (title %I.gin_trgm_ops)', v_schema);
end;
$$;

create index profiles_created_at_idx on public.profiles (created_at);

create index categories_parent_idx on public.categories (parent_id, sort_order);
create index topics_category_idx on public.topics (category_id, sort_order);
create index teams_category_idx on public.teams (category_id);
create index events_category_starts_idx on public.events (category_id, starts_at);
create index events_home_team_idx on public.events (home_team_id);
create index events_away_team_idx on public.events (away_team_id);

create index markets_category_status_idx on public.markets (category_id, status) where not is_hidden;
create index markets_subcategory_idx on public.markets (subcategory_id);
create index markets_event_idx on public.markets (event_id);
create index markets_status_idx on public.markets (status);
create index markets_volume_idx on public.markets (volume_kobo desc) where not is_hidden;
create index markets_search_idx on public.markets using gin (search_vector);
create index markets_resolved_outcome_idx on public.markets (resolved_outcome_id);
create index markets_created_by_idx on public.markets (created_by);
create index markets_resolved_by_idx on public.markets (resolved_by);

create index market_links_market_idx on public.market_links (market_id);
create index market_price_history_outcome_idx on public.market_price_history (outcome_id, recorded_at desc);
create index market_price_history_market_idx on public.market_price_history (market_id, recorded_at desc);
create index topic_markets_market_idx on public.topic_markets (market_id);
create index shelves_surface_idx on public.shelves (surface, category_id, sort_order);
create index shelf_items_shelf_idx on public.shelf_items (shelf_id, sort_order);
create index shelf_items_market_idx on public.shelf_items (market_id);
create index shelf_items_topic_idx on public.shelf_items (topic_id);
create index banners_surface_idx on public.banners (surface, sort_order) where is_active;
create index banners_market_idx on public.banners (market_id);

create unique index bank_accounts_active_unique on public.bank_accounts (user_id, bank_id, account_number) where deleted_at is null;
create index bank_accounts_bank_idx on public.bank_accounts (bank_id);
create unique index virtual_accounts_one_active_per_user on public.virtual_accounts (user_id) where is_active;
create index direct_debit_mandates_user_idx on public.direct_debit_mandates (user_id);
create index direct_debit_mandates_bank_account_idx on public.direct_debit_mandates (bank_account_id);
create index deposits_user_idx on public.deposits (user_id, created_at desc);
create index deposits_mandate_idx on public.deposits (mandate_id);
create index deposits_virtual_account_idx on public.deposits (virtual_account_id);
create index withdrawals_user_idx on public.withdrawals (user_id, created_at desc);
create index withdrawals_bank_account_idx on public.withdrawals (bank_account_id);
create index withdrawals_open_idx on public.withdrawals (created_at) where status in ('pending', 'processing');

create index trades_user_idx on public.trades (user_id, created_at desc);
create index trades_market_idx on public.trades (market_id, created_at desc);
create index trades_outcome_idx on public.trades (outcome_id);
create index positions_market_idx on public.positions (market_id);
create index positions_outcome_idx on public.positions (outcome_id);
create index wallet_transactions_user_idx on public.wallet_transactions (user_id, created_at desc);
create index wallet_transactions_trade_idx on public.wallet_transactions (trade_id);
create index wallet_transactions_market_idx on public.wallet_transactions (market_id);
create index wallet_transactions_deposit_idx on public.wallet_transactions (deposit_id);
create index wallet_transactions_withdrawal_idx on public.wallet_transactions (withdrawal_id);

create index posts_feed_idx on public.posts (created_at desc) where deleted_at is null and parent_id is null;
create index posts_author_idx on public.posts (author_id, created_at desc);
create index posts_parent_idx on public.posts (parent_id, created_at);
create index posts_market_idx on public.posts (market_id, created_at desc);
create index posts_category_idx on public.posts (category_id, created_at desc);
create index posts_quoted_idx on public.posts (quoted_post_id);
create index post_reactions_user_idx on public.post_reactions (user_id);
create index post_hides_post_idx on public.post_hides (post_id);

create index notifications_user_idx on public.notifications (user_id, created_at desc);
create index notifications_unread_idx on public.notifications (user_id) where read_at is null;
create index notifications_market_idx on public.notifications (market_id);
create index notifications_trade_idx on public.notifications (trade_id);
create index push_tokens_user_idx on public.push_tokens (user_id);
create index recent_searches_user_idx on public.recent_searches (user_id, created_at desc);
create index user_roles_granted_by_idx on public.user_roles (granted_by);
create index user_interests_category_idx on public.user_interests (category);
create index admin_audit_log_entity_idx on public.admin_audit_log (entity_type, entity_id);
create index admin_audit_log_actor_idx on public.admin_audit_log (actor_id);


-- -----------------------------------------------------------------------------
-- 9b. Internal helpers (private schema)
-- -----------------------------------------------------------------------------

create or replace function private.is_admin()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.user_roles
    where user_id = (select auth.uid()) and role = 'admin'
  );
$$;

-- Admin user, service_role key (Edge Functions), or a direct DB session (SQL editor, pg_cron).
create or replace function private.is_admin_or_service()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select private.is_admin()
      or coalesce(nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'role', '') = 'service_role'
      or session_user <> 'authenticator';
$$;

-- True when the current statement is NOT running as an API end user.
-- SECURITY DEFINER functions run as their owner, so their writes count as trusted;
-- direct PostgREST writes run as anon/authenticated and get their protected columns reset.
create or replace function private.is_trusted_context()
returns boolean
language sql
stable
set search_path = ''
as $$
  select current_user not in ('anon', 'authenticated');
$$;

create or replace function private.set_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

create or replace function private.forbid_change()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  raise exception '% is append-only', tg_table_name;
end;
$$;

create or replace function private.format_naira(p_kobo bigint)
returns text
language sql
stable
set search_path = ''
as $$
  select '₦' || case
    when p_kobo % 100 = 0 then to_char(p_kobo / 100, 'FM999,999,999,999,990')
    else to_char(p_kobo / 100.0, 'FM999,999,999,999,990.00')
  end;
$$;

create or replace function private.notify(
  p_user_id   uuid,
  p_type      public.notification_type,
  p_title     text,
  p_body      text default null,
  p_market_id uuid default null,
  p_trade_id  uuid default null,
  p_data      jsonb default '{}'::jsonb
)
returns void
language sql
security definer
set search_path = ''
as $$
  insert into public.notifications (user_id, type, title, body, market_id, trade_id, data)
  values (p_user_id, p_type, p_title, p_body, p_market_id, p_trade_id, coalesce(p_data, '{}'::jsonb));
$$;

-- The only code path that changes a wallet balance. Locks the wallet row and
-- writes the matching ledger entry. Returns the new balance.
create or replace function private.wallet_apply(
  p_user_id       uuid,
  p_amount_kobo   bigint,
  p_type          public.ledger_entry_type,
  p_trade_id      uuid default null,
  p_market_id     uuid default null,
  p_deposit_id    uuid default null,
  p_withdrawal_id uuid default null,
  p_description   text default null
)
returns bigint
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_balance bigint;
begin
  select balance_kobo into v_balance
  from public.wallets
  where user_id = p_user_id
  for update;

  if not found then
    raise exception 'Wallet not found';
  end if;

  if p_amount_kobo = 0 then
    return v_balance;
  end if;

  if v_balance + p_amount_kobo < 0 then
    raise exception 'Insufficient balance. Fund wallet to continue activity.';
  end if;

  v_balance := v_balance + p_amount_kobo;

  update public.wallets
     set balance_kobo = v_balance, updated_at = now()
   where user_id = p_user_id;

  insert into public.wallet_transactions
    (user_id, type, amount_kobo, balance_after_kobo, trade_id, market_id, deposit_id, withdrawal_id, description)
  values
    (p_user_id, p_type, p_amount_kobo, v_balance, p_trade_id, p_market_id, p_deposit_id, p_withdrawal_id, p_description);

  return v_balance;
end;
$$;

create or replace function private.assert_can_trade(p_user_id uuid)
returns void
language plpgsql
stable
set search_path = ''
as $$
declare
  v_dob      date;
  v_deleting timestamptz;
  v_min_age  integer;
begin
  select pp.dob, p.deletion_requested_at
    into v_dob, v_deleting
  from public.profiles p
  join public.profile_private pp on pp.id = p.id
  where p.id = p_user_id;

  if v_deleting is not null then
    raise exception 'This account is scheduled for deletion';
  end if;

  select min_age_years into v_min_age from public.platform_settings;

  if v_dob is null then
    raise exception 'Add your date of birth before trading';
  end if;
  if v_dob > (current_date - make_interval(years => v_min_age))::date then
    raise exception 'You must be at least % years old to trade', v_min_age;
  end if;
end;
$$;

create or replace function private.assert_market_tradable(p_market public.markets)
returns void
language plpgsql
stable
set search_path = ''
as $$
begin
  if p_market.status not in ('active', 'live') then
    raise exception 'This market is not open for trading (status: %)', p_market.status;
  end if;
  if p_market.closes_at is not null and p_market.closes_at <= now() then
    raise exception 'This market has closed';
  end if;
  if p_market.liquidity_b is null then
    raise exception 'This market has not been published';
  end if;
end;
$$;

-- LMSR state for a market, options in display order.
create or replace function private.market_state(p_market_id uuid, out ids uuid[], out q numeric[])
language sql
stable
set search_path = ''
as $$
  select array_agg(o.id order by o.sort_order, o.id),
         array_agg(o.shares_outstanding order by o.sort_order, o.id)
  from public.market_outcomes o
  where o.market_id = p_market_id;
$$;

-- LMSR math. Cost C(q) = b·ln Σ exp(q_j / b), in share units (1 unit = ₦100).
-- All functions subtract max(q)/b before exponentiating to stay numerically stable.
create or replace function private.lmsr_prices(p_q numeric[], p_b numeric)
returns numeric[]
language plpgsql
immutable
set search_path = ''
as $$
declare
  v_m   numeric := (select max(x) from unnest(p_q) as x) / p_b;
  v_s   numeric := 0;
  v_out numeric[] := '{}';
  i     integer;
begin
  for i in 1 .. array_length(p_q, 1) loop
    v_s := v_s + exp(p_q[i] / p_b - v_m);
  end loop;
  for i in 1 .. array_length(p_q, 1) loop
    v_out := v_out || round(exp(p_q[i] / p_b - v_m) / v_s, 10);
  end loop;
  return v_out;
end;
$$;

-- Shares of option i that `p_cost` units buys: solves C(q + Δ·e_i) − C(q) = cost.
create or replace function private.lmsr_shares_for_cost(p_q numeric[], p_b numeric, p_i integer, p_cost numeric)
returns numeric
language plpgsql
immutable
set search_path = ''
as $$
declare
  v_m  numeric := (select max(x) from unnest(p_q) as x) / p_b;
  v_s  numeric := 0;
  v_ei numeric;
  i    integer;
begin
  for i in 1 .. array_length(p_q, 1) loop
    v_s := v_s + exp(p_q[i] / p_b - v_m);
  end loop;
  v_ei := exp(p_q[p_i] / p_b - v_m);
  return p_b * (v_m + ln(v_s * exp(p_cost / p_b) - v_s + v_ei)) - p_q[p_i];
end;
$$;

-- Units received for selling `p_shares` of option i: C(q) − C(q − Δ·e_i).
create or replace function private.lmsr_proceeds_for_shares(p_q numeric[], p_b numeric, p_i integer, p_shares numeric)
returns numeric
language plpgsql
immutable
set search_path = ''
as $$
declare
  v_m  numeric := (select max(x) from unnest(p_q) as x) / p_b;
  v_s  numeric := 0;
  v_ei numeric;
  i    integer;
begin
  for i in 1 .. array_length(p_q, 1) loop
    v_s := v_s + exp(p_q[i] / p_b - v_m);
  end loop;
  v_ei := exp(p_q[p_i] / p_b - v_m);
  return p_b * (ln(v_s) - ln(v_s - v_ei + exp((p_q[p_i] - p_shares) / p_b - v_m)));
end;
$$;

-- Called from the markets trigger when a market is first published.
create or replace function private.init_market_prices(p_market_id uuid, p_outcome_count integer)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if not private.is_admin_or_service() then
    raise exception 'Admins only' using errcode = '42501';
  end if;
  update public.market_outcomes
     set price = round(1.0 / p_outcome_count, 10)
   where market_id = p_market_id;
end;
$$;


-- -----------------------------------------------------------------------------
-- 9c. Triggers
-- -----------------------------------------------------------------------------

-- New auth user → profile, private profile, wallet, notification prefs.
-- Username comes from signUp(data: {'username': …}); a taken or invalid username
-- aborts the sign-up ("Database error saving new user").
create or replace function private.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_username text := lower(btrim(coalesce(new.raw_user_meta_data ->> 'username', '')));
begin
  if v_username = '' then
    v_username := 'user_' || substr(replace(new.id::text, '-', ''), 1, 10);
  end if;

  insert into public.profiles (id, username) values (new.id, v_username);
  insert into public.profile_private (id, email, phone) values (new.id, new.email, new.phone);
  insert into public.wallets (user_id) values (new.id);
  insert into public.notification_preferences (user_id) values (new.id);
  return new;
end;
$$;

create trigger pigeon_on_auth_user_created
  after insert on auth.users
  for each row execute function private.handle_new_user();

create or replace function private.handle_user_contact_change()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  update public.profile_private
     set email = new.email, phone = new.phone
   where id = new.id;
  return new;
end;
$$;

create trigger pigeon_on_auth_user_contact_changed
  after update of email, phone on auth.users
  for each row
  when (old.email is distinct from new.email or old.phone is distinct from new.phone)
  execute function private.handle_user_contact_change();

create or replace function private.profiles_before_update()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if private.is_trusted_context() then
    return new;
  end if;
  new.id                    := old.id;
  new.posts_count           := old.posts_count;
  new.trades_count          := old.trades_count;
  new.trade_volume_kobo     := old.trade_volume_kobo;
  new.deletion_requested_at := old.deletion_requested_at;
  new.created_at            := old.created_at;
  if not private.is_admin() then
    new.is_official := old.is_official;
    new.is_verified := old.is_verified;
  end if;
  return new;
end;
$$;

create trigger profiles_before_update
  before update on public.profiles
  for each row execute function private.profiles_before_update();

-- Contact details mirror auth.users; DOB is write-once and must meet the minimum age.
create or replace function private.profile_private_before_write()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  v_min_age integer;
begin
  if not private.is_trusted_context() then
    if tg_op = 'UPDATE' then
      new.email := old.email;
      new.phone := old.phone;
      if old.dob is not null then
        new.dob := old.dob;
      end if;
    else
      new.email := null;
      new.phone := null;
    end if;
  end if;

  if new.dob is not null then
    select min_age_years into v_min_age from public.platform_settings;
    if new.dob > (current_date - make_interval(years => v_min_age))::date then
      raise exception 'You must be at least % years old to use Pigeon', v_min_age;
    end if;
  end if;
  return new;
end;
$$;

create trigger profile_private_before_write
  before insert or update on public.profile_private
  for each row execute function private.profile_private_before_write();

-- Keeps trading state out of reach of direct API writes, validates the
-- category pair, and fixes the LMSR liquidity parameter on first publish.
create or replace function private.markets_before_write()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  v_outcomes integer;
begin
  if new.subcategory_id is not null and not exists (
    select 1 from public.categories c
    where c.id = new.subcategory_id and c.parent_id = new.category_id
  ) then
    raise exception 'Subcategory does not belong to the selected category';
  end if;

  if not private.is_trusted_context() then
    if tg_op = 'INSERT' then
      if new.status in ('resolved', 'settled', 'voided') then
        raise exception 'New markets cannot start as %', new.status;
      end if;
      new.liquidity_b         := null;
      new.volume_kobo         := 0;
      new.fees_collected_kobo := 0;
      new.buys_count          := 0;
      new.sells_count         := 0;
      new.traders_count       := 0;
      new.last_traded_at      := null;
      new.resolved_outcome_id := null;
      new.resolved_at         := null;
      new.resolved_by         := null;
      new.settled_at          := null;
      new.voided_at           := null;
      new.void_reason         := null;
      new.created_by          := auth.uid();
    else
      if new.status is distinct from old.status
         and (new.status in ('resolved', 'settled', 'voided') or old.status in ('resolved', 'settled', 'voided')) then
        raise exception 'Use resolve_market / settle_market / void_market to change status from % to %', old.status, new.status;
      end if;
      if old.liquidity_b is not null and new.seed_kobo <> old.seed_kobo then
        raise exception 'Market seed cannot change after publishing';
      end if;
      new.liquidity_b         := old.liquidity_b;
      new.volume_kobo         := old.volume_kobo;
      new.fees_collected_kobo := old.fees_collected_kobo;
      new.buys_count          := old.buys_count;
      new.sells_count         := old.sells_count;
      new.traders_count       := old.traders_count;
      new.last_traded_at      := old.last_traded_at;
      new.resolved_outcome_id := old.resolved_outcome_id;
      new.resolved_at         := old.resolved_at;
      new.resolved_by         := old.resolved_by;
      new.settled_at          := old.settled_at;
      new.voided_at           := old.voided_at;
      new.void_reason         := old.void_reason;
      new.created_by          := old.created_by;
      new.created_at          := old.created_at;
    end if;
  end if;

  -- Publishing: requires a seed and options; prices start uniform (₦25 each for 4 options).
  if new.status in ('active', 'live') and new.liquidity_b is null then
    if new.seed_kobo <= 0 then
      raise exception 'Set a market seed before publishing';
    end if;
    select count(*) into v_outcomes from public.market_outcomes where market_id = new.id;
    if v_outcomes < 2 then
      raise exception 'A market needs at least 2 options before publishing';
    end if;
    if new.market_type = 'binary' and v_outcomes <> 2 then
      raise exception 'Binary markets must have exactly 2 options';
    end if;
    new.liquidity_b := new.seed_kobo / (10000.0 * ln(v_outcomes));
    new.opens_at    := coalesce(new.opens_at, now());
    perform private.init_market_prices(new.id, v_outcomes);
  end if;

  return new;
end;
$$;

create trigger markets_before_write
  before insert or update on public.markets
  for each row execute function private.markets_before_write();

-- Options are frozen once the market is published (adding one would reprice everything).
create or replace function private.market_outcomes_before_write()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  v_published boolean;
begin
  if private.is_trusted_context() then
    return coalesce(new, old);
  end if;

  select m.liquidity_b is not null into v_published
  from public.markets m
  where m.id = coalesce(new.market_id, old.market_id);

  if tg_op = 'DELETE' then
    if v_published then
      raise exception 'Options cannot be removed after a market is published';
    end if;
    return old;
  end if;

  if tg_op = 'INSERT' then
    if v_published then
      raise exception 'Options cannot be added after a market is published';
    end if;
    new.shares_outstanding := 0;
    new.price              := null;
    new.is_winner          := null;
    return new;
  end if;

  new.market_id          := old.market_id;
  new.shares_outstanding := old.shares_outstanding;
  new.price              := old.price;
  new.is_winner          := old.is_winner;
  return new;
end;
$$;

create trigger market_outcomes_before_write
  before insert or update or delete on public.market_outcomes
  for each row execute function private.market_outcomes_before_write();

create or replace function private.posts_before_write()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if private.is_trusted_context() then
    return new;
  end if;

  if tg_op = 'INSERT' then
    new.reply_count     := 0;
    new.reaction_count  := 0;
    new.reaction_counts := '{}'::jsonb;
    new.deleted_at      := null;
    if not private.is_admin() then
      new.is_hidden := false;
    end if;
    return new;
  end if;

  new.author_id       := old.author_id;
  new.parent_id       := old.parent_id;
  new.quoted_post_id  := old.quoted_post_id;
  new.market_id       := old.market_id;
  new.category_id     := old.category_id;
  new.reply_count     := old.reply_count;
  new.reaction_count  := old.reaction_count;
  new.reaction_counts := old.reaction_counts;
  new.created_at      := old.created_at;
  if old.deleted_at is not null then
    new.deleted_at := old.deleted_at;
  end if;
  if not private.is_admin() then
    new.is_hidden := old.is_hidden;
  end if;
  return new;
end;
$$;

create trigger posts_before_write
  before insert or update on public.posts
  for each row execute function private.posts_before_write();

create or replace function private.posts_after_write()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if tg_op = 'INSERT' then
    update public.profiles set posts_count = posts_count + 1 where id = new.author_id;
    if new.parent_id is not null then
      update public.posts set reply_count = reply_count + 1 where id = new.parent_id;
    end if;
  elsif old.deleted_at is null and new.deleted_at is not null then
    update public.profiles set posts_count = greatest(posts_count - 1, 0) where id = new.author_id;
    if new.parent_id is not null then
      update public.posts set reply_count = greatest(reply_count - 1, 0) where id = new.parent_id;
    end if;
  end if;
  return null;
end;
$$;

create trigger posts_after_write
  after insert or update of deleted_at on public.posts
  for each row execute function private.posts_after_write();

create or replace function private.post_reactions_after_write()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_key text;
begin
  if tg_op = 'INSERT' then
    v_key := new.reaction::text;
    update public.posts
       set reaction_count  = reaction_count + 1,
           reaction_counts = jsonb_set(reaction_counts, array[v_key],
                               to_jsonb(coalesce((reaction_counts ->> v_key)::integer, 0) + 1))
     where id = new.post_id;
  else
    v_key := old.reaction::text;
    update public.posts
       set reaction_count  = greatest(reaction_count - 1, 0),
           reaction_counts = jsonb_set(reaction_counts, array[v_key],
                               to_jsonb(greatest(coalesce((reaction_counts ->> v_key)::integer, 0) - 1, 0)))
     where id = old.post_id;
  end if;
  return null;
end;
$$;

create trigger post_reactions_after_write
  after insert or delete on public.post_reactions
  for each row execute function private.post_reactions_after_write();

create trigger trades_append_only
  before update or delete on public.trades
  for each row execute function private.forbid_change();

create trigger wallet_transactions_append_only
  before update or delete on public.wallet_transactions
  for each row execute function private.forbid_change();

create trigger admin_audit_log_append_only
  before update or delete on public.admin_audit_log
  for each row execute function private.forbid_change();

do $$
declare
  t text;
begin
  foreach t in array array[
    'profiles', 'profile_private', 'categories', 'topics', 'teams', 'events',
    'markets', 'market_outcomes', 'shelves', 'banners', 'platform_settings',
    'wallets', 'bank_accounts', 'virtual_accounts', 'direct_debit_mandates',
    'deposits', 'withdrawals', 'positions', 'posts', 'notification_preferences'
  ] loop
    execute format(
      'create trigger set_updated_at before update on public.%I
         for each row execute function private.set_updated_at()', t);
  end loop;
end;
$$;


-- -----------------------------------------------------------------------------
-- 10. API functions (RPC)
-- -----------------------------------------------------------------------------

-- ---- Auth helpers -----------------------------------------------------------

-- Username → email for "log in with username". Callable signed-out.
-- Note: this reveals the email behind any username. To avoid that, move
-- username login into an Edge Function that signs in server-side.
create or replace function public.get_email_for_username(p_username text)
returns text
language sql
stable
security definer
set search_path = ''
as $$
  select pp.email
  from public.profiles p
  join public.profile_private pp on pp.id = p.id
  where p.username = lower(btrim(p_username))
    and p.deletion_requested_at is null;
$$;

create or replace function public.touch_last_seen()
returns void
language sql
security definer
set search_path = ''
as $$
  update public.profiles set last_seen_at = now() where id = (select auth.uid());
$$;

-- Accounts with financial history are anonymised by a back-office job rather
-- than hard-deleted (financial FKs are RESTRICT).
create or replace function public.request_account_deletion()
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user uuid := auth.uid();
begin
  if v_user is null then
    raise exception 'Not authenticated' using errcode = '28000';
  end if;
  if exists (select 1 from public.wallets where user_id = v_user and balance_kobo > 0) then
    raise exception 'Withdraw your balance before deleting your account';
  end if;
  if exists (select 1 from public.positions where user_id = v_user and shares > 0 and settled_at is null) then
    raise exception 'You still have open positions';
  end if;
  update public.profiles set deletion_requested_at = now() where id = v_user;
end;
$$;

-- ---- Trading ----------------------------------------------------------------

create or replace function public.quote_buy(p_outcome_id uuid, p_amount_kobo bigint)
returns table (
  shares               numeric,
  avg_price_kobo       numeric,
  fee_kobo             bigint,
  total_kobo           bigint,
  payout_if_right_kobo bigint,
  price_before         numeric,
  price_after          numeric
)
language plpgsql
stable
security definer
set search_path = ''
as $$
#variable_conflict use_column
declare
  v_market   public.markets;
  v_settings public.platform_settings;
  v_ids      uuid[];
  v_q        numeric[];
  v_idx      integer;
  v_shares   numeric;
  v_fee      bigint;
  v_before   numeric[];
  v_after    numeric[];
begin
  select m.* into v_market
  from public.markets m
  join public.market_outcomes o on o.market_id = m.id
  where o.id = p_outcome_id;
  if not found then
    raise exception 'Option not found';
  end if;
  perform private.assert_market_tradable(v_market);
  if p_amount_kobo is null or p_amount_kobo <= 0 then
    raise exception 'Enter an amount';
  end if;

  select * into v_settings from public.platform_settings;
  select s.ids, s.q into v_ids, v_q from private.market_state(v_market.id) as s;
  v_idx    := array_position(v_ids, p_outcome_id);
  v_before := private.lmsr_prices(v_q, v_market.liquidity_b);
  v_shares := trunc(private.lmsr_shares_for_cost(v_q, v_market.liquidity_b, v_idx, p_amount_kobo / 10000.0), 6);
  v_fee    := ceil(p_amount_kobo * coalesce(v_market.fee_bps, v_settings.trade_fee_bps) / 10000.0)::bigint;
  v_q[v_idx] := v_q[v_idx] + v_shares;
  v_after  := private.lmsr_prices(v_q, v_market.liquidity_b);

  return query select
    v_shares,
    case when v_shares > 0 then round(p_amount_kobo / v_shares, 4) end,
    v_fee,
    p_amount_kobo + v_fee,
    floor(v_shares * 10000)::bigint,
    v_before[v_idx],
    v_after[v_idx];
end;
$$;

create or replace function public.quote_sell(p_outcome_id uuid, p_shares numeric)
returns table (
  proceeds_kobo  bigint,
  fee_kobo       bigint,
  net_kobo       bigint,
  avg_price_kobo numeric,
  price_before   numeric,
  price_after    numeric
)
language plpgsql
stable
security definer
set search_path = ''
as $$
#variable_conflict use_column
declare
  v_market   public.markets;
  v_settings public.platform_settings;
  v_ids      uuid[];
  v_q        numeric[];
  v_idx      integer;
  v_proceeds bigint;
  v_fee      bigint;
  v_before   numeric[];
  v_after    numeric[];
begin
  select m.* into v_market
  from public.markets m
  join public.market_outcomes o on o.market_id = m.id
  where o.id = p_outcome_id;
  if not found then
    raise exception 'Option not found';
  end if;
  perform private.assert_market_tradable(v_market);

  select * into v_settings from public.platform_settings;
  select s.ids, s.q into v_ids, v_q from private.market_state(v_market.id) as s;
  v_idx := array_position(v_ids, p_outcome_id);
  if p_shares is null or p_shares <= 0 or p_shares > v_q[v_idx] then
    raise exception 'Invalid number of shares';
  end if;

  v_before   := private.lmsr_prices(v_q, v_market.liquidity_b);
  v_proceeds := floor(private.lmsr_proceeds_for_shares(v_q, v_market.liquidity_b, v_idx, p_shares) * 10000)::bigint;
  v_fee      := ceil(v_proceeds * coalesce(v_market.fee_bps, v_settings.trade_fee_bps) / 10000.0)::bigint;
  v_q[v_idx] := v_q[v_idx] - p_shares;
  v_after    := private.lmsr_prices(v_q, v_market.liquidity_b);

  return query select
    v_proceeds,
    v_fee,
    v_proceeds - v_fee,
    round(v_proceeds / p_shares, 4),
    v_before[v_idx],
    v_after[v_idx];
end;
$$;

-- Buy ₦amount of an option. Fee is charged on top ("Total you'll pay").
-- p_min_shares guards against the price moving between quote and submit.
create or replace function public.buy_shares(
  p_outcome_id  uuid,
  p_amount_kobo bigint,
  p_min_shares  numeric default 0
)
returns public.trades
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user        uuid := auth.uid();
  v_settings    public.platform_settings;
  v_market      public.markets;
  v_ids         uuid[];
  v_q           numeric[];
  v_idx         integer;
  v_before      numeric[];
  v_after       numeric[];
  v_shares      numeric;
  v_fee         bigint;
  v_first_trade boolean;
  v_label       text;
  v_trade       public.trades;
begin
  if v_user is null then
    raise exception 'Not authenticated' using errcode = '28000';
  end if;
  perform private.assert_can_trade(v_user);

  select * into v_settings from public.platform_settings;
  if p_amount_kobo is null or p_amount_kobo < v_settings.min_trade_kobo then
    raise exception 'Minimum trade is %', private.format_naira(v_settings.min_trade_kobo);
  end if;

  -- Trades on one market are serialised so the LMSR state stays consistent.
  select m.* into v_market
  from public.markets m
  join public.market_outcomes o on o.market_id = m.id
  where o.id = p_outcome_id
  for update of m;
  if not found then
    raise exception 'Option not found';
  end if;
  perform private.assert_market_tradable(v_market);

  select s.ids, s.q into v_ids, v_q from private.market_state(v_market.id) as s;
  v_idx    := array_position(v_ids, p_outcome_id);
  v_before := private.lmsr_prices(v_q, v_market.liquidity_b);
  v_shares := trunc(private.lmsr_shares_for_cost(v_q, v_market.liquidity_b, v_idx, p_amount_kobo / 10000.0), 6);
  if v_shares <= 0 then
    raise exception 'Amount too small';
  end if;
  if v_shares < coalesce(p_min_shares, 0) then
    raise exception 'Price moved: you would get % shares (minimum %). Review and try again.', v_shares, p_min_shares;
  end if;
  v_fee := ceil(p_amount_kobo * coalesce(v_market.fee_bps, v_settings.trade_fee_bps) / 10000.0)::bigint;

  v_q[v_idx] := v_q[v_idx] + v_shares;
  v_after    := private.lmsr_prices(v_q, v_market.liquidity_b);

  update public.market_outcomes o
     set shares_outstanding = s.q, price = s.p
    from unnest(v_ids, v_q, v_after) as s(id, q, p)
   where o.id = s.id;

  v_first_trade := not exists (
    select 1 from public.trades t where t.user_id = v_user and t.market_id = v_market.id
  );

  insert into public.trades
    (user_id, market_id, outcome_id, side, shares, amount_kobo, fee_kobo, net_kobo,
     avg_price_kobo, price_before, price_after)
  values
    (v_user, v_market.id, p_outcome_id, 'buy', v_shares, p_amount_kobo, v_fee, p_amount_kobo + v_fee,
     round(p_amount_kobo / v_shares, 4), v_before[v_idx], v_after[v_idx])
  returning * into v_trade;

  perform private.wallet_apply(v_user, -p_amount_kobo, 'trade_buy', p_trade_id => v_trade.id, p_market_id => v_market.id);
  perform private.wallet_apply(v_user, -v_fee, 'trade_fee', p_trade_id => v_trade.id, p_market_id => v_market.id);

  insert into public.positions as p (user_id, outcome_id, market_id, shares, cost_basis_kobo, fees_paid_kobo)
  values (v_user, p_outcome_id, v_market.id, v_shares, p_amount_kobo, v_fee)
  on conflict (user_id, outcome_id) do update
     set shares          = p.shares + excluded.shares,
         cost_basis_kobo = p.cost_basis_kobo + excluded.cost_basis_kobo,
         fees_paid_kobo  = p.fees_paid_kobo + excluded.fees_paid_kobo;

  update public.markets
     set volume_kobo         = volume_kobo + p_amount_kobo,
         fees_collected_kobo = fees_collected_kobo + v_fee,
         buys_count          = buys_count + 1,
         traders_count       = traders_count + case when v_first_trade then 1 else 0 end,
         last_traded_at      = now()
   where id = v_market.id;

  update public.profiles
     set trades_count      = trades_count + 1,
         trade_volume_kobo = trade_volume_kobo + p_amount_kobo
   where id = v_user;

  insert into public.market_price_history (market_id, outcome_id, price)
  select v_market.id, s.id, s.p from unnest(v_ids, v_after) as s(id, p);

  select label into v_label from public.market_outcomes where id = p_outcome_id;
  perform private.notify(
    v_user, 'trade_buy',
    format('🔥 You bought %s %s', private.format_naira(p_amount_kobo), v_label),
    v_market.title, v_market.id, v_trade.id,
    jsonb_build_object('shares', v_shares, 'cost_kobo', p_amount_kobo + v_fee,
                       'payout_if_right_kobo', floor(v_shares * 10000)::bigint)
  );

  return v_trade;
end;
$$;

-- Sell shares back to the market maker. Fee is deducted from proceeds.
create or replace function public.sell_shares(
  p_outcome_id         uuid,
  p_shares             numeric,
  p_min_proceeds_kobo  bigint default 0
)
returns public.trades
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user         uuid := auth.uid();
  v_settings     public.platform_settings;
  v_market       public.markets;
  v_position     public.positions;
  v_ids          uuid[];
  v_q            numeric[];
  v_idx          integer;
  v_before       numeric[];
  v_after        numeric[];
  v_proceeds     bigint;
  v_fee          bigint;
  v_cost_removed bigint;
  v_label        text;
  v_trade        public.trades;
begin
  if v_user is null then
    raise exception 'Not authenticated' using errcode = '28000';
  end if;
  if p_shares is null or p_shares <= 0 then
    raise exception 'Enter a number of shares to sell';
  end if;

  select * into v_settings from public.platform_settings;

  select m.* into v_market
  from public.markets m
  join public.market_outcomes o on o.market_id = m.id
  where o.id = p_outcome_id
  for update of m;
  if not found then
    raise exception 'Option not found';
  end if;
  perform private.assert_market_tradable(v_market);

  select * into v_position
  from public.positions
  where user_id = v_user and outcome_id = p_outcome_id
  for update;
  if not found or v_position.shares < p_shares then
    raise exception 'You do not have enough shares to sell';
  end if;

  select s.ids, s.q into v_ids, v_q from private.market_state(v_market.id) as s;
  v_idx      := array_position(v_ids, p_outcome_id);
  v_before   := private.lmsr_prices(v_q, v_market.liquidity_b);
  v_proceeds := floor(private.lmsr_proceeds_for_shares(v_q, v_market.liquidity_b, v_idx, p_shares) * 10000)::bigint;
  v_fee      := ceil(v_proceeds * coalesce(v_market.fee_bps, v_settings.trade_fee_bps) / 10000.0)::bigint;
  if v_proceeds - v_fee <= 0 then
    raise exception 'Amount too small to sell';
  end if;
  if v_proceeds - v_fee < coalesce(p_min_proceeds_kobo, 0) then
    raise exception 'Price moved: you would receive % (minimum %). Review and try again.',
      private.format_naira(v_proceeds - v_fee), private.format_naira(p_min_proceeds_kobo);
  end if;

  v_q[v_idx] := v_q[v_idx] - p_shares;
  v_after    := private.lmsr_prices(v_q, v_market.liquidity_b);

  update public.market_outcomes o
     set shares_outstanding = s.q, price = s.p
    from unnest(v_ids, v_q, v_after) as s(id, q, p)
   where o.id = s.id;

  insert into public.trades
    (user_id, market_id, outcome_id, side, shares, amount_kobo, fee_kobo, net_kobo,
     avg_price_kobo, price_before, price_after)
  values
    (v_user, v_market.id, p_outcome_id, 'sell', p_shares, v_proceeds, v_fee, v_proceeds - v_fee,
     round(v_proceeds / p_shares, 4), v_before[v_idx], v_after[v_idx])
  returning * into v_trade;

  perform private.wallet_apply(v_user, v_proceeds, 'trade_sell', p_trade_id => v_trade.id, p_market_id => v_market.id);
  perform private.wallet_apply(v_user, -v_fee, 'trade_fee', p_trade_id => v_trade.id, p_market_id => v_market.id);

  v_cost_removed := case
    when p_shares = v_position.shares then v_position.cost_basis_kobo
    else round(v_position.cost_basis_kobo * p_shares / v_position.shares)::bigint
  end;

  update public.positions
     set shares            = shares - p_shares,
         cost_basis_kobo   = cost_basis_kobo - v_cost_removed,
         fees_paid_kobo    = fees_paid_kobo + v_fee,
         realized_pnl_kobo = realized_pnl_kobo + (v_proceeds - v_fee - v_cost_removed)
   where user_id = v_user and outcome_id = p_outcome_id;

  update public.markets
     set volume_kobo         = volume_kobo + v_proceeds,
         fees_collected_kobo = fees_collected_kobo + v_fee,
         sells_count         = sells_count + 1,
         last_traded_at      = now()
   where id = v_market.id;

  update public.profiles
     set trades_count      = trades_count + 1,
         trade_volume_kobo = trade_volume_kobo + v_proceeds
   where id = v_user;

  insert into public.market_price_history (market_id, outcome_id, price)
  select v_market.id, s.id, s.p from unnest(v_ids, v_after) as s(id, p);

  select label into v_label from public.market_outcomes where id = p_outcome_id;
  perform private.notify(
    v_user, 'trade_sell',
    format('💰 You sold %s %s', private.format_naira(v_proceeds), v_label),
    v_market.title, v_market.id, v_trade.id,
    jsonb_build_object('shares', p_shares, 'received_kobo', v_proceeds - v_fee)
  );

  return v_trade;
end;
$$;

-- ---- Resolution & settlement (admin) ----------------------------------------

-- Picks the winner and halts trading. Can be called again to correct the
-- winner until the market is settled.
create or replace function public.resolve_market(
  p_market_id          uuid,
  p_winning_outcome_id uuid,
  p_notes              text default null
)
returns public.markets
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_market public.markets;
begin
  if not private.is_admin_or_service() then
    raise exception 'Admins only' using errcode = '42501';
  end if;

  select * into v_market from public.markets where id = p_market_id for update;
  if not found then
    raise exception 'Market not found';
  end if;
  if v_market.status in ('draft', 'settled', 'voided') then
    raise exception 'A % market cannot be resolved', v_market.status;
  end if;
  if not exists (
    select 1 from public.market_outcomes where id = p_winning_outcome_id and market_id = p_market_id
  ) then
    raise exception 'Winning option does not belong to this market';
  end if;

  update public.market_outcomes
     set is_winner = (id = p_winning_outcome_id)
   where market_id = p_market_id;

  update public.markets
     set status              = 'resolved',
         resolved_outcome_id = p_winning_outcome_id,
         resolved_at         = now(),
         resolved_by         = auth.uid(),
         resolution_notes    = coalesce(p_notes, resolution_notes)
   where id = p_market_id
  returning * into v_market;

  insert into public.admin_audit_log (actor_id, action, entity_type, entity_id, details)
  values (auth.uid(), 'market.resolve', 'market', p_market_id,
          jsonb_build_object('winning_outcome_id', p_winning_outcome_id, 'notes', p_notes));

  return v_market;
end;
$$;

-- Pays ₦100 per winning share. Runs automatically after settlement_delay
-- (see settle_due_markets), or immediately with p_force.
create or replace function public.settle_market(p_market_id uuid, p_force boolean default false)
returns public.markets
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_market   public.markets;
  v_settings public.platform_settings;
  v_payout   bigint;
  r          record;
begin
  if not private.is_admin_or_service() then
    raise exception 'Admins only' using errcode = '42501';
  end if;

  select * into v_settings from public.platform_settings;
  select * into v_market from public.markets where id = p_market_id for update;
  if not found then
    raise exception 'Market not found';
  end if;
  if v_market.status <> 'resolved' then
    raise exception 'Only resolved markets can be settled (status: %)', v_market.status;
  end if;
  if not p_force and v_market.resolved_at + v_settings.settlement_delay > now() then
    raise exception 'Settlement window has not elapsed yet';
  end if;

  for r in
    select p.user_id, p.outcome_id, p.shares, p.cost_basis_kobo
    from public.positions p
    where p.market_id = p_market_id and p.settled_at is null
    order by p.user_id, p.outcome_id
    for update
  loop
    v_payout := case when r.outcome_id = v_market.resolved_outcome_id
                     then floor(r.shares * 10000)::bigint else 0 end;
    update public.positions
       set payout_kobo       = v_payout,
           realized_pnl_kobo = realized_pnl_kobo + v_payout - r.cost_basis_kobo,
           settled_at        = now()
     where user_id = r.user_id and outcome_id = r.outcome_id;
    if v_payout > 0 then
      perform private.wallet_apply(r.user_id, v_payout, 'payout', p_market_id => p_market_id);
    end if;
  end loop;

  for r in
    select p.user_id,
           sum(p.cost_basis_kobo + p.fees_paid_kobo)::bigint as cost,
           sum(p.payout_kobo)::bigint as won
    from public.positions p
    where p.market_id = p_market_id and p.shares > 0
    group by p.user_id
  loop
    if r.won > 0 then
      perform private.notify(r.user_id, 'market_won', '🎉 You won!', v_market.title, p_market_id, null,
        jsonb_build_object('cost_kobo', r.cost, 'won_kobo', r.won));
    else
      perform private.notify(r.user_id, 'market_lost', '💔 You lost', v_market.title, p_market_id, null,
        jsonb_build_object('cost_kobo', r.cost, 'won_kobo', 0));
    end if;
  end loop;

  update public.markets
     set status = 'settled', settled_at = now()
   where id = p_market_id
  returning * into v_market;

  insert into public.admin_audit_log (actor_id, action, entity_type, entity_id, details)
  values (auth.uid(), 'market.settle', 'market', p_market_id, jsonb_build_object('forced', p_force));

  return v_market;
end;
$$;

create or replace function public.settle_due_markets()
returns integer
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_id    uuid;
  v_count integer := 0;
begin
  for v_id in
    select m.id
    from public.markets m, public.platform_settings s
    where m.status = 'resolved' and m.resolved_at + s.settlement_delay <= now()
    order by m.resolved_at
  loop
    perform public.settle_market(v_id);
    v_count := v_count + 1;
  end loop;
  return v_count;
end;
$$;

-- Cancels a market and refunds each holder's remaining cost basis.
create or replace function public.void_market(p_market_id uuid, p_reason text)
returns public.markets
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_market public.markets;
  r        record;
begin
  if not private.is_admin_or_service() then
    raise exception 'Admins only' using errcode = '42501';
  end if;

  select * into v_market from public.markets where id = p_market_id for update;
  if not found then
    raise exception 'Market not found';
  end if;
  if v_market.status in ('settled', 'voided') then
    raise exception 'A % market cannot be voided', v_market.status;
  end if;

  for r in
    select p.user_id, sum(p.cost_basis_kobo)::bigint as refund
    from public.positions p
    where p.market_id = p_market_id and p.settled_at is null and p.shares > 0
    group by p.user_id
    order by p.user_id
  loop
    if r.refund > 0 then
      perform private.wallet_apply(r.user_id, r.refund, 'refund', p_market_id => p_market_id,
                                   p_description => p_reason);
    end if;
    perform private.notify(r.user_id, 'market_voided', 'Market cancelled', v_market.title, p_market_id, null,
      jsonb_build_object('refund_kobo', r.refund, 'reason', p_reason));
  end loop;

  update public.positions
     set payout_kobo = case when shares > 0 then cost_basis_kobo else 0 end,
         settled_at  = now()
   where market_id = p_market_id and settled_at is null;

  update public.markets
     set status = 'voided', voided_at = now(), void_reason = p_reason
   where id = p_market_id
  returning * into v_market;

  insert into public.admin_audit_log (actor_id, action, entity_type, entity_id, details)
  values (auth.uid(), 'market.void', 'market', p_market_id, jsonb_build_object('reason', p_reason));

  return v_market;
end;
$$;

-- ---- Wallet: user-initiated -------------------------------------------------

-- Debits the wallet immediately; an Edge Function (Database Webhook on insert)
-- sends the payout and then calls complete_withdrawal / fail_withdrawal.
create or replace function public.request_withdrawal(p_bank_account_id uuid, p_amount_kobo bigint)
returns public.withdrawals
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user       uuid := auth.uid();
  v_settings   public.platform_settings;
  v_bank       public.bank_accounts;
  v_withdrawal public.withdrawals;
begin
  if v_user is null then
    raise exception 'Not authenticated' using errcode = '28000';
  end if;

  select * into v_settings from public.platform_settings;
  if p_amount_kobo is null or p_amount_kobo < v_settings.min_withdrawal_kobo then
    raise exception 'You cannot withdraw less than %', private.format_naira(v_settings.min_withdrawal_kobo);
  end if;
  if p_amount_kobo <= v_settings.withdrawal_fee_kobo then
    raise exception 'Amount must be more than the % processing fee', private.format_naira(v_settings.withdrawal_fee_kobo);
  end if;

  select * into v_bank
  from public.bank_accounts
  where id = p_bank_account_id and user_id = v_user and deleted_at is null;
  if not found then
    raise exception 'Bank account not found';
  end if;
  if not v_bank.is_verified then
    raise exception 'This bank account has not been verified yet';
  end if;

  insert into public.withdrawals (user_id, bank_account_id, amount_kobo, fee_kobo)
  values (v_user, p_bank_account_id, p_amount_kobo, v_settings.withdrawal_fee_kobo)
  returning * into v_withdrawal;

  perform private.wallet_apply(v_user, -p_amount_kobo, 'withdrawal', p_withdrawal_id => v_withdrawal.id);

  perform private.notify(v_user, 'withdrawal_initiated', 'Withdrawal initiated',
    format('Your withdrawal of %s is on its way to your bank account.', private.format_naira(p_amount_kobo)),
    null, null, jsonb_build_object('withdrawal_id', v_withdrawal.id));

  return v_withdrawal;
end;
$$;

-- Creates a pending direct-debit deposit; an Edge Function charges the
-- mandate and calls confirm_deposit / fail_deposit from the provider webhook.
create or replace function public.create_direct_debit_deposit(p_mandate_id uuid, p_amount_kobo bigint)
returns public.deposits
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user     uuid := auth.uid();
  v_settings public.platform_settings;
  v_deposit  public.deposits;
begin
  if v_user is null then
    raise exception 'Not authenticated' using errcode = '28000';
  end if;

  select * into v_settings from public.platform_settings;
  if p_amount_kobo is null or p_amount_kobo < v_settings.min_deposit_kobo then
    raise exception 'You cannot fund wallet with less than %', private.format_naira(v_settings.min_deposit_kobo);
  end if;

  if not exists (
    select 1 from public.direct_debit_mandates
    where id = p_mandate_id and user_id = v_user and status = 'active'
  ) then
    raise exception 'Direct debit is not active for this bank account';
  end if;

  insert into public.deposits (user_id, method, amount_kobo, mandate_id)
  values (v_user, 'direct_debit', p_amount_kobo, p_mandate_id)
  returning * into v_deposit;

  return v_deposit;
end;
$$;

create or replace function public.remove_bank_account(p_bank_account_id uuid)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  update public.bank_accounts
     set deleted_at = now()
   where id = p_bank_account_id and user_id = auth.uid() and deleted_at is null;
  if not found then
    raise exception 'Bank account not found';
  end if;

  -- The provider-side mandate is cancelled by an Edge Function watching this table.
  update public.direct_debit_mandates
     set status = 'cancelled', cancelled_at = now()
   where bank_account_id = p_bank_account_id and status in ('pending', 'active');
end;
$$;

-- ---- Wallet: service-only (Edge Functions / webhooks) -----------------------

create or replace function public.confirm_deposit(
  p_deposit_id         uuid,
  p_provider_reference text default null,
  p_fee_kobo           bigint default null
)
returns public.deposits
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_deposit public.deposits;
begin
  select * into v_deposit from public.deposits where id = p_deposit_id for update;
  if not found then
    raise exception 'Deposit not found';
  end if;
  if v_deposit.status = 'successful' then
    return v_deposit;  -- idempotent for webhook retries
  end if;
  if v_deposit.status not in ('pending', 'processing') then
    raise exception 'Deposit is %', v_deposit.status;
  end if;

  update public.deposits
     set status             = 'successful',
         completed_at       = now(),
         provider_reference = coalesce(p_provider_reference, provider_reference),
         fee_kobo           = coalesce(p_fee_kobo, fee_kobo)
   where id = p_deposit_id
  returning * into v_deposit;

  perform private.wallet_apply(v_deposit.user_id, v_deposit.amount_kobo - v_deposit.fee_kobo, 'deposit',
                               p_deposit_id => v_deposit.id);

  perform private.notify(v_deposit.user_id, 'deposit_successful', 'Wallet funded',
    format('%s has been added to your wallet.', private.format_naira(v_deposit.amount_kobo - v_deposit.fee_kobo)),
    null, null, jsonb_build_object('deposit_id', v_deposit.id));

  return v_deposit;
end;
$$;

-- Bank transfer into a user's virtual account (provider webhook). Idempotent on reference.
create or replace function public.record_transfer_deposit(
  p_account_number     text,
  p_amount_kobo        bigint,
  p_provider_reference text,
  p_fee_kobo           bigint default 0,
  p_metadata           jsonb default '{}'::jsonb
)
returns public.deposits
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_account public.virtual_accounts;
  v_deposit public.deposits;
begin
  select * into v_deposit from public.deposits where provider_reference = p_provider_reference;
  if found then
    return v_deposit;
  end if;

  select * into v_account
  from public.virtual_accounts
  where account_number = p_account_number;
  if not found then
    raise exception 'Unknown virtual account %', p_account_number;
  end if;

  insert into public.deposits
    (user_id, method, amount_kobo, fee_kobo, virtual_account_id, provider, provider_reference, metadata)
  values
    (v_account.user_id, 'bank_transfer', p_amount_kobo, coalesce(p_fee_kobo, 0), v_account.id,
     v_account.provider, p_provider_reference, coalesce(p_metadata, '{}'::jsonb))
  on conflict (provider_reference) do nothing
  returning * into v_deposit;

  if v_deposit.id is null then
    select * into v_deposit from public.deposits where provider_reference = p_provider_reference;
    return v_deposit;
  end if;

  return public.confirm_deposit(v_deposit.id);
end;
$$;

create or replace function public.fail_deposit(p_deposit_id uuid, p_reason text)
returns public.deposits
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_deposit public.deposits;
begin
  update public.deposits
     set status = 'failed', failure_reason = p_reason, completed_at = now()
   where id = p_deposit_id and status in ('pending', 'processing')
  returning * into v_deposit;

  if not found then
    select * into v_deposit from public.deposits where id = p_deposit_id;
    return v_deposit;
  end if;

  perform private.notify(v_deposit.user_id, 'deposit_failed', 'Request failed', 'Unable to fund wallet.',
    null, null, jsonb_build_object('deposit_id', v_deposit.id, 'reason', p_reason));
  return v_deposit;
end;
$$;

create or replace function public.complete_withdrawal(p_withdrawal_id uuid, p_provider_reference text default null)
returns public.withdrawals
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_withdrawal public.withdrawals;
begin
  select * into v_withdrawal from public.withdrawals where id = p_withdrawal_id for update;
  if not found then
    raise exception 'Withdrawal not found';
  end if;
  if v_withdrawal.status = 'successful' then
    return v_withdrawal;
  end if;
  if v_withdrawal.status not in ('pending', 'processing') then
    raise exception 'Withdrawal is %', v_withdrawal.status;
  end if;

  update public.withdrawals
     set status             = 'successful',
         processed_at       = now(),
         provider_reference = coalesce(p_provider_reference, provider_reference)
   where id = p_withdrawal_id
  returning * into v_withdrawal;

  perform private.notify(v_withdrawal.user_id, 'withdrawal_successful', 'Withdrawal complete',
    format('%s has been sent to your bank account.', private.format_naira(v_withdrawal.net_amount_kobo)),
    null, null, jsonb_build_object('withdrawal_id', v_withdrawal.id));
  return v_withdrawal;
end;
$$;

-- Refunds the full amount (including fee). Also handles a bank reversal after success.
create or replace function public.fail_withdrawal(p_withdrawal_id uuid, p_reason text)
returns public.withdrawals
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_withdrawal public.withdrawals;
begin
  select * into v_withdrawal from public.withdrawals where id = p_withdrawal_id for update;
  if not found then
    raise exception 'Withdrawal not found';
  end if;
  if v_withdrawal.status in ('failed', 'reversed') then
    return v_withdrawal;
  end if;

  update public.withdrawals
     set status         = case when status = 'successful' then 'reversed'::public.payment_status
                               else 'failed'::public.payment_status end,
         failure_reason = p_reason,
         processed_at   = now()
   where id = p_withdrawal_id
  returning * into v_withdrawal;

  perform private.wallet_apply(v_withdrawal.user_id, v_withdrawal.amount_kobo, 'withdrawal_reversal',
                               p_withdrawal_id => v_withdrawal.id, p_description => p_reason);

  perform private.notify(v_withdrawal.user_id, 'withdrawal_failed', 'Withdrawal failed',
    format('%s has been returned to your wallet.', private.format_naira(v_withdrawal.amount_kobo)),
    null, null, jsonb_build_object('withdrawal_id', v_withdrawal.id, 'reason', p_reason));
  return v_withdrawal;
end;
$$;

-- ---- Notifications ----------------------------------------------------------

-- Marks the given notifications (or all, when p_ids is null) as read.
create or replace function public.mark_notifications_read(p_ids uuid[] default null)
returns integer
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_count integer;
begin
  update public.notifications
     set read_at = now()
   where user_id = (select auth.uid())
     and read_at is null
     and (p_ids is null or id = any (p_ids));
  get diagnostics v_count = row_count;
  return v_count;
end;
$$;

-- ---- Discovery --------------------------------------------------------------

-- Search bar: "Markets, Users, Topics, Events and More".
create or replace function public.search(p_query text, p_limit integer default 20)
returns table (kind text, id uuid, title text, subtitle text, image_url text)
language sql
stable
set search_path = ''
as $$
  with q as (
    select websearch_to_tsquery('english', btrim(p_query)) as ts,
           '%' || replace(replace(replace(btrim(p_query), '\', '\\'), '%', '\%'), '_', '\_') || '%' as pattern,
           least(greatest(coalesce(p_limit, 20), 1), 50) as lim
    where char_length(btrim(coalesce(p_query, ''))) > 0
  )
  (select 'market'::text, m.id, m.title, c.name, m.image_url
     from public.markets m
     join public.categories c on c.id = m.category_id, q
    where not m.is_hidden and m.status <> 'draft'
      and (m.search_vector @@ q.ts or m.title ilike q.pattern)
    order by ts_rank(m.search_vector, q.ts) desc, m.volume_kobo desc
    limit (select lim from q))
  union all
  (select 'user'::text, p.id, p.username, p.bio, p.avatar_url
     from public.profiles p, q
    where p.username ilike q.pattern and p.deletion_requested_at is null
    order by p.is_official desc, p.trade_volume_kobo desc
    limit (select lim from q))
  union all
  (select 'topic'::text, t.id, t.name, t.description, t.image_url
     from public.topics t, q
    where t.is_active and t.name ilike q.pattern
    order by t.sort_order
    limit (select lim from q))
  union all
  (select 'event'::text, e.id, e.title, null::text, e.image_url
     from public.events e, q
    where e.title ilike q.pattern
    order by e.starts_at desc nulls last
    limit (select lim from q));
$$;

-- "Trending": markets by recent traded volume. Returns aggregates only.
create or replace function public.trending_markets(
  p_category_id uuid default null,
  p_hours       integer default 24,
  p_limit       integer default 20
)
returns table (market_id uuid, volume_kobo bigint, trades_count bigint)
language sql
stable
security definer
set search_path = ''
as $$
  select t.market_id, sum(t.amount_kobo)::bigint, count(*)
  from public.trades t
  join public.markets m on m.id = t.market_id
  where t.created_at > now() - make_interval(hours => coalesce(p_hours, 24))
    and not m.is_hidden
    and m.status in ('active', 'live')
    and (p_category_id is null or m.category_id = p_category_id)
  group by t.market_id
  order by 2 desc
  limit least(greatest(coalesce(p_limit, 20), 1), 100);
$$;

-- ---- Admin dashboards -------------------------------------------------------

create or replace function public.admin_overview()
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_today timestamptz := date_trunc('day', now() at time zone 'Africa/Lagos') at time zone 'Africa/Lagos';
begin
  if not private.is_admin_or_service() then
    raise exception 'Admins only' using errcode = '42501';
  end if;

  return jsonb_build_object(
    'total_users',       (select count(*) from public.profiles),
    'joined_today',      (select count(*) from public.profiles where created_at >= v_today),
    'active_users_7d',   (select count(*) from public.profiles where last_seen_at > now() - interval '7 days'),
    'total_markets',     (select count(*) from public.markets where status <> 'draft'),
    'markets_by_status', (select coalesce(jsonb_object_agg(status, n), '{}'::jsonb)
                            from (select status, count(*) as n from public.markets group by status) s),
    'wager_volume_kobo', (select coalesce(sum(volume_kobo), 0) from public.markets),
    'fees_kobo',         (select coalesce(sum(fees_collected_kobo), 0) from public.markets),
    'top_markets',       (select coalesce(jsonb_agg(x), '[]'::jsonb) from (
                            select id, title, status, volume_kobo, traders_count
                            from public.markets
                            where status <> 'draft'
                            order by volume_kobo desc
                            limit 5) x)
  );
end;
$$;

-- User growth chart. p_days = 7 (7D), 30 (1M) or null (All). Days are in Lagos time.
create or replace function public.admin_user_growth(p_days integer default null)
returns table (day date, new_users bigint, total_users bigint)
language plpgsql
stable
security definer
set search_path = ''
as $$
#variable_conflict use_column
declare
  v_today date := (now() at time zone 'Africa/Lagos')::date;
begin
  if not private.is_admin_or_service() then
    raise exception 'Admins only' using errcode = '42501';
  end if;

  return query
  with daily as (
    select (p.created_at at time zone 'Africa/Lagos')::date as d, count(*) as n
    from public.profiles p
    group by 1
  ),
  span as (
    select generate_series(
             coalesce(v_today - (p_days - 1), (select min(d) from daily), v_today),
             v_today,
             interval '1 day')::date as d
  )
  select s.d,
         coalesce(daily.n, 0)::bigint,
         (select coalesce(sum(n), 0) from daily where daily.d <= s.d)::bigint
  from span s
  left join daily on daily.d = s.d
  order by s.d;
end;
$$;


-- Admin Panel "User data" switch. An RPC rather than a plain UPDATE so every
-- flip lands in the audit log.
create or replace function public.set_user_data_source(p_source text)
returns text
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_old text;
begin
  if not private.is_admin_or_service() then
    raise exception 'Admins only' using errcode = '42501';
  end if;
  if p_source is null or p_source not in ('stock', 'live') then
    raise exception 'Data source must be stock or live';
  end if;

  select user_data_source into v_old from public.platform_settings;
  update public.platform_settings set user_data_source = p_source where id;

  insert into public.admin_audit_log (actor_id, action, entity_type, details)
  values (auth.uid(), 'set_user_data_source', 'platform_settings',
          jsonb_build_object('from', v_old, 'to', p_source));

  return p_source;
end;
$$;


-- -----------------------------------------------------------------------------
-- 11. Views (security_invoker: they respect the caller's RLS)
-- -----------------------------------------------------------------------------

-- One row per listed market with its options inlined — for market cards.
create view public.market_feed
with (security_invoker = true)
as
select
  m.id,
  m.slug,
  m.title,
  m.market_type,
  m.status,
  m.is_featured,
  m.image_url,
  m.period,
  m.category_id,
  c.name  as category_name,
  c.color as category_color,
  m.subcategory_id,
  sc.name as subcategory_name,
  m.event_id,
  m.volume_kobo,
  m.traders_count,
  m.opens_at,
  m.closes_at,
  m.created_at,
  coalesce(o.outcomes, '[]'::jsonb) as outcomes
from public.markets m
join public.categories c on c.id = m.category_id
left join public.categories sc on sc.id = m.subcategory_id
left join lateral (
  select jsonb_agg(
           jsonb_build_object(
             'id', mo.id, 'label', mo.label, 'short_label', mo.short_label,
             'image_url', mo.image_url, 'emoji', mo.emoji, 'color', mo.color,
             'price', mo.price, 'is_winner', mo.is_winner)
           order by mo.sort_order, mo.id) as outcomes
  from public.market_outcomes mo
  where mo.market_id = m.id
) o on true
where not m.is_hidden;

-- Wallet "Predictions" list and the "Your position" screen.
create view public.my_positions
with (security_invoker = true)
as
select
  p.market_id,
  p.outcome_id,
  m.title     as market_title,
  m.status    as market_status,
  m.image_url as market_image_url,
  o.label     as outcome_label,
  o.image_url as outcome_image_url,
  o.emoji     as outcome_emoji,
  o.color     as outcome_color,
  p.shares,
  o.price                                                       as chance,
  p.cost_basis_kobo,
  floor(p.shares * coalesce(o.price, 0) * 10000)::bigint        as value_kobo,
  floor(p.shares * coalesce(o.price, 0) * 10000)::bigint - p.cost_basis_kobo as change_kobo,
  floor(p.shares * 10000)::bigint                               as payout_if_right_kobo,
  p.realized_pnl_kobo,
  p.payout_kobo,
  p.settled_at,
  p.updated_at
from public.positions p
join public.market_outcomes o on o.id = p.outcome_id
join public.markets m on m.id = p.market_id
where p.user_id = (select auth.uid())
  and (p.shares > 0 or p.settled_at is not null);

-- Wallet header: "Cash Balance" and "Holdings".
create view public.my_wallet
with (security_invoker = true)
as
select
  w.balance_kobo as cash_balance_kobo,
  coalesce((
    select sum(mp.value_kobo) from public.my_positions mp where mp.settled_at is null
  ), 0)::bigint  as holdings_kobo,
  w.currency,
  w.updated_at
from public.wallets w
where w.user_id = (select auth.uid());

-- Arena feed and replies, with author info and the viewer's own reactions.
create view public.feed_posts
with (security_invoker = true)
as
select
  p.id,
  p.author_id,
  a.username     as author_username,
  a.avatar_url   as author_avatar_url,
  a.avatar_color as author_avatar_color,
  a.is_official  as author_is_official,
  a.is_verified  as author_is_verified,
  p.body,
  p.parent_id,
  p.quoted_post_id,
  p.market_id,
  p.category_id,
  p.reply_count,
  p.reaction_count,
  p.reaction_counts,
  coalesce((
    select array_agg(r.reaction order by r.reaction)
    from public.post_reactions r
    where r.post_id = p.id and r.user_id = (select auth.uid())
  ), '{}') as my_reactions,
  p.created_at,
  p.updated_at
from public.posts p
join public.profiles a on a.id = p.author_id
where p.deleted_at is null
  and not p.is_hidden
  and not exists (
    select 1 from public.post_hides h
    where h.post_id = p.id and h.user_id = (select auth.uid())
  );


-- -----------------------------------------------------------------------------
-- 12. Row Level Security
-- -----------------------------------------------------------------------------
alter table public.profiles                 enable row level security;
alter table public.profile_private          enable row level security;
alter table public.user_roles               enable row level security;
alter table public.interests                enable row level security;
alter table public.user_interests           enable row level security;
alter table public.categories               enable row level security;
alter table public.topics                   enable row level security;
alter table public.teams                    enable row level security;
alter table public.events                   enable row level security;
alter table public.markets                  enable row level security;
alter table public.market_outcomes          enable row level security;
alter table public.market_links             enable row level security;
alter table public.market_price_history     enable row level security;
alter table public.topic_markets            enable row level security;
alter table public.shelves                  enable row level security;
alter table public.shelf_items              enable row level security;
alter table public.banners                  enable row level security;
alter table public.platform_settings        enable row level security;
alter table public.wallets                  enable row level security;
alter table public.banks                    enable row level security;
alter table public.bank_accounts            enable row level security;
alter table public.virtual_accounts         enable row level security;
alter table public.direct_debit_mandates    enable row level security;
alter table public.deposits                 enable row level security;
alter table public.withdrawals              enable row level security;
alter table public.trades                   enable row level security;
alter table public.positions                enable row level security;
alter table public.wallet_transactions      enable row level security;
alter table public.posts                    enable row level security;
alter table public.post_reactions           enable row level security;
alter table public.post_hides               enable row level security;
alter table public.notifications            enable row level security;
alter table public.notification_preferences enable row level security;
alter table public.push_tokens              enable row level security;
alter table public.recent_searches          enable row level security;
alter table public.admin_audit_log          enable row level security;

-- profiles
create policy "Profiles are public"
  on public.profiles for select to anon, authenticated using (true);
create policy "Users update their own profile"
  on public.profiles for update to authenticated
  using (id = (select auth.uid())) with check (id = (select auth.uid()));
create policy "Admins update any profile"
  on public.profiles for update to authenticated
  using (private.is_admin()) with check (private.is_admin());

-- profile_private
create policy "Users read their own private profile"
  on public.profile_private for select to authenticated using (id = (select auth.uid()));
create policy "Users create their own private profile"
  on public.profile_private for insert to authenticated with check (id = (select auth.uid()));
create policy "Users update their own private profile"
  on public.profile_private for update to authenticated
  using (id = (select auth.uid())) with check (id = (select auth.uid()));

-- user_roles
create policy "Users read their own roles"
  on public.user_roles for select to authenticated
  using (user_id = (select auth.uid()) or private.is_admin());
create policy "Admins manage roles"
  on public.user_roles for all to authenticated
  using (private.is_admin()) with check (private.is_admin());

-- interests
create policy "Interests are public"
  on public.interests for select to anon, authenticated using (true);
create policy "Admins manage interests"
  on public.interests for all to authenticated
  using (private.is_admin()) with check (private.is_admin());
create policy "Users read their own interests"
  on public.user_interests for select to authenticated using (user_id = (select auth.uid()));
create policy "Users add their own interests"
  on public.user_interests for insert to authenticated with check (user_id = (select auth.uid()));
create policy "Users remove their own interests"
  on public.user_interests for delete to authenticated using (user_id = (select auth.uid()));

-- Public catalogue tables: everyone reads, admins write.
do $$
declare
  t text;
begin
  foreach t in array array[
    'categories', 'topics', 'teams', 'events', 'market_links', 'topic_markets',
    'shelves', 'shelf_items', 'banners', 'banks', 'market_price_history'
  ] loop
    execute format(
      'create policy "Public read" on public.%I for select to anon, authenticated using (true)', t);
    execute format(
      'create policy "Admins manage" on public.%I for all to authenticated
         using (private.is_admin()) with check (private.is_admin())', t);
  end loop;
end;
$$;

-- markets & options (drafts are admin-only)
create policy "Published markets are public"
  on public.markets for select to anon, authenticated
  using (status <> 'draft' or private.is_admin());
create policy "Admins manage markets"
  on public.markets for all to authenticated
  using (private.is_admin()) with check (private.is_admin());

create policy "Options of visible markets are public"
  on public.market_outcomes for select to anon, authenticated
  using (exists (select 1 from public.markets m where m.id = market_id));
create policy "Admins manage options"
  on public.market_outcomes for all to authenticated
  using (private.is_admin()) with check (private.is_admin());

-- settings
create policy "Settings are public"
  on public.platform_settings for select to anon, authenticated using (true);
create policy "Admins update settings"
  on public.platform_settings for update to authenticated
  using (private.is_admin()) with check (private.is_admin());

-- Money tables: owners and admins read; writes only through RPCs / service role.
do $$
declare
  t text;
begin
  foreach t in array array[
    'wallets', 'wallet_transactions', 'trades', 'positions',
    'deposits', 'withdrawals', 'virtual_accounts', 'direct_debit_mandates'
  ] loop
    execute format(
      'create policy "Owners read" on public.%I for select to authenticated
         using (user_id = (select auth.uid()) or private.is_admin())', t);
  end loop;
end;
$$;

create policy "Owners read active bank accounts"
  on public.bank_accounts for select to authenticated
  using ((user_id = (select auth.uid()) and deleted_at is null) or private.is_admin());

-- posts
create policy "Visible posts are public"
  on public.posts for select to anon, authenticated
  using ((deleted_at is null and not is_hidden)
         or author_id = (select auth.uid())
         or private.is_admin());
create policy "Users create their own posts"
  on public.posts for insert to authenticated
  with check (author_id = (select auth.uid()));
create policy "Users edit or delete their own posts"
  on public.posts for update to authenticated
  using (author_id = (select auth.uid())) with check (author_id = (select auth.uid()));
create policy "Admins moderate posts"
  on public.posts for update to authenticated
  using (private.is_admin()) with check (private.is_admin());

create policy "Reactions are public"
  on public.post_reactions for select to anon, authenticated using (true);
create policy "Users react as themselves"
  on public.post_reactions for insert to authenticated with check (user_id = (select auth.uid()));
create policy "Users remove their own reactions"
  on public.post_reactions for delete to authenticated using (user_id = (select auth.uid()));

-- Per-user tables
create policy "Users manage their hidden posts"
  on public.post_hides for all to authenticated
  using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));
create policy "Users read their notifications"
  on public.notifications for select to authenticated using (user_id = (select auth.uid()));
create policy "Users read their notification settings"
  on public.notification_preferences for select to authenticated using (user_id = (select auth.uid()));
create policy "Users update their notification settings"
  on public.notification_preferences for update to authenticated
  using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));
create policy "Users manage their push tokens"
  on public.push_tokens for all to authenticated
  using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));
create policy "Users manage their recent searches"
  on public.recent_searches for all to authenticated
  using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));
create policy "Admins read the audit log"
  on public.admin_audit_log for select to authenticated using (private.is_admin());

-- Defence in depth: API roles can never write money tables directly, even if a
-- permissive policy is added later by mistake.
revoke insert, update, delete, truncate on
  public.wallets, public.wallet_transactions, public.trades, public.positions,
  public.deposits, public.withdrawals, public.bank_accounts, public.virtual_accounts,
  public.direct_debit_mandates, public.market_price_history, public.notifications,
  public.admin_audit_log
from anon, authenticated;


-- -----------------------------------------------------------------------------
-- 13. Function privileges
-- -----------------------------------------------------------------------------
revoke execute on all functions in schema private from public, anon, authenticated;
-- Used inside RLS policies and invoker triggers.
grant execute on function
  private.is_admin(),
  private.is_admin_or_service(),
  private.is_trusted_context(),
  private.init_market_prices(uuid, integer)
to anon, authenticated;

revoke execute on all functions in schema public from public, anon, authenticated;

grant execute on function
  public.get_email_for_username(text),
  public.quote_buy(uuid, bigint),
  public.quote_sell(uuid, numeric),
  public.search(text, integer),
  public.trending_markets(uuid, integer, integer)
to anon, authenticated;

grant execute on function
  public.buy_shares(uuid, bigint, numeric),
  public.sell_shares(uuid, numeric, bigint),
  public.request_withdrawal(uuid, bigint),
  public.create_direct_debit_deposit(uuid, bigint),
  public.remove_bank_account(uuid),
  public.mark_notifications_read(uuid[]),
  public.touch_last_seen(),
  public.request_account_deletion(),
  -- admin RPCs check private.is_admin_or_service() themselves
  public.resolve_market(uuid, uuid, text),
  public.settle_market(uuid, boolean),
  public.void_market(uuid, text),
  public.admin_overview(),
  public.admin_user_growth(integer),
  public.set_user_data_source(text)
to authenticated;

-- confirm_deposit, record_transfer_deposit, fail_deposit, complete_withdrawal,
-- fail_withdrawal and settle_due_markets stay service_role-only.
grant execute on function
  public.confirm_deposit(uuid, text, bigint),
  public.record_transfer_deposit(text, bigint, text, bigint, jsonb),
  public.fail_deposit(uuid, text),
  public.complete_withdrawal(uuid, text),
  public.fail_withdrawal(uuid, text),
  public.settle_due_markets()
to service_role;


-- -----------------------------------------------------------------------------
-- 14. Storage
-- -----------------------------------------------------------------------------
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values
  ('avatars', 'avatars', true, 2097152, array['image/png', 'image/jpeg', 'image/webp']),
  -- market images, option avatars, banners, category icons, team badges
  ('media',   'media',   true, 5242880, array['image/png', 'image/jpeg', 'image/webp', 'image/svg+xml'])
on conflict (id) do nothing;

-- Avatars go in avatars/<user id>/<file>.
create policy "Users read their own avatar files"
  on storage.objects for select to authenticated
  using (bucket_id = 'avatars' and (storage.foldername(name))[1] = (select auth.uid())::text);
create policy "Users upload their own avatar"
  on storage.objects for insert to authenticated
  with check (bucket_id = 'avatars' and (storage.foldername(name))[1] = (select auth.uid())::text);
create policy "Users replace their own avatar"
  on storage.objects for update to authenticated
  using (bucket_id = 'avatars' and (storage.foldername(name))[1] = (select auth.uid())::text)
  with check (bucket_id = 'avatars' and (storage.foldername(name))[1] = (select auth.uid())::text);
create policy "Users delete their own avatar"
  on storage.objects for delete to authenticated
  using (bucket_id = 'avatars' and (storage.foldername(name))[1] = (select auth.uid())::text);
create policy "Admins manage media"
  on storage.objects for all to authenticated
  using (bucket_id = 'media' and private.is_admin())
  with check (bucket_id = 'media' and private.is_admin());


-- -----------------------------------------------------------------------------
-- 15. Realtime (live prices, scores, notifications, balance, feed, data source)
-- -----------------------------------------------------------------------------
do $$
declare
  t text;
begin
  foreach t in array array['markets', 'market_outcomes', 'events', 'notifications', 'wallets', 'posts', 'platform_settings'] loop
    if not exists (
      select 1 from pg_publication_tables
      where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = t
    ) then
      execute format('alter publication supabase_realtime add table public.%I', t);
    end if;
  end loop;
end;
$$;


-- -----------------------------------------------------------------------------
-- 16. Scheduled jobs (enable pg_cron under Database → Extensions first)
-- -----------------------------------------------------------------------------
-- select cron.schedule('settle-due-markets', '* * * * *', $$select public.settle_due_markets()$$);


-- -----------------------------------------------------------------------------
-- 17. Seed data (values the app currently hard-codes)
-- -----------------------------------------------------------------------------
insert into public.platform_settings default values;

insert into public.interests (label, emoji, sort_order) values
  ('Sports', '⚽', 1),
  ('Gaming', '🎮', 2),
  ('Crypto & Finance', '💰', 3),
  ('Politics', '🗳️', 4),
  ('Science', '🔭', 5),
  ('Culture & Entertainment', '🎭', 6),
  ('Markets & Economy', '📈', 7),
  ('Tech & AI', '🤖', 8),
  ('Memes & Pop Culture', '😂', 9),
  ('Future Trends', '🔮', 10),
  ('Influencer & Lifestyle', '🧑', 11);

insert into public.categories (name, slug, emoji, color, sort_order) values
  ('Politics',       'politics',     '🏛️', '#FFD500', 1),
  ('Sports',         'sports',       '⚽', '#19D36D', 2),
  ('Culture',        'culture',      '🎭', '#FF4A7A', 3),
  ('Tech & Science', 'tech-science', '🧬', '#22E6F0', 4),
  ('Economics',      'economics',    '💼', '#F5F5F5', 5),
  ('Socials',        'socials',      '◼',  '#6E7380', 6);

insert into public.categories (parent_id, name, slug, emoji, color, sort_order)
select c.id, s.name, s.slug, s.emoji, s.color, s.sort_order
from (values
  ('Football',   'football',   '⚽', '#19D36D', 1),
  ('Basketball', 'basketball', '🏀', '#FF7A00', 2),
  ('Tennis',     'tennis',     '🎾', '#B8FF00', 3),
  ('Boxing',     'boxing',     '🥊', '#FF4F4F', 4),
  ('Wrestling',  'wrestling',  '🟪', '#CB10FF', 5)
) as s(name, slug, emoji, color, sort_order)
cross join public.categories c
where c.slug = 'sports';

insert into public.topics (category_id, name, slug, emoji, sort_order)
select c.id, t.name, t.slug, t.emoji, t.sort_order
from (values
  ('sports',       'Premier League', 'premier-league', '🏆', 1),
  ('sports',       'World Cup',      'world-cup',      '🌍', 2),
  ('sports',       'NBA Finals',     'nba-finals',     '🏀', 3),
  ('politics',     'Elections',      'elections',      '🗳️', 1),
  ('politics',     'Iran',           'iran',           null, 2),
  ('politics',     'Donald Trump',   'donald-trump',   null, 3),
  ('culture',      'Headies',        'headies',        null, 1),
  ('culture',      'Grammy',         'grammy',         null, 2),
  ('culture',      'Afrobeats',      'afrobeats',      null, 3),
  ('culture',      'Rap',            'rap',            null, 4),
  ('tech-science', 'AI',             'ai',             '🤖', 1),
  ('tech-science', 'Elon Musk',      'elon-musk',      null, 2),
  ('tech-science', 'ChatGPT',        'chatgpt',        null, 3),
  ('economics',    'World Debt',     'world-debt',     null, 1),
  ('economics',    'Crypto',         'crypto',         '₿',  2),
  ('economics',    'Inflation',      'inflation',      null, 3)
) as t(category_slug, name, slug, emoji, sort_order)
join public.categories c on c.slug = t.category_slug;

-- Bank list from SelectBankListScreen. Codes are left null; fill them from
-- your payment provider's bank-list endpoint.
insert into public.banks (name, is_popular, sort_order)
select name, ord <= 9, ord
from unnest(array[
  'Access Bank', 'FirstBank', 'GTBank', 'Kuda Microfinance Bank', 'Moniepoint MFB',
  'Opay', 'Palmpay', 'United Bank for Africa', 'Zenith Bank',
  'Accion Microfinance Bank', 'Advans La Fayette Microfinance Bank', 'Alternative Bank Limited',
  'Carbon - Digital Neobank / MFB', 'Citibank Nigeria Limited', 'Ecobank Nigeria Limited',
  'eTranzact International', 'Fairmoney Microfinance Bank', 'Fidelity Bank PLC',
  'First City Monument Bank', 'Globus Bank Limited', 'Hope Payment Service Bank', 'Jaiz Bank PLC',
  'Keystone Bank Limited', 'LAPO Microfinance Bank', 'Lotus Bank Limited', 'MoMO PSB',
  'MoneyMaster PSB', 'NIRSAL Microfinance Bank', 'Nova Commercial Bank', 'NowNow Digital Systems',
  'Optimus Bank Limited', 'Paga', 'Parallax Limited', 'Polaris Bank Limited', 'PremiumTrust Bank',
  'Providus Bank Limited', 'Signature Bank Limited', 'SmartCash PSB', 'Stanbic IBTC Bank PLC',
  'Standard Chartered Bank Nigeria', 'Sterling Bank PLC', 'Summit Bank', 'SunTrust Bank Nigeria Limited',
  'TAJBank Limited', 'Tatum Bank', 'Titan Trust Bank', 'Union Bank of Nigeria', 'Unity Bank PLC',
  'VBank', 'Wema Bank PLC'
]) with ordinality as b(name, ord);


-- -----------------------------------------------------------------------------
-- 18. Existing users: accounts created before this schema get a profile,
--     wallet and notification settings. Username, DOB, bio, avatar and
--     interests are carried over from legacy_profiles / legacy_user_interests
--     when section 1b renamed those tables.
-- -----------------------------------------------------------------------------
do $$
declare
  r          record;
  v_key      text;
  v_legacy   jsonb;
  v_username text;
  v_dob      date;
  v_min_age  integer;
  v_users    integer := 0;
  v_dobs     integer := 0;
  v_ints     integer := 0;
begin
  select min_age_years into v_min_age from public.platform_settings;

  if to_regclass('public.legacy_profiles') is not null then
    select column_name into v_key
    from information_schema.columns
    where table_schema = 'public' and table_name = 'legacy_profiles' and column_name in ('id', 'user_id')
    order by column_name = 'id' desc
    limit 1;
  end if;

  for r in
    select u.id, u.email, u.phone, u.raw_user_meta_data
    from auth.users u
    where not exists (select 1 from public.profiles p where p.id = u.id)
    order by u.created_at
  loop
    v_legacy := null;
    if v_key is not null then
      execute format('select to_jsonb(l) from public.legacy_profiles l where l.%I = $1 limit 1', v_key)
        into v_legacy using r.id;
    end if;

    -- Keep the old username when it is valid and still free.
    v_username := lower(btrim(coalesce(v_legacy ->> 'username', r.raw_user_meta_data ->> 'username', '')));
    if v_username !~ '^[a-z0-9_.]{3,30}$'
       or exists (select 1 from public.profiles where username = v_username) then
      v_username := 'user_' || substr(replace(r.id::text, '-', ''), 1, 10);
    end if;

    begin
      v_dob := (v_legacy ->> 'dob')::date;
    exception when others then
      v_dob := null;
    end;
    if v_dob > (current_date - make_interval(years => v_min_age))::date then
      v_dob := null;
    end if;

    insert into public.profiles (id, username, bio, avatar_url)
    values (r.id, v_username, left(v_legacy ->> 'bio', 160), v_legacy ->> 'avatar_url');
    insert into public.profile_private (id, email, phone, dob) values (r.id, r.email, r.phone, v_dob);
    insert into public.wallets (user_id) values (r.id);
    insert into public.notification_preferences (user_id) values (r.id);

    v_users := v_users + 1;
    v_dobs  := v_dobs + (v_dob is not null)::integer;
  end loop;

  if to_regclass('public.legacy_user_interests') is not null then
    execute $q$
      insert into public.user_interests (user_id, category)
      select distinct (to_jsonb(l) ->> 'user_id')::uuid, to_jsonb(l) ->> 'category'
      from public.legacy_user_interests l
      where to_jsonb(l) ->> 'category' in (select label from public.interests)
        and (to_jsonb(l) ->> 'user_id')::uuid in (select id from public.profiles)
      on conflict do nothing
    $q$;
    get diagnostics v_ints = row_count;
  end if;

  if v_users > 0 then
    insert into pigeon_install_report (action, detail)
    values ('migrated', format('%s existing user(s) got a profile and wallet (%s with date of birth, %s interests carried over)',
                               v_users, v_dobs, v_ints));
  end if;
  insert into pigeon_install_report (action, detail)
  values ('installed', 'Pigeon schema installed. Next: grant yourself admin (see the top of this file).');
end;
$$;

select action, detail from pigeon_install_report order by step;
