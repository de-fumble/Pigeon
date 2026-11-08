import 'package:flutter/material.dart';
import 'package:pigeon/components/auth/auth_responsive_layout.dart';
import 'package:pigeon/components/onboarding/onboarding_brand_mark.dart';
import 'package:pigeon/components/shared/app_back_button.dart';
import 'package:pigeon/components/shared/motion/fade_slide_in.dart';
import 'package:pigeon/constants/app_spacing.dart';
import 'package:pigeon/utils/context_extensions.dart';

class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.content,
    required this.bottomContent,
    this.onBack,
    this.topBanner,
    this.contentTopSpacing = 118,
  });

  final Widget content;
  final Widget bottomContent;
  final VoidCallback? onBack;
  final Widget? topBanner;
  final double contentTopSpacing;

  @override
  Widget build(BuildContext context) {
    final double horizontalPadding = context.screenWidth < 390 ? 20 : 24;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: AuthResponsiveLayout(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return Stack(
                  children: [
                    Positioned.fill(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: _bottomContentReserve),
                        child: SingleChildScrollView(
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (topBanner != null) ...<Widget>[
                                const SizedBox(height: 6),
                                FadeSlideIn(offset: -12, child: topBanner!),
                                const SizedBox(height: 8),
                              ],
                              SizedBox(height: topBanner == null ? 18 : 0),
                              SizedBox(
                                height: 44,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    if (onBack != null)
                                      AppBackButton(onPressed: onBack!),
                                    const Center(child: OnboardingBrandMark()),
                                  ],
                                ),
                              ),
                              SizedBox(height: contentTopSpacing),
                              FadeSlideIn(
                                delay: const Duration(milliseconds: 80),
                                child: content,
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: AppSpacing.lg,
                      child: FadeSlideIn(
                        delay: const Duration(milliseconds: 160),
                        child: bottomContent,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  double get _bottomContentReserve => 180;
}
