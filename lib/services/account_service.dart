import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/live_models.dart';
import 'auth_service.dart';
import 'live_data_service.dart';
import 'supabase_service.dart';

/// The signed-in user's own account: profile, contact details, date of birth
/// and role.
class AccountState {
  const AccountState({
    required this.profile,
    required this.isAdmin,
    this.email,
    this.phone,
    this.dateOfBirth,
  });

  final LiveProfile profile;
  final bool isAdmin;
  final String? email;
  final String? phone;
  final DateTime? dateOfBirth;

  String get handle => profile.handle;

  /// Email if there is one, otherwise phone.
  String? get contact => email ?? phone;
}

/// Delivery channels from Settings → Notifications (`notification_preferences`).
typedef NotificationPrefs = ({bool push, bool sms, bool email});

/// Single source of truth for the signed-in user's account. The side menu,
/// avatar buttons and the Account screen all listen to [current], which
/// reloads whenever the auth state changes.
///
/// A user's own account always comes from the database, whatever the
/// dashboard data source is set to; only other users' content follows it.
class AccountService {
  AccountService._();

  static SupabaseClient get _client => SupabaseService.client;

  /// Null while signed out (or before the first load finishes).
  static final ValueNotifier<AccountState?> current =
      ValueNotifier<AccountState?>(null);

  static StreamSubscription<AuthState>? _authSub;

  /// Loads the account if someone is signed in and follows sign-in /
  /// sign-out from then on. Never throws.
  static Future<void> initialize() async {
    _authSub ??= SupabaseService.authStateChanges.listen((AuthState state) {
      if (state.event == AuthChangeEvent.signedOut) {
        current.value = null;
      } else if (state.event == AuthChangeEvent.signedIn ||
          state.event == AuthChangeEvent.userUpdated) {
        refresh().catchError((Object e) {
          debugPrint('AccountService: $e');
        });
      }
    });
    try {
      await refresh();
    } catch (e) {
      debugPrint('AccountService: $e');
    }
  }

  /// Reloads [current] from the database.
  static Future<void> refresh() async {
    final User? user = SupabaseService.currentUser;
    if (user == null) {
      current.value = null;
      return;
    }
    final (LiveProfile? profile, DateTime? dob, bool isAdmin) = await (
      LiveDataService.fetchProfile(user.id),
      AuthService.fetchDateOfBirth(),
      AuthService.isAdmin(),
    ).wait;
    if (profile == null || SupabaseService.currentUser?.id != user.id) return;
    current.value = AccountState(
      profile: profile,
      isAdmin: isAdmin,
      email: _nonEmpty(user.email),
      phone: _nonEmpty(user.phone),
      dateOfBirth: dob,
    );
  }

  static String? _nonEmpty(String? s) => s == null || s.isEmpty ? null : s;

  static String _requireUserId() {
    final String? id = SupabaseService.currentUser?.id;
    if (id == null) {
      throw const AuthException(
        'Your session has expired. Please log in again.',
      );
    }
    return id;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Profile
  // ─────────────────────────────────────────────────────────────────────────

  /// Usernames are stored lowercased; a taken name fails with the database's
  /// unique-constraint error, reworded here.
  static Future<void> updateUsername(String username) async {
    final String value = username.trim().toLowerCase();
    if (!AuthService.usernamePattern.hasMatch(value)) {
      throw const AuthException(
        'Usernames are 3–30 letters, numbers, dots or underscores.',
      );
    }
    try {
      await _client
          .from('profiles')
          .update(<String, dynamic>{'username': value})
          .eq('id', _requireUserId());
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        throw const AuthException('That username is taken.');
      }
      rethrow;
    }
    await refresh();
  }

  static Future<void> updateBio(String bio) async {
    final String value = bio.trim();
    await _client
        .from('profiles')
        .update(<String, dynamic>{'bio': value.isEmpty ? null : value})
        .eq('id', _requireUserId());
    await refresh();
  }

  static Future<void> updateDateOfBirth(DateTime dob) async {
    await AuthService.updateDateOfBirth(dob);
    await refresh();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Notification preferences
  // ─────────────────────────────────────────────────────────────────────────

  static Future<NotificationPrefs> fetchNotificationPrefs() async {
    final Map<String, dynamic>? row = await _client
        .from('notification_preferences')
        .select('push_enabled, sms_enabled, email_enabled')
        .eq('user_id', _requireUserId())
        .maybeSingle();
    return (
      push: row?['push_enabled'] != false,
      sms: row?['sms_enabled'] != false,
      email: row?['email_enabled'] != false,
    );
  }

  static Future<void> updateNotificationPrefs(NotificationPrefs prefs) async {
    await _client
        .from('notification_preferences')
        .update(<String, dynamic>{
          'push_enabled': prefs.push,
          'sms_enabled': prefs.sms,
          'email_enabled': prefs.email,
        })
        .eq('user_id', _requireUserId());
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Account
  // ─────────────────────────────────────────────────────────────────────────

  /// Flags the account for deletion. The database refuses while the wallet
  /// has money or positions are open, and says which.
  static Future<void> requestDeletion() async {
    await _client.rpc('request_account_deletion');
  }
}
