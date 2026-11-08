-- =============================================================================
-- Admin access
-- =============================================================================
-- Everything the Admin Panel needs on top of schema.sql:
--
--   1. Role helpers: private.has_role(), private.is_staff() (admin or moderator).
--   2. Role management: user_roles is written only through admin_set_role(),
--      which audits every change and never removes the last admin.
--   3. Moderators: read hidden posts and hide/unhide them with moderate_post().
--   4. Admins read users' contact details (profile_private) and search users
--      with admin_list_users().
--   5. Dashboards: admin_overview() gains the counts the panel cards show
--      (categories, topics & shelves, banners); admin_user_stats() feeds the
--      Users screen filters; admin_volume_series() feeds "Wage Volume".
--   6. Markets: the admin_markets view lists every market (drafts and hidden
--      ones included) for the Markets screen; admin_create_market() saves a
--      market with its options, links and topics in one transaction.
--   7. Topics & Shelves: admin_set_topic_markets() / admin_set_shelf_items()
--      replace a topic's or shelf's ordered contents in one call.
--   8. Catalogue quality of life: slugs are filled in from the name/title when
--      left empty, and deleting a category that still has markets fails with
--      a readable message.
--   9. Audit trail: every direct admin write to a catalogue table lands in
--      admin_audit_log with the changed columns. Admin RPCs that already log
--      themselves (resolve/settle/void, set_user_data_source) are not doubled.
--
-- Access model
--   admin      everything below, plus what schema.sql already grants
--              (catalogue CRUD, markets, settings, media bucket, money reads).
--   moderator  read every post (hidden too) and hide/unhide posts. Nothing else.
--   service    (service_role key / SQL editor) passes every admin check, as in
--              schema.sql, so Edge Functions and pg_cron can call admin RPCs.
--
-- Run once in the SQL editor (or `supabase db push`) after schema.sql and
-- 20261018000000_user_data_source.sql. Safe to re-run.
-- =============================================================================


-- -----------------------------------------------------------------------------
-- 1. Role helpers
-- -----------------------------------------------------------------------------
create or replace function private.has_role(p_role public.app_role)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.user_roles
    where user_id = (select auth.uid()) and role = p_role
  );
$$;

-- Admin or moderator.
create or replace function private.is_staff()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.user_roles
    where user_id = (select auth.uid()) and role in ('admin', 'moderator')
  );
$$;

-- Writes one audit row for the current admin or moderator; a no-op for anyone
-- else. Called by the audit trigger, which runs as the API user.
create or replace function private.write_audit(
  p_action      text,
  p_entity_type text,
  p_entity_id   uuid,
  p_details     jsonb
)
returns void
language sql
security definer
set search_path = ''
as $$
  insert into public.admin_audit_log (actor_id, action, entity_type, entity_id, details)
  select auth.uid(), p_action, p_entity_type, p_entity_id, coalesce(p_details, '{}'::jsonb)
  where private.is_staff();
$$;

create or replace function private.slugify(p_text text)
returns text
language sql
immutable
set search_path = ''
as $$
  select nullif(btrim(regexp_replace(lower(coalesce(p_text, '')), '[^a-z0-9]+', '-', 'g'), '-'), '');
$$;


-- -----------------------------------------------------------------------------
-- 2. Role management
-- -----------------------------------------------------------------------------

-- Roles change only through admin_set_role(), so every grant is audited and
-- the last admin can't be removed by accident. Users still read their own
-- roles ("Users read their own roles" in schema.sql).
drop policy if exists "Admins manage roles" on public.user_roles;
revoke insert, update, delete, truncate on public.user_roles from anon, authenticated;

-- Grants (p_granted = true) or revokes a role. Returns the user's roles after
-- the change.
create or replace function public.admin_set_role(
  p_user_id uuid,
  p_role    public.app_role,
  p_granted boolean default true
)
returns public.app_role[]
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_changed integer;
  v_roles   public.app_role[];
begin
  if not private.is_admin_or_service() then
    raise exception 'Admins only' using errcode = '42501';
  end if;
  if not exists (select 1 from public.profiles where id = p_user_id) then
    raise exception 'User not found';
  end if;

  if p_granted then
    insert into public.user_roles (user_id, role, granted_by)
    values (p_user_id, p_role, auth.uid())
    on conflict (user_id, role) do nothing;
  else
    if p_role = 'admin' then
      -- Serialise concurrent revokes so two admins can't remove each other.
      perform 1 from public.user_roles where role = 'admin' for update;
      if not exists (
        select 1 from public.user_roles where role = 'admin' and user_id <> p_user_id
      ) then
        raise exception 'Cannot remove the last admin';
      end if;
    end if;
    delete from public.user_roles where user_id = p_user_id and role = p_role;
  end if;
  get diagnostics v_changed = row_count;

  if v_changed > 0 then
    insert into public.admin_audit_log (actor_id, action, entity_type, entity_id, details)
    values (auth.uid(), case when p_granted then 'role.grant' else 'role.revoke' end,
            'user', p_user_id, jsonb_build_object('role', p_role));
  end if;

  select coalesce(array_agg(role order by role), '{}') into v_roles
  from public.user_roles where user_id = p_user_id;
  return v_roles;
end;
$$;


-- -----------------------------------------------------------------------------
-- 3. Moderation
-- -----------------------------------------------------------------------------
drop policy if exists "Staff read all posts" on public.posts;
create policy "Staff read all posts"
  on public.posts for select to authenticated using (private.is_staff());

create or replace function public.moderate_post(
  p_post_id uuid,
  p_hidden  boolean,
  p_reason  text default null
)
returns public.posts
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_post public.posts;
begin
  if not (private.is_staff() or private.is_admin_or_service()) then
    raise exception 'Moderators only' using errcode = '42501';
  end if;

  update public.posts set is_hidden = p_hidden
   where id = p_post_id
  returning * into v_post;
  if not found then
    raise exception 'Post not found';
  end if;

  insert into public.admin_audit_log (actor_id, action, entity_type, entity_id, details)
  values (auth.uid(), case when p_hidden then 'post.hide' else 'post.unhide' end,
          'post', p_post_id, jsonb_build_object('reason', p_reason, 'author_id', v_post.author_id));

  return v_post;
end;
$$;


-- -----------------------------------------------------------------------------
-- 4. Users
-- -----------------------------------------------------------------------------
drop policy if exists "Admins read private profiles" on public.profile_private;
create policy "Admins read private profiles"
  on public.profile_private for select to authenticated using (private.is_admin());

-- User directory. p_query matches username, email or phone; p_role keeps only
-- users holding that role. total_count is the match count before paging.
create or replace function public.admin_list_users(
  p_query  text default null,
  p_role   public.app_role default null,
  p_limit  integer default 50,
  p_offset integer default 0
)
returns table (
  id                    uuid,
  username              text,
  email                 text,
  phone                 text,
  avatar_url            text,
  avatar_color          text,
  is_verified           boolean,
  is_official           boolean,
  roles                 public.app_role[],
  balance_kobo          bigint,
  posts_count           integer,
  trades_count          integer,
  trade_volume_kobo     bigint,
  last_seen_at          timestamptz,
  deletion_requested_at timestamptz,
  created_at            timestamptz,
  total_count           bigint
)
language plpgsql
stable
security definer
set search_path = ''
as $$
#variable_conflict use_column
declare
  v_query text := '%' || replace(replace(replace(btrim(coalesce(p_query, '')), '\', '\\'), '%', '\%'), '_', '\_') || '%';
begin
  if not private.is_admin_or_service() then
    raise exception 'Admins only' using errcode = '42501';
  end if;

  return query
  select p.id, p.username, pp.email, pp.phone, p.avatar_url, p.avatar_color,
         p.is_verified, p.is_official, coalesce(r.roles, '{}'), w.balance_kobo,
         p.posts_count, p.trades_count, p.trade_volume_kobo, p.last_seen_at,
         p.deletion_requested_at, p.created_at,
         count(*) over ()
  from public.profiles p
  left join public.profile_private pp on pp.id = p.id
  left join public.wallets w on w.user_id = p.id
  left join lateral (
    select array_agg(ur.role order by ur.role) as roles
    from public.user_roles ur
    where ur.user_id = p.id
  ) r on true
  where (v_query = '%%'
         or p.username ilike v_query
         or pp.email ilike v_query
         or pp.phone like v_query)
    and (p_role is null or p_role = any (r.roles))
  order by p.created_at desc
  limit least(greatest(coalesce(p_limit, 50), 1), 200)
  offset greatest(coalesce(p_offset, 0), 0);
end;
$$;


-- -----------------------------------------------------------------------------
-- 5. Dashboards
-- -----------------------------------------------------------------------------

-- Admin Panel cards. Keys from schema.sql are unchanged; the counts for the
-- Categories, Topics & Shelves and Banners cards are new.
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
    'total_users',         (select count(*) from public.profiles),
    'joined_today',        (select count(*) from public.profiles where created_at >= v_today),
    'active_users_7d',     (select count(*) from public.profiles where last_seen_at > now() - interval '7 days'),
    'total_markets',       (select count(*) from public.markets where status <> 'draft'),
    'markets_by_status',   (select coalesce(jsonb_object_agg(status, n), '{}'::jsonb)
                              from (select status, count(*) as n from public.markets group by status) s),
    'hidden_markets',      (select count(*) from public.markets where is_hidden),
    'wager_volume_kobo',   (select coalesce(sum(volume_kobo), 0) from public.markets),
    'fees_kobo',           (select coalesce(sum(fees_collected_kobo), 0) from public.markets),
    'categories_count',    (select count(*) from public.categories where parent_id is null),
    'subcategories_count', (select count(*) from public.categories where parent_id is not null),
    'topics_count',        (select count(*) from public.topics),
    'shelves_count',       (select count(*) from public.shelves),
    'banners_count',       (select count(*) from public.banners where is_active),
    'open_withdrawals',    (select count(*) from public.withdrawals where status in ('pending', 'processing')),
    'top_markets',         (select coalesce(jsonb_agg(x), '[]'::jsonb) from (
                              select id, title, image_url, status, volume_kobo, traders_count
                              from public.markets
                              where status <> 'draft'
                              order by volume_kobo desc
                              limit 5) x)
  );
end;
$$;

-- Users screen stats for the All / 7D / 1M filter (p_days null, 7 or 30).
-- new_users and active_users cover the window; "All" counts users active in
-- the last 30 days. Days are in Lagos time, matching admin_user_growth().
create or replace function public.admin_user_stats(p_days integer default null)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_today timestamptz := date_trunc('day', now() at time zone 'Africa/Lagos') at time zone 'Africa/Lagos';
  v_since timestamptz;
begin
  if not private.is_admin_or_service() then
    raise exception 'Admins only' using errcode = '42501';
  end if;
  if p_days is not null and p_days < 1 then
    raise exception 'p_days must be at least 1';
  end if;
  v_since := v_today - make_interval(days => coalesce(p_days, 1) - 1);

  return jsonb_build_object(
    'total_users',  (select count(*) from public.profiles),
    'new_users',    (select count(*) from public.profiles
                      where p_days is null or created_at >= v_since),
    'active_users', (select count(*) from public.profiles
                      where last_seen_at >= case when p_days is null then now() - interval '30 days' else v_since end),
    'joined_today', (select count(*) from public.profiles where created_at >= v_today)
  );
end;
$$;

-- "Wage Volume" chart: traded amount, fees and trade count per day.
-- p_days = 7, 30 or null (since the first trade).
create or replace function public.admin_volume_series(p_days integer default null)
returns table (day date, volume_kobo bigint, fees_kobo bigint, trades bigint)
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
    select (t.created_at at time zone 'Africa/Lagos')::date as d,
           sum(t.amount_kobo)::bigint as volume,
           sum(t.fee_kobo)::bigint    as fees,
           count(*)                   as n
    from public.trades t
    group by 1
  ),
  span as (
    select generate_series(
             coalesce(v_today - (p_days - 1), (select min(d) from daily), v_today),
             v_today,
             interval '1 day')::date as d
  )
  select s.d, coalesce(daily.volume, 0), coalesce(daily.fees, 0), coalesce(daily.n, 0)
  from span s
  left join daily on daily.d = s.d
  order by s.d;
end;
$$;


-- -----------------------------------------------------------------------------
-- 6. Markets
-- -----------------------------------------------------------------------------

-- Every market for the admin Markets screen, including drafts and hidden ones
-- (market_feed leaves hidden markets out). Empty for non-admins.
create or replace view public.admin_markets
with (security_invoker = true)
as
select
  m.id,
  m.slug,
  m.title,
  m.description,
  m.market_type,
  m.status,
  m.is_hidden,
  m.is_featured,
  m.category_id,
  c.name  as category_name,
  c.slug  as category_slug,
  c.color as category_color,
  m.subcategory_id,
  sc.name as subcategory_name,
  m.event_id,
  m.image_url,
  m.period,
  m.resolution_criteria,
  m.settlement_terms,
  m.wager_terms,
  m.seed_kobo,
  m.liquidity_b is not null as is_published,
  m.fee_bps,
  m.volume_kobo,
  m.fees_collected_kobo,
  m.buys_count,
  m.sells_count,
  m.traders_count,
  m.last_traded_at,
  m.opens_at,
  m.closes_at,
  m.resolved_outcome_id,
  m.resolved_at,
  m.settled_at,
  m.voided_at,
  m.void_reason,
  m.created_by,
  m.created_at,
  m.updated_at,
  coalesce(o.outcomes, '[]'::jsonb) as outcomes,
  coalesce(tm.topic_ids, '{}')      as topic_ids
from public.markets m
join public.categories c on c.id = m.category_id
left join public.categories sc on sc.id = m.subcategory_id
left join lateral (
  select jsonb_agg(
           jsonb_build_object(
             'id', mo.id, 'label', mo.label, 'short_label', mo.short_label,
             'image_url', mo.image_url, 'emoji', mo.emoji, 'color', mo.color,
             'price', mo.price, 'shares_outstanding', mo.shares_outstanding,
             'is_winner', mo.is_winner)
           order by mo.sort_order, mo.id) as outcomes
  from public.market_outcomes mo
  where mo.market_id = m.id
) o on true
left join lateral (
  select array_agg(t.topic_id order by t.sort_order) as topic_ids
  from public.topic_markets t
  where t.market_id = m.id
) tm on true
where private.is_admin();

revoke all on public.admin_markets from public, anon;
grant select on public.admin_markets to authenticated;

-- Saves a new market with its options, related-news links and topics in one
-- transaction, then moves it to p_status. Publishing ('active' / 'live') runs
-- the usual checks in markets_before_write (seed set, at least 2 options).
--
--   p_market   {"title", "description", "market_type", "category_id" | "category_slug",
--               "subcategory_id" | "subcategory_slug", "event_id", "image_url", "period",
--               "resolution_criteria", "settlement_terms", "wager_terms",
--               "opens_at", "closes_at", "seed_kobo", "fee_bps", "is_featured", "is_hidden"}
--   p_outcomes [{"label", "short_label", "image_url", "emoji", "color"}, …]  (in display order)
--   p_links    [{"url", "title", "source_name"}, …]
--
-- Runs as the caller, so RLS and the protective triggers apply exactly as for
-- direct admin writes.
create or replace function public.admin_create_market(
  p_market    jsonb,
  p_outcomes  jsonb,
  p_links     jsonb default '[]'::jsonb,
  p_topic_ids uuid[] default '{}',
  p_status    public.market_status default 'draft'
)
returns public.markets
language plpgsql
security invoker
set search_path = ''
as $$
declare
  v_market public.markets;
begin
  if not private.is_admin() then
    raise exception 'Admins only' using errcode = '42501';
  end if;
  if jsonb_typeof(p_outcomes) is distinct from 'array' then
    raise exception 'Options must be a JSON array';
  end if;
  if p_links is not null and jsonb_typeof(p_links) <> 'array' then
    raise exception 'Links must be a JSON array';
  end if;
  if p_status in ('closed', 'resolved', 'settled', 'voided') then
    raise exception 'A new market cannot start as %', p_status;
  end if;

  insert into public.markets (
    title, description, market_type, category_id, subcategory_id, event_id,
    image_url, period, resolution_criteria, settlement_terms, wager_terms,
    opens_at, closes_at, seed_kobo, fee_bps, is_featured, is_hidden
  ) values (
    btrim(p_market ->> 'title'),
    nullif(btrim(p_market ->> 'description'), ''),
    coalesce((p_market ->> 'market_type')::public.market_type, 'multiple_choice'),
    coalesce((p_market ->> 'category_id')::uuid,
             (select id from public.categories where slug = p_market ->> 'category_slug')),
    coalesce((p_market ->> 'subcategory_id')::uuid,
             (select id from public.categories where slug = p_market ->> 'subcategory_slug')),
    (p_market ->> 'event_id')::uuid,
    p_market ->> 'image_url',
    p_market ->> 'period',
    p_market ->> 'resolution_criteria',
    p_market ->> 'settlement_terms',
    p_market ->> 'wager_terms',
    (p_market ->> 'opens_at')::timestamptz,
    (p_market ->> 'closes_at')::timestamptz,
    coalesce((p_market ->> 'seed_kobo')::bigint, 0),
    (p_market ->> 'fee_bps')::integer,
    coalesce((p_market ->> 'is_featured')::boolean, false),
    coalesce((p_market ->> 'is_hidden')::boolean, false)
  )
  returning * into v_market;

  insert into public.market_outcomes (market_id, label, short_label, image_url, emoji, color, sort_order)
  select v_market.id, btrim(o.value ->> 'label'), o.value ->> 'short_label', o.value ->> 'image_url',
         o.value ->> 'emoji', o.value ->> 'color', o.ord::integer
  from jsonb_array_elements(p_outcomes) with ordinality as o(value, ord);

  insert into public.market_links (market_id, url, title, source_name, sort_order)
  select v_market.id, btrim(l.value ->> 'url'), l.value ->> 'title', l.value ->> 'source_name', l.ord::integer
  from jsonb_array_elements(coalesce(p_links, '[]'::jsonb)) with ordinality as l(value, ord);

  insert into public.topic_markets (topic_id, market_id, sort_order)
  select t.topic_id, v_market.id,
         (select coalesce(max(x.sort_order), -1) + 1 from public.topic_markets x where x.topic_id = t.topic_id)
  from (select distinct unnest(coalesce(p_topic_ids, '{}')) as topic_id) t;

  if p_status <> 'draft' then
    update public.markets set status = p_status where id = v_market.id
    returning * into v_market;
  end if;

  return v_market;
end;
$$;


-- -----------------------------------------------------------------------------
-- 7. Topics & Shelves
-- -----------------------------------------------------------------------------

-- Sets a topic's markets to exactly p_market_ids, in that order.
create or replace function public.admin_set_topic_markets(p_topic_id uuid, p_market_ids uuid[])
returns void
language plpgsql
security invoker
set search_path = ''
as $$
begin
  if not private.is_admin() then
    raise exception 'Admins only' using errcode = '42501';
  end if;
  if not exists (select 1 from public.topics where id = p_topic_id) then
    raise exception 'Topic not found';
  end if;

  delete from public.topic_markets
   where topic_id = p_topic_id
     and market_id <> all (coalesce(p_market_ids, '{}'));

  insert into public.topic_markets (topic_id, market_id, sort_order)
  select distinct on (u.market_id) p_topic_id, u.market_id, u.ord::integer
  from unnest(coalesce(p_market_ids, '{}')) with ordinality as u(market_id, ord)
  order by u.market_id, u.ord
  on conflict (topic_id, market_id) do update set sort_order = excluded.sort_order;
end;
$$;

-- Sets a shelf's items, in order. Each item is {"market_id": …} or {"topic_id": …}.
create or replace function public.admin_set_shelf_items(p_shelf_id uuid, p_items jsonb)
returns void
language plpgsql
security invoker
set search_path = ''
as $$
begin
  if not private.is_admin() then
    raise exception 'Admins only' using errcode = '42501';
  end if;
  if not exists (select 1 from public.shelves where id = p_shelf_id) then
    raise exception 'Shelf not found';
  end if;
  if p_items is not null and jsonb_typeof(p_items) <> 'array' then
    raise exception 'Items must be a JSON array';
  end if;

  delete from public.shelf_items where shelf_id = p_shelf_id;

  insert into public.shelf_items (shelf_id, market_id, topic_id, sort_order)
  select p_shelf_id, (i.value ->> 'market_id')::uuid, (i.value ->> 'topic_id')::uuid, i.ord::integer
  from jsonb_array_elements(coalesce(p_items, '[]'::jsonb)) with ordinality as i(value, ord);
end;
$$;


-- -----------------------------------------------------------------------------
-- 8. Catalogue quality of life
-- -----------------------------------------------------------------------------

-- Fills an empty slug from the column named in the trigger argument, adding
-- -2, -3 … until it is unique.
create or replace function private.fill_slug()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_base   text;
  v_slug   text;
  v_n      integer := 1;
  v_taken  boolean;
begin
  if nullif(btrim(new.slug), '') is not null then
    return new;
  end if;

  v_base := coalesce(private.slugify(to_jsonb(new) ->> tg_argv[0]), tg_table_name);
  v_slug := v_base;
  loop
    execute format('select exists (select 1 from public.%I where slug = $1)', tg_table_name)
      into v_taken using v_slug;
    exit when not v_taken;
    v_n := v_n + 1;
    v_slug := v_base || '-' || v_n;
  end loop;

  new.slug := v_slug;
  return new;
end;
$$;

drop trigger if exists fill_slug on public.categories;
create trigger fill_slug before insert on public.categories
  for each row execute function private.fill_slug('name');
drop trigger if exists fill_slug on public.topics;
create trigger fill_slug before insert on public.topics
  for each row execute function private.fill_slug('name');
drop trigger if exists fill_slug on public.markets;
create trigger fill_slug before insert on public.markets
  for each row execute function private.fill_slug('title');

-- markets.category_id / subcategory_id block the delete anyway; this replaces
-- the raw foreign-key error with one the Admin Panel can show.
create or replace function private.categories_before_delete()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_markets bigint;
begin
  select count(*) into v_markets
  from public.markets
  where category_id = old.id or subcategory_id = old.id;

  if v_markets > 0 then
    raise exception 'Category "%" still has % market(s). Move them to another category, or set is_active = false to hide the category instead.',
      old.name, v_markets
      using errcode = '23503';
  end if;
  return old;
end;
$$;

drop trigger if exists categories_before_delete on public.categories;
create trigger categories_before_delete before delete on public.categories
  for each row execute function private.categories_before_delete();


-- -----------------------------------------------------------------------------
-- 9. Audit trail for direct admin writes
-- -----------------------------------------------------------------------------

-- Logs inserts, deletes and the changed columns of updates made through the
-- API (as `authenticated`). Writes made inside SECURITY DEFINER RPCs (trades,
-- resolve/settle/void, set_user_data_source …) or by the service role are not
-- logged here; the admin RPCs log those themselves. The optional trigger
-- argument names an owner column: a user editing their own row is not logged.
create or replace function private.audit_admin_change()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  v_old     jsonb;
  v_new     jsonb;
  v_row     jsonb;
  v_details jsonb := '{}'::jsonb;
  v_id      uuid;
  k         text;
begin
  if current_user <> 'authenticated' then
    return null;
  end if;

  if tg_op in ('UPDATE', 'DELETE') then
    v_old := to_jsonb(old);
  end if;
  if tg_op in ('INSERT', 'UPDATE') then
    v_new := to_jsonb(new);
  end if;
  v_row := coalesce(v_new, v_old);

  if tg_nargs > 0 and v_row ->> tg_argv[0] = (select auth.uid())::text then
    return null;
  end if;

  if tg_op = 'UPDATE' then
    for k in select jsonb_object_keys(v_new) loop
      if k not in ('updated_at', 'search_vector') and v_new -> k is distinct from v_old -> k then
        v_details := v_details || jsonb_build_object(k, jsonb_build_object('from', v_old -> k, 'to', v_new -> k));
      end if;
    end loop;
    if v_details = '{}'::jsonb then
      return null;
    end if;
  else
    v_details := v_row - 'search_vector';
  end if;

  if v_row ->> 'id' ~* '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$' then
    v_id := (v_row ->> 'id')::uuid;
  end if;

  perform private.write_audit(tg_table_name || '.' || lower(tg_op), tg_table_name, v_id, v_details);
  return null;
end;
$$;

do $$
declare
  t   text;
  arg text;
begin
  for t, arg in
    select * from (values
      ('categories', null), ('topics', null), ('teams', null), ('events', null),
      ('markets', null), ('market_outcomes', null), ('market_links', null),
      ('topic_markets', null), ('shelves', null), ('shelf_items', null),
      ('banners', null), ('banks', null), ('interests', null),
      ('platform_settings', null),
      ('profiles', 'id'),        -- admin edits to someone else's profile (verified / official)
      ('posts', 'author_id')     -- admin edits to someone else's post
    ) as v(table_name, owner_column)
  loop
    execute format('drop trigger if exists audit_admin_change on public.%I', t);
    execute format(
      'create trigger audit_admin_change after insert or update or delete on public.%I
         for each row execute function private.audit_admin_change(%s)',
      t, coalesce(quote_literal(arg), ''));
  end loop;
end;
$$;


-- -----------------------------------------------------------------------------
-- 10. Function privileges
-- -----------------------------------------------------------------------------
revoke execute on function
  private.has_role(public.app_role),
  private.is_staff(),
  private.write_audit(text, text, uuid, jsonb),
  private.slugify(text),
  private.fill_slug(),
  private.categories_before_delete(),
  private.audit_admin_change()
from public, anon, authenticated;

-- Used inside RLS policies and the admin_markets view.
grant execute on function
  private.has_role(public.app_role),
  private.is_staff()
to anon, authenticated;

-- Called by the audit trigger, which runs as the API user. It only writes
-- for admins and moderators.
grant execute on function private.write_audit(text, text, uuid, jsonb) to authenticated;

revoke execute on function
  public.admin_set_role(uuid, public.app_role, boolean),
  public.moderate_post(uuid, boolean, text),
  public.admin_list_users(text, public.app_role, integer, integer),
  public.admin_overview(),
  public.admin_user_stats(integer),
  public.admin_volume_series(integer),
  public.admin_create_market(jsonb, jsonb, jsonb, uuid[], public.market_status),
  public.admin_set_topic_markets(uuid, uuid[]),
  public.admin_set_shelf_items(uuid, jsonb)
from public, anon;

-- Each of these checks the caller's role itself.
grant execute on function
  public.admin_set_role(uuid, public.app_role, boolean),
  public.moderate_post(uuid, boolean, text),
  public.admin_list_users(text, public.app_role, integer, integer),
  public.admin_overview(),
  public.admin_user_stats(integer),
  public.admin_volume_series(integer),
  public.admin_create_market(jsonb, jsonb, jsonb, uuid[], public.market_status),
  public.admin_set_topic_markets(uuid, uuid[]),
  public.admin_set_shelf_items(uuid, jsonb)
to authenticated;

-- Make the API see the new view and functions immediately.
notify pgrst, 'reload schema';
