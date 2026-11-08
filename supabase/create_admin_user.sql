-- =============================================================================
-- Creates (or repairs) an admin login for the Admin Panel.
-- Run once in the Supabase dashboard → SQL Editor. Safe to re-run: an existing
-- account with this email gets its password reset, email confirmed and the
-- admin role granted.
--
--   Login:    admin@pigeon.app   (or username: admin)
--   Password: IkowIIO1pzLzxpKa
--
-- Change the password after first login, and don't commit this file with a
-- real password in it.
-- =============================================================================

do $$
declare
  v_email    text := 'admin@pigeon.app';
  v_password text := 'IkowIIO1pzLzxpKa';
  v_username text := 'admin';
  v_id       uuid;
begin
  select id into v_id from auth.users where email = v_email;

  if v_id is null then
    -- The username must be free; the sign-up trigger (handle_new_user) uses it.
    if exists (select 1 from public.profiles where username = v_username) then
      v_username := 'admin_' || substr(md5(random()::text), 1, 6);
    end if;

    v_id := gen_random_uuid();

    insert into auth.users (
      instance_id, id, aud, role, email, encrypted_password,
      email_confirmed_at, raw_app_meta_data, raw_user_meta_data,
      created_at, updated_at,
      confirmation_token, email_change, email_change_token_new, recovery_token
    ) values (
      '00000000-0000-0000-0000-000000000000', v_id, 'authenticated', 'authenticated',
      v_email, extensions.crypt(v_password, extensions.gen_salt('bf')),
      now(), '{"provider":"email","providers":["email"]}',
      jsonb_build_object('username', v_username),
      now(), now(),
      '', '', '', ''
    );

    insert into auth.identities (
      id, user_id, provider_id, identity_data, provider,
      last_sign_in_at, created_at, updated_at
    ) values (
      gen_random_uuid(), v_id, v_id::text,
      jsonb_build_object('sub', v_id::text, 'email', v_email, 'email_verified', true),
      'email', now(), now(), now()
    );
  else
    update auth.users
       set encrypted_password = extensions.crypt(v_password, extensions.gen_salt('bf')),
           email_confirmed_at = coalesce(email_confirmed_at, now()),
           updated_at = now()
     where id = v_id;
  end if;

  insert into public.user_roles (user_id, role)
  values (v_id, 'admin')
  on conflict (user_id, role) do nothing;

  raise notice 'Admin ready: % (username: %, id: %)',
    v_email, (select username from public.profiles where id = v_id), v_id;
end;
$$;
