import 'package:flutter/material.dart';
import 'package:pigeon/components/onboarding/onboarding_eye_mark.dart';

class TradeResultHero extends StatelessWidget {
  const TradeResultHero({
    super.key,
    required this.headline,
    this.headlineColor = Colors.white,
  });

  final String headline;
  final Color headlineColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const OnboardingEyeMark(),
        const SizedBox(height: 28),
        Text(
          headline,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: headlineColor,
            fontSize: 36,
            fontWeight: FontWeight.w800,
            height: 1.1,
          ),
        ),
      ],
    );
  }
}
