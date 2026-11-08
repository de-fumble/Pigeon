import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

/// Wraps all Supabase Auth operations used across the app.
/// All methods throw [AuthException] on failure — callers should catch and
/// display appropriate error messages.
class AuthService {
  AuthService._();

  static SupabaseClient get _client => SupabaseService.client;

  /// Number of digits in Supabase email and SMS OTPs (the project default).
  static const int otpLength = 6;

  /// Mirrors the `profiles_username_format` check in supabase/schema.sql
  /// (usernames are stored lowercased).
  static final RegExp usernamePattern = RegExp(r'^[A-Za-z0-9_.]{3,30}$');

  // ─────────────────────────────────────────────────────────────────────────
  // Phone numbers
  // ─────────────────────────────────────────────────────────────────────────

  /// Normalises a Nigerian phone number to E.164 (+234…), which Supabase
  /// requires. Accepts 0803…, 803…, 234803… and +234803…, with or without
  /// spaces and dashes.
  static String normalizePhone(String input) {
    final String trimmed = input.trim();
    final String digits = trimmed.replaceAll(RegExp(r'[^0-9]'), '');
    if (trimmed.startsWith('+') || digits.startsWith('234')) return '+$digits';
    if (digits.startsWith('0')) return '+234${digits.substring(1)}';
    return '+234$digits';
  }

  /// Whether a login identifier is a phone number rather than a username.
  static bool looksLikePhone(String input) {
    final String trimmed = input.trim();
    return RegExp(r'^\+?[0-9][0-9\s-]*$').hasMatch(trimmed) &&
        trimmed.replaceAll(RegExp(r'[^0-9]'), '').length >= 10;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Registration flow
  // ─────────────────────────────────────────────────────────────────────────

  /// Step 1 — register with email + password.
  /// Supabase sends a confirmation email automatically.
  /// Returns the created [User].
  static Future<AuthResponse> registerWithEmail({
    required String email,
    required String password,
    required String username,
  }) async {
    final AuthResponse response = await _client.auth.signUp(
      email: email,
      password: password,
      data: <String, dynamic>{'username': username},
    );
    return response;
  }

  /// Step 1 (alt) — register with phone + password.
  /// Supabase sends an SMS OTP automatically.
  static Future<AuthResponse> registerWithPhone({
    required String phone,
    required String password,
    required String username,
  }) async {
    final AuthResponse response = await _client.auth.signUp(
      phone: normalizePhone(phone),
      password: password,
      data: <String, dynamic>{'username': username},
    );
    return response;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // OTP verification
  // ─────────────────────────────────────────────────────────────────────────

  /// Verify an email OTP code sent during sign-up.
  static Future<AuthResponse> verifyEmailOtp({
    required String email,
    required String token,
  }) async {
    return _client.auth.verifyOTP(
      email: email,
      token: token,
      type: OtpType.signup,
    );
  }

  /// Verify a phone OTP code sent during sign-up.
  static Future<AuthResponse> verifyPhoneOtp({
    required String phone,
    required String token,
  }) async {
    return _client.auth.verifyOTP(
      phone: normalizePhone(phone),
      token: token,
      type: OtpType.sms,
    );
  }

  /// Resend OTP for email (sign-up flow).
  static Future<void> resendEmailOtp(String email) async {
    await _client.auth.resend(type: OtpType.signup, email: email);
  }

  /// Resend OTP for phone (sign-up flow).
  static Future<void> resendPhoneOtp(String phone) async {
    await _client.auth.resend(type: OtpType.sms, phone: normalizePhone(phone));
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Login — password
  // ─────────────────────────────────────────────────────────────────────────

  /// Sign in with email + password.
  static Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return _client.auth.signInWithPassword(email: email, password: password);
  }

  /// Sign in with phone + password.
  static Future<AuthResponse> signInWithPhone({
    required String phone,
    required String password,
  }) async {
    return _client.auth.signInWithPassword(
      phone: normalizePhone(phone),
      password: password,
    );
  }

  /// Sign in with username + password.
  /// Supabase doesn't natively support username login, so we resolve the
  /// email with the `get_email_for_username` RPC (emails are not readable
  /// from `profiles`), then sign in with that email.
  static Future<AuthResponse> signInWithUsername({
    required String username,
    required String password,
  }) async {
    final dynamic email = await _client.rpc(
      'get_email_for_username',
      params: <String, dynamic>{'p_username': username},
    );

    if (email is! String || email.isEmpty) {
      throw const AuthException('No account found with that username.');
    }

    return _client.auth.signInWithPassword(email: email, password: password);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Login — OTP
  // ─────────────────────────────────────────────────────────────────────────

  /// Send a login OTP to the given email.
  /// `shouldCreateUser: false` stops an unknown email from silently creating
  /// an account that skipped sign-up (no username, interests or DOB).
  static Future<void> sendLoginEmailOtp(String email) async {
    await _client.auth.signInWithOtp(email: email, shouldCreateUser: false);
  }

  /// Send a login OTP to the given phone number.
  static Future<void> sendLoginPhoneOtp(String phone) async {
    await _client.auth.signInWithOtp(
      phone: normalizePhone(phone),
      shouldCreateUser: false,
    );
  }

  /// Verify a login email OTP.
  static Future<AuthResponse> verifyLoginEmailOtp({
    required String email,
    required String token,
  }) async {
    return _client.auth.verifyOTP(
      email: email,
      token: token,
      type: OtpType.email,
    );
  }

  /// Verify a login phone OTP.
  static Future<AuthResponse> verifyLoginPhoneOtp({
    required String phone,
    required String token,
  }) async {
    return _client.auth.verifyOTP(
      phone: normalizePhone(phone),
      token: token,
      type: OtpType.sms,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Profile completion (post-OTP)
  // ─────────────────────────────────────────────────────────────────────────

  /// Save selected interests for the current user.
  static Future<void> saveInterests(List<String> interests) async {
    final String? userId = SupabaseService.currentUser?.id;
    if (userId == null) return;

    // Delete existing then re-insert
    await _client.from('user_interests').delete().eq('user_id', userId);

    if (interests.isNotEmpty) {
      await _client
          .from('user_interests')
          .insert(
            interests
                .map(
                  (String i) => <String, dynamic>{
                    'user_id': userId,
                    'category': i,
                  },
                )
                .toList(),
          );
    }
  }

  /// Save date of birth for the current user. DOB lives in the owner-only
  /// `profile_private` table (created by the sign-up trigger) and is required
  /// before the user can trade, so failures are surfaced to the caller.
  static Future<void> saveDateOfBirth(DateTime dob) async {
    final String? userId = SupabaseService.currentUser?.id;
    if (userId == null) {
      throw const AuthException(
        'Your session has expired. Please log in again.',
      );
    }

    await _client
        .from('profile_private')
        .update(<String, dynamic>{
          'dob': dob.toIso8601String().split('T').first,
        })
        .eq('id', userId);
  }

  /// The current user's date of birth, or null when signed out or not set.
  static Future<DateTime?> fetchDateOfBirth() async {
    final String? userId = SupabaseService.currentUser?.id;
    if (userId == null) return null;
    final Map<String, dynamic>? row = await _client
        .from('profile_private')
        .select('dob')
        .eq('id', userId)
        .maybeSingle();
    final Object? dob = row?['dob'];
    return dob == null ? null : DateTime.tryParse('$dob');
  }

  /// Changes the date of birth from Settings. [saveDateOfBirth] only works
  /// the first time (the column is write-once for direct writes), so this
  /// goes through the `set_date_of_birth` RPC, which re-checks the minimum
  /// age.
  static Future<void> updateDateOfBirth(DateTime dob) async {
    if (SupabaseService.currentUser == null) {
      throw const AuthException(
        'Your session has expired. Please log in again.',
      );
    }
    await _client.rpc(
      'set_date_of_birth',
      params: <String, dynamic>{
        'p_dob': dob.toIso8601String().split('T').first,
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Username availability check
  // ─────────────────────────────────────────────────────────────────────────

  /// Returns true if the username is available (not taken).
  static Future<bool> isUsernameAvailable(String username) async {
    final List<dynamic> rows = await _client
        .from('profiles')
        .select('id')
        .eq('username', username.toLowerCase().trim())
        .limit(1);
    return rows.isEmpty;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Roles
  // ─────────────────────────────────────────────────────────────────────────

  /// Whether the signed-in user has the `admin` role. RLS lets users read
  /// their own `user_roles` rows. Returns false on any error.
  static Future<bool> isAdmin() async {
    final String? userId = SupabaseService.currentUser?.id;
    if (userId == null) return false;
    try {
      final List<dynamic> rows = await _client
          .from('user_roles')
          .select('role')
          .eq('user_id', userId)
          .eq('role', 'admin')
          .limit(1);
      return rows.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Email & password
  // ─────────────────────────────────────────────────────────────────────────

  /// Starts an email change. Supabase emails a confirmation link; the
  /// address only changes once it's confirmed.
  static Future<void> updateEmail(String email) async {
    await _client.auth.updateUser(UserAttributes(email: email.trim()));
  }

  static Future<void> updatePassword(String password) async {
    if (password.length < 6) {
      throw const AuthException('Passwords need at least 6 characters.');
    }
    await _client.auth.updateUser(UserAttributes(password: password));
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Sign out
  // ─────────────────────────────────────────────────────────────────────────

  static Future<void> signOut() async {
    await _client.auth.signOut();
  }
}
