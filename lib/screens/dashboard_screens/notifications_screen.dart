import 'package:flutter/material.dart';
import 'package:pigeon/components/shared/motion/fade_slide_in.dart';
import 'package:pigeon/components/dashboard/dashboard_shell.dart';
import 'package:pigeon/components/dashboard/notification_list_item.dart';
import 'package:pigeon/components/dashboard/notifications_top_bar.dart';
import 'package:pigeon/components/shared/data_source_builder.dart';
import 'package:pigeon/components/shared/live_widgets.dart';
import 'package:pigeon/constants/app_colors.dart';
import 'package:pigeon/models/live_models.dart';
import 'package:pigeon/models/trade_result_notification.dart';
import 'package:pigeon/router/app_router.dart';
import 'package:pigeon/screens/notifications_screens/notification_detail_screen.dart'
    show NotificationDetailKind;
import 'package:pigeon/services/live_data_service.dart';
import 'package:pigeon/utils/live_formatters.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  void _open(BuildContext context, String name) {
    Navigator.of(
      context,
    ).pushNamed(AppRouter.notificationDetail, arguments: name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: DashboardShell(
          activeIndex: 2,
          child: Stack(
            children: [
              DataSourceBuilder(
                live: (BuildContext context) => const _LiveNotifications(),
                stock: (BuildContext context) => ListView(
                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 126),
                  children: staggeredEntrance([
                    const NotificationsTopBar(),
                    const SizedBox(height: 26),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        'Today',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    NotificationListItem(
                      iconBackground: const Color(0xFFFF6B8F),
                      icon: Icons.rocket_launch_outlined,
                      title: '🚨 New market:',
                      subtitle: 'Will Bitcoin rise or fall today?',
                      unread: true,
                    ),
                    NotificationListItem(
                      iconBackground: const Color(0xFFFFE462),
                      icon: Icons.receipt_long_rounded,
                      title: '💰 You sold N35K Yes:',
                      subtitle: 'Will rain fall in Lagos today?',
                      unread: true,
                      iconImage: 'assets/icons/notifications/receipt-text.png',
                    ),
                    NotificationListItem(
                      iconBackground: const Color(0xFFFFE462),
                      icon: Icons.receipt_long_rounded,
                      title: '🔥 You bought N12K Chelsa:',
                      subtitle: 'Chelsea vs Arsenal',
                      unread: true,
                      iconImage: 'assets/icons/notifications/receipt-text.png',
                    ),
                    const SizedBox(height: 32),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        'This Week',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    NotificationListItem(
                      iconBackground: const Color(0xFF7FFFB3),
                      icon: Icons.emoji_events_outlined,
                      title: '🎉 You won!:',
                      subtitle: 'Will Bitcoin rise or fall today?',
                      unread: true,
                      onTap: () => _open(context, 'won'),
                      iconImage: 'assets/icons/notifications/youwon.png',
                      iconForeground:
                          'assets/icons/notifications/airplane-landing-01.png',
                      replaceBackground: true,
                    ),
                    NotificationListItem(
                      iconBackground: const Color(0xFF7FFFB3),
                      icon: Icons.emoji_events_outlined,
                      title: '💔 You lost:',
                      subtitle: 'Will rain fall in Lagos today?',
                      unread: true,
                      onTap: () => _open(context, 'lost'),
                      iconImage: 'assets/icons/notifications/youwon.png',
                      iconForeground:
                          'assets/icons/notifications/airplane-landing-01.png',
                      replaceBackground: true,
                    ),
                    NotificationListItem(
                      iconBackground: const Color(0xFFFFE462),
                      icon: Icons.receipt_long_rounded,
                      title: '🔥 You bought N9K Lakers:',
                      subtitle: 'Lakers vs Chicago Bulls',
                      iconImage: 'assets/icons/notifications/receipt-text.png',
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The signed-in user's notifications, newest first, grouped by age. New
/// ones arrive in realtime; everything shown is marked read in the background.
class _LiveNotifications extends StatefulWidget {
  const _LiveNotifications();

  @override
  State<_LiveNotifications> createState() => _LiveNotificationsState();
}

class _LiveNotificationsState extends State<_LiveNotifications> {
  final GlobalKey<LiveLoaderState<List<LiveNotification>>> _loader =
      GlobalKey<LiveLoaderState<List<LiveNotification>>>();
  RealtimeChannel? _channel;

  @override
  void initState() {
    super.initState();
    _channel = LiveDataService.watchNotifications(
      () => _loader.currentState?.reload(),
    );
  }

  @override
  void dispose() {
    final RealtimeChannel? channel = _channel;
    if (channel != null) LiveDataService.unwatch(channel);
    super.dispose();
  }

  Future<List<LiveNotification>> _load() async {
    final List<LiveNotification> items =
        await LiveDataService.fetchNotifications();
    final List<String> unread = <String>[
      for (final LiveNotification n in items)
        if (n.unread) n.id,
    ];
    // Dots stay visible for this visit; they're cleared next time.
    if (unread.isNotEmpty) {
      LiveDataService.markNotificationsRead(unread).catchError((_) {});
    }
    return items;
  }

  void _open(LiveNotification n) {
    final Map<String, dynamic> d = n.data;
    int kobo(String key) => (d[key] as num?)?.toInt() ?? 0;
    final String question = n.body ?? '';
    final (NotificationDetailKind, List<TradeSummaryRow>)? detail = switch (n
        .type) {
      'market_won' => (
        NotificationDetailKind.won,
        <TradeSummaryRow>[
          TradeSummaryRow(
            label: 'Cost',
            value: LiveFormatters.naira(kobo('cost_kobo')),
          ),
          TradeSummaryRow(
            label: 'Won',
            value: LiveFormatters.naira(kobo('won_kobo')),
            highlight: true,
          ),
        ],
      ),
      'market_lost' => (
        NotificationDetailKind.lost,
        <TradeSummaryRow>[
          TradeSummaryRow(
            label: 'Cost',
            value: LiveFormatters.naira(kobo('cost_kobo')),
          ),
          const TradeSummaryRow(label: 'Lost', value: '₦0', highlight: true),
        ],
      ),
      'trade_buy' => (
        NotificationDetailKind.bought,
        <TradeSummaryRow>[
          TradeSummaryRow(
            label: 'Cost',
            value: LiveFormatters.naira(kobo('cost_kobo')),
          ),
          TradeSummaryRow(
            label: 'Payout if right',
            value: LiveFormatters.naira(kobo('payout_if_right_kobo')),
            highlight: true,
          ),
        ],
      ),
      'trade_sell' => (
        NotificationDetailKind.sold,
        <TradeSummaryRow>[
          TradeSummaryRow(
            label: 'Received',
            value: LiveFormatters.naira(kobo('received_kobo')),
            highlight: true,
          ),
        ],
      ),
      _ => null,
    };
    if (detail != null) {
      Navigator.of(context).pushNamed(
        AppRouter.notificationDetail,
        arguments: <String, dynamic>{
          'kind': detail.$1,
          'notification': TradeResultNotification(
            questionTitle: question,
            summary: detail.$2,
          ),
        },
      );
    } else if (n.marketId != null) {
      openLiveMarket(context, n.marketId!);
    } else if (n.type.startsWith('deposit') ||
        n.type.startsWith('withdrawal')) {
      Navigator.of(context).pushNamed(AppRouter.wallet);
    }
  }

  Widget _item(LiveNotification n) {
    final String title = n.body == null ? n.title : '${n.title}:';
    void onTap() => _open(n);
    switch (n.type) {
      case 'market_won':
      case 'market_lost':
        return NotificationListItem(
          iconBackground: const Color(0xFF7FFFB3),
          icon: Icons.emoji_events_outlined,
          title: title,
          subtitle: n.body ?? '',
          unread: n.unread,
          onTap: onTap,
          iconImage: 'assets/icons/notifications/youwon.png',
          iconForeground: 'assets/icons/notifications/airplane-landing-01.png',
          replaceBackground: true,
        );
      case 'trade_buy':
      case 'trade_sell':
        return NotificationListItem(
          iconBackground: const Color(0xFFFFE462),
          icon: Icons.receipt_long_rounded,
          title: title,
          subtitle: n.body ?? '',
          unread: n.unread,
          onTap: onTap,
          iconImage: 'assets/icons/notifications/receipt-text.png',
        );
      default:
        final (Color bg, IconData icon) = switch (n.type) {
          'new_market' => (
            const Color(0xFFFF6B8F),
            Icons.rocket_launch_outlined,
          ),
          'market_voided' => (const Color(0xFFD9D9D9), Icons.undo_rounded),
          'bank_account_linked' => (
            const Color(0xFF89D1FF),
            Icons.account_balance_outlined,
          ),
          'deposit_failed' || 'withdrawal_failed' => (
            const Color(0xFFFF6B6B),
            Icons.error_outline_rounded,
          ),
          final String t
              when t.startsWith('deposit') || t.startsWith('withdrawal') =>
            (const Color(0xFF7FFFB3), Icons.account_balance_wallet_outlined),
          _ => (const Color(0xFFEFF5FF), Icons.campaign_outlined),
        };
        return NotificationListItem(
          iconBackground: bg,
          icon: icon,
          title: title,
          subtitle: n.body ?? '',
          unread: n.unread,
          onTap: onTap,
        );
    }
  }

  static String _groupFor(DateTime time, DateTime now) {
    final DateTime t = time.toLocal();
    final DateTime today = DateTime(now.year, now.month, now.day);
    if (!t.isBefore(today)) return 'Today';
    if (t.isAfter(today.subtract(const Duration(days: 7)))) return 'This Week';
    return 'Earlier';
  }

  @override
  Widget build(BuildContext context) {
    const Widget topBar = NotificationsTopBar();
    if (LiveDataService.currentUserId == null) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 126),
        children: <Widget>[
          topBar,
          const LiveSignInPrompt(message: 'Log in to see your notifications.'),
        ],
      );
    }
    return RefreshIndicator(
      onRefresh: () async => _loader.currentState?.reload(),
      color: AppColors.accent,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 126),
        children: <Widget>[
          topBar,
          const SizedBox(height: 26),
          LiveLoader<List<LiveNotification>>(
            key: _loader,
            load: _load,
            placeholder: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: LiveSkeleton(cards: 0, rows: 6),
            ),
            builder: (BuildContext context, List<LiveNotification> items, _) {
              if (items.isEmpty) {
                return const LiveEmptyState(
                  icon: Icons.notifications_none_rounded,
                  message: "You're all caught up.",
                );
              }
              final DateTime now = DateTime.now();
              final List<Widget> children = <Widget>[];
              String? group;
              for (final LiveNotification n in items) {
                final String g = _groupFor(n.createdAt, now);
                if (g != group) {
                  if (group != null) children.add(const SizedBox(height: 32));
                  children
                    ..add(
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          g,
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    )
                    ..add(const SizedBox(height: 14));
                  group = g;
                }
                children.add(_item(n));
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: staggeredEntrance(children),
              );
            },
          ),
        ],
      ),
    );
  }
}
