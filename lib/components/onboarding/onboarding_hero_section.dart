import 'package:flutter/material.dart';
import 'package:pigeon/components/onboarding/onboarding_brand_mark.dart';
import 'package:pigeon/components/onboarding/onboarding_eye_mark.dart';
import 'package:pigeon/constants/app_spacing.dart';

class OnboardingHeroSection extends StatelessWidget {
  const OnboardingHeroSection({super.key, required this.headline});

  final String headline;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const OnboardingBrandMark(),
        const SizedBox(height: 168),
        const OnboardingEyeMark(),
        const SizedBox(height: AppSpacing.xxxl),
        Text(
          headline,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineLarge,
        ),
      ],
    );
  }
}
