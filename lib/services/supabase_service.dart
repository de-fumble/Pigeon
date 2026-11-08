import 'package:supabase_flutter/supabase_flutter.dart';

/// Central access point for the Supabase client.
/// Call [SupabaseService.initialize] once in main() before runApp.
class SupabaseService {
  SupabaseService._();

  static const String _url = 'https://tunrwbvhyltydpnmdxaw.supabase.co';
  static const String _anonKey =
      'sb_publishable_LaayIOc-WeCxGQeRvD6ulA_EqOrWMcP';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: _url,
      // ignore: deprecated_member_use
      anonKey: _anonKey,
    );
  }

  /// The Supabase client singleton.
  static SupabaseClient get client => Supabase.instance.client;

  /// The currently authenticated user, or null if not signed in.
  static User? get currentUser => client.auth.currentUser;

  /// Whether a user is currently signed in.
  static bool get isSignedIn => currentUser != null;

  /// Stream of auth state changes.
  static Stream<AuthState> get authStateChanges =>
      client.auth.onAuthStateChange;
}
