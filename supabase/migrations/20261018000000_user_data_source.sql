-- =============================================================================
-- User data pipeline switch
-- =============================================================================
-- Lets admins choose what the user-facing dashboard shows:
--   'stock' — the built-in demo content shipped with the app
--   'live'  — real rows from this database
-- The app reads platform_settings.user_data_source on start and follows
-- changes in realtime, so flipping it in the Admin Panel updates every open
-- client without a restart.
--
-- Run once in the SQL editor (or `supabase db push`) after schema.sql.
-- =============================================================================

alter table public.platform_settings
  add column if not exists user_data_source text not null default 'stock';

do $$
begin
  if not exists (
    select 1 from pg_constraint
    where conname = 'platform_settings_user_data_source_check'
      and conrelid = 'public.platform_settings'::regclass
  ) then
    alter table public.platform_settings
      add constraint platform_settings_user_data_source_check
      check (user_data_source in ('stock', 'live'));
  end if;
end;
$$;

-- Admin switch. Goes through an RPC (rather than a plain UPDATE) so every flip
-- lands in the audit log.
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

revoke execute on function public.set_user_data_source(text) from public, anon;
grant execute on function public.set_user_data_source(text) to authenticated;

-- Broadcast changes so open apps switch immediately.
do $$
begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'platform_settings'
  ) then
    alter publication supabase_realtime add table public.platform_settings;
  end if;
end;
$$;

-- Make the API see the new column and function immediately.
notify pgrst, 'reload schema';
