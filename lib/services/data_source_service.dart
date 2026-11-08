import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_service.dart';

/// Where the user dashboard gets its content from.
enum UserDataSource {
  /// The built-in demo content shipped with the app.
  stock,

  /// Real rows from the Supabase database.
  live;

  static UserDataSource parse(Object? raw) =>
      raw == 'live' ? UserDataSource.live : UserDataSource.stock;
}

/// Tracks `platform_settings.user_data_source`, which admins flip from the
/// Admin Panel. Screens listen to [current] and swap between their stock and
/// live builders, so a flip takes effect on every open client without a
/// restart.
///
/// Defaults to [UserDataSource.stock] until the setting has loaded (and
/// whenever it can't be read), so the app never shows an empty dashboard
/// because of a network problem.
class DataSourceService {
  DataSourceService._();

  static final ValueNotifier<UserDataSource> current =
      ValueNotifier<UserDataSource>(UserDataSource.stock);

  static bool get isLive => current.value == UserDataSource.live;

  static RealtimeChannel? _channel;

  static SupabaseClient get _client => SupabaseService.client;

  /// Loads the current setting and subscribes to changes. Never throws; waits
  /// at most [timeout] so a slow network doesn't hold up app start.
  static Future<void> initialize({
    Duration timeout = const Duration(seconds: 4),
  }) async {
    _subscribe();
    try {
      await refresh().timeout(timeout);
    } catch (e) {
      debugPrint('DataSourceService: using stock data ($e)');
    }
  }

  static Future<void> refresh() async {
    final Map<String, dynamic>? row = await _client
        .from('platform_settings')
        .select('user_data_source')
        .maybeSingle();
    current.value = UserDataSource.parse(row?['user_data_source']);
  }

  /// Admin only — the RPC rejects everyone else with a "42501" error.
  static Future<void> setSource(UserDataSource source) async {
    final dynamic result = await _client.rpc(
      'set_user_data_source',
      params: <String, dynamic>{'p_source': source.name},
    );
    current.value = UserDataSource.parse(result);
  }

  static void _subscribe() {
    if (_channel != null) return;
    _channel = _client
        .channel('public:platform_settings')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'platform_settings',
          callback: (PostgresChangePayload payload) {
            if (payload.newRecord.containsKey('user_data_source')) {
              current.value = UserDataSource.parse(
                payload.newRecord['user_data_source'],
              );
            }
          },
        )
        .subscribe();
  }
}
