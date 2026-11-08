-- =============================================================================
-- Users can change their date of birth
-- =============================================================================
-- schema.sql makes profile_private.dob write-once for direct API writes (the
-- profile_private_before_write trigger keeps the old value). Settings → Edit
-- Profile lets users correct it through set_date_of_birth(), which still
-- enforces platform_settings.min_age_years (the same trigger checks it) and
-- leaves direct table writes write-once.
--
-- Run once in the SQL editor (or `supabase db push`) after schema.sql.
-- Safe to re-run.
-- =============================================================================

create or replace function public.set_date_of_birth(p_dob date)
returns date
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user uuid := auth.uid();
begin
  if v_user is null then
    raise exception 'Log in to continue.' using errcode = '42501';
  end if;
  if p_dob is null then
    raise exception 'Enter your date of birth';
  end if;
  if p_dob < date '1900-01-01' or p_dob > current_date then
    raise exception 'Enter a valid date of birth';
  end if;

  -- Runs as the function owner, so the trigger lets the change through and
  -- applies the minimum-age check.
  update public.profile_private set dob = p_dob where id = v_user;
  if not found then
    raise exception 'Profile not found';
  end if;

  return p_dob;
end;
$$;

revoke execute on function public.set_date_of_birth(date) from public, anon;
grant execute on function public.set_date_of_birth(date) to authenticated;

notify pgrst, 'reload schema';
