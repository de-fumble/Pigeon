import 'package:flutter/material.dart';
import 'package:pigeon/components/shared/motion/fade_slide_in.dart';
import 'package:pigeon/components/shared/motion/pressable.dart';
import 'package:pigeon/components/notification_detail/notification_action_sheet.dart';
import 'package:pigeon/components/notification_detail/trade_result_hero.dart';
import 'package:pigeon/components/notification_detail/trade_summary_list.dart';
import 'package:pigeon/components/onboarding/onboarding_brand_mark.dart';
import 'package:pigeon/components/shared/app_svg_icon.dart';
import 'package:pigeon/models/trade_result_notification.dart';

enum NotificationDetailKind { won, lost, bought, sold }

class NotificationDetailScreen extends StatelessWidget {
  const NotificationDetailScreen({
    super.key,
    this.notification,
    this.kind = NotificationDetailKind.won,
  });

  final TradeResultNotification? notification;
  final NotificationDetailKind kind;

  static const TradeResultNotification _defaultWon = TradeResultNotification(
    questionTitle: 'Who will be the next\nNigerian President?',
    summary: <TradeSummaryRow>[
      TradeSummaryRow(label: 'Bought', value: 'Peter Obi'),
      TradeSummaryRow(label: 'Cost', value: '₦2,300'),
      TradeSummaryRow(label: 'Won', value: '₦6,700', highlight: true),
    ],
  );

  static const TradeResultNotification _defaultLost = TradeResultNotification(
    questionTitle: 'Will rain fall in Lagos today?',
    summary: <TradeSummaryRow>[
      TradeSummaryRow(label: 'Bought', value: 'Yes'),
      TradeSummaryRow(label: 'Cost', value: '₦35,000'),
      TradeSummaryRow(label: 'Lost', value: '₦0', highlight: true),
    ],
  );

  static const TradeResultNotification _defaultBought = TradeResultNotification(
    questionTitle: 'Chelsea vs Arsenal',
    summary: <TradeSummaryRow>[
      TradeSummaryRow(label: 'Bought', value: 'Chelsea'),
      TradeSummaryRow(label: 'Cost', value: '₦12,000'),
      TradeSummaryRow(label: 'Status', value: 'Open', highlight: true),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final TradeResultNotification data =
        notification ??
        switch (kind) {
          NotificationDetailKind.won => _defaultWon,
          NotificationDetailKind.lost => _defaultLost,
          NotificationDetailKind.bought ||
          NotificationDetailKind.sold => _defaultBought,
        };

    final String headline = switch (kind) {
      NotificationDetailKind.won => 'You Won!',
      NotificationDetailKind.lost => 'You Lost',
      NotificationDetailKind.bought => 'Position Opened',
      NotificationDetailKind.sold => 'Cashed Out',
    };

    final Color backgroundColor = switch (kind) {
      NotificationDetailKind.won => const Color(0xFF1DA1F2),
      NotificationDetailKind.lost => const Color(0xFFFE542A),
      NotificationDetailKind.bought ||
      NotificationDetailKind.sold => const Color(0xFF19D36D),
    };

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(48, 90, 48, 100),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: staggeredEntrance(<Widget>[
                  Center(child: TradeResultHero(headline: headline)),
                  const SizedBox(height: 32),
                  TradeSummaryList(rows: data.summary),
                ]),
              ),
            ),
            Positioned(
              top: 8,
              right: 18,
              child: Builder(
                builder: (BuildContext context) {
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => NotificationActionSheet.show(context),
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: AppSvgIcon(
                          asset: AppIcons.notificationDetailDotButton,
                          size: 22,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              top: 60,
              left: 0,
              right: 0,
              child: const Center(child: OnboardingBrandMark()),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 32,
              child: Center(
                child: Pressable(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'Close',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
