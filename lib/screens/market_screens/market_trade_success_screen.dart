import 'dart:math' as math;

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:pigeon/components/shared/motion/fade_slide_in.dart';
import 'package:pigeon/components/shared/motion/pressable.dart';
import 'package:pigeon/components/notification_detail/trade_result_hero.dart';
import 'package:pigeon/components/notification_detail/trade_summary_list.dart';
import 'package:pigeon/components/onboarding/onboarding_brand_mark.dart';
import 'package:pigeon/components/shared/app_svg_icon.dart';
import 'package:pigeon/models/trade_result_notification.dart';
import 'package:pigeon/router/app_router.dart';
import 'package:pigeon/utils/live_formatters.dart';

class MarketTradeSuccessScreen extends StatefulWidget {
  const MarketTradeSuccessScreen({
    super.key,
    required this.candidateName,
    required this.amount,
    required this.totalKobo,
    required this.toWinKobo,
  });

  final String candidateName;
  final int amount;
  final int totalKobo;
  final int toWinKobo;

  @override
  State<MarketTradeSuccessScreen> createState() =>
      _MarketTradeSuccessScreenState();
}

class _MarketTradeSuccessScreenState extends State<MarketTradeSuccessScreen> {
  late final ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 2));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _confetti.play();
    });
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1DA1F2),
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(48, 90, 48, 100),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: staggeredEntrance(<Widget>[
                  Center(child: TradeResultHero(headline: 'Successful!')),
                  const SizedBox(height: 32),
                  TradeSummaryList(
                    rows: <TradeSummaryRow>[
                      TradeSummaryRow(
                        label: 'Bought',
                        value: widget.candidateName,
                      ),
                      TradeSummaryRow(
                        label: 'Amount',
                        value: LiveFormatters.naira(
                          widget.totalKobo,
                          showKobo: true,
                        ),
                      ),
                      TradeSummaryRow(
                        label: 'To Win',
                        value: LiveFormatters.naira(
                          widget.toWinKobo,
                          showKobo: true,
                        ),
                        highlight: true,
                      ),
                    ],
                  ),
                ]),
              ),
            ),
            Positioned(
              top: 8,
              right: 18,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {},
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
                  onTap: () {
                    Navigator.of(context).popUntil(
                      (Route<dynamic> route) =>
                          route.settings.name == AppRouter.marketDetails ||
                          route.isFirst,
                    );
                  },
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
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confetti,
                blastDirection: math.pi / 2,
                blastDirectionality: BlastDirectionality.explosive,
                emissionFrequency: 0.05,
                numberOfParticles: 26,
                minBlastForce: 14,
                maxBlastForce: 26,
                gravity: 0.3,
                shouldLoop: false,
                colors: const <Color>[
                  Color(0xFFFFB800),
                  Color(0xFF19D36D),
                  Color(0xFF38D4D8),
                  Color(0xFFFF7A00),
                  Color(0xFFFF3C9D),
                  Colors.white,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
