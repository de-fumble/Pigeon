import 'package:flutter/material.dart';
import 'package:pigeon/components/shared/motion/fade_slide_in.dart';
import 'package:pigeon/components/dashboard/market_position_action_buttons.dart';
import 'package:pigeon/components/dashboard/market_position_stats_card.dart';
import 'package:pigeon/components/dashboard/market_position_top_bar.dart';
import 'package:pigeon/components/shared/live_widgets.dart';
import 'package:pigeon/constants/app_colors.dart';
import 'package:pigeon/router/app_router.dart';
import 'package:pigeon/utils/live_formatters.dart';

class MarketPositionScreen extends StatelessWidget {
  const MarketPositionScreen({
    super.key,
    required this.title,
    required this.position,
    required this.avatar,
    required this.avatarColor,
    required this.chance,
    required this.cost,
    required this.value,
    required this.change,
    required this.payout,
    this.changeColor,
    this.marketId,
    this.outcomeId,
    this.shares,
    this.pricePerShare,
    this.tradable = false,
  });

  final String title;
  final String position;
  final String avatar;
  final Color avatarColor;
  final String chance;
  final String cost;
  final String value;
  final String change;
  final String payout;
  final Color? changeColor;

  // Live positions only.
  final String? marketId;
  final String? outcomeId;
  final double? shares;
  final int? pricePerShare;
  final bool tradable;

  bool get _isLive => outcomeId != null;

  void _trade(BuildContext context, String route) {
    Navigator.of(context).pushNamed(
      route,
      arguments: <String, dynamic>{
        'candidateName': position,
        'candidateInitials': LiveFormatters.initials(position),
        'candidateColor': avatarColor,
        // Stock positions only carry the displayed chance ("52%").
        'pricePerShare':
            pricePerShare ?? int.tryParse(chance.replaceAll('%', '')) ?? 50,
        'outcomeId': outcomeId,
        'liveShares': shares,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 126),
              children: staggeredEntrance([
                MarketPositionTopBar(onBack: () => Navigator.of(context).pop()),
                const SizedBox(height: 44),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 21,
                      backgroundColor: avatarColor,
                      child: Text(avatar, style: const TextStyle(fontSize: 18)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          height: 1.1,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                const Text(
                  'Your position',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  position,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: marketId == null
                        ? () {}
                        : () => openLiveMarket(context, marketId!),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.backgroundSecondary,
                      foregroundColor: AppColors.textPrimary,
                      minimumSize: const Size.fromHeight(42),
                      shape: const StadiumBorder(),
                      textStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    child: const Text('View Market'),
                  ),
                ),
                const SizedBox(height: 20),
                MarketPositionStatsCard(
                  chance: chance,
                  cost: cost,
                  value: value,
                  change: change,
                  payout: payout,
                  changeColor: changeColor,
                ),
              ]),
            ),
            Positioned(
              left: 18,
              right: 18,
              bottom: 18,
              child: MarketPositionActionButtons(
                onCashOut: _isLive && tradable
                    ? () => _trade(context, AppRouter.marketSellInput)
                    : () {},
                onBuy: _isLive && tradable
                    ? () => _trade(context, AppRouter.marketTradeInput)
                    : () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
