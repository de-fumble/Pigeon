import 'package:flutter/material.dart';
import 'package:pigeon/components/auth/auth_responsive_layout.dart';
import 'package:pigeon/components/onboarding/onboarding_footer.dart';
import 'package:pigeon/components/onboarding/onboarding_hero_section.dart';
import 'package:pigeon/components/onboarding/onboarding_brand_mark.dart';
import 'package:pigeon/components/shared/app_pill_button.dart';
import 'package:pigeon/constants/app_colors.dart';
import 'package:pigeon/constants/app_spacing.dart';
import 'package:pigeon/constants/app_strings.dart';
import 'package:pigeon/models/onboarding_content_model.dart';
import 'package:pigeon/router/app_router.dart';
import 'package:pigeon/utils/context_extensions.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  static const OnboardingContentModel _content = OnboardingContentModel(
    headline: AppStrings.onboardingHeadline,
    primaryActionLabel: AppStrings.getStarted,
    secondaryPrompt: AppStrings.existingAccountPrompt,
    secondaryActionLabel: AppStrings.logIn,
  );

  @override
  Widget build(BuildContext context) {
    final double horizontalPadding = context.screenWidth < 390 ? 20 : 24;

    return Scaffold(
      body: AuthResponsiveLayout(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Column(
              children: [
                SizedBox(height: context.screenHeight * 0.055),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // The showcase panel beside the form already shows the eyes
                      // and the headline on laptops.
                      Builder(
                        builder: (BuildContext context) =>
                            AuthLayoutScope.isSplit(context)
                            ? const _SplitHero()
                            : OnboardingHeroSection(
                                headline: _content.headline,
                              ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      AppPillButton(
                        label: _content.primaryActionLabel,
                        onPressed: () => Navigator.of(
                          context,
                        ).pushNamed(AppRouter.contactInput),
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                        child: OnboardingFooter(
                          prompt: _content.secondaryPrompt,
                          actionLabel: _content.secondaryActionLabel,
                          onTap: () =>
                              Navigator.of(context).pushNamed(AppRouter.login),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Onboarding heading beside the showcase panel: the panel carries the
/// artwork, so this side just invites the user in.
class _SplitHero extends StatelessWidget {
  const _SplitHero();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const OnboardingBrandMark(),
        const SizedBox(height: 120),
        Text(
          'Join the flock',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: 12),
        const Text(
          'Create an account in under a minute, or log in to pick up where you left off.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 16,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}
