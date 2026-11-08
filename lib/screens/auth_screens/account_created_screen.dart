import 'dart:math' as math;

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:pigeon/components/auth/auth_responsive_layout.dart';
import 'package:pigeon/components/shared/motion/fade_slide_in.dart';
import 'package:pigeon/constants/app_colors.dart';
import 'package:pigeon/constants/app_spacing.dart';
import 'package:pigeon/constants/app_strings.dart';
import 'package:pigeon/router/app_router.dart';

class AccountCreatedScreen extends StatefulWidget {
  const AccountCreatedScreen({super.key});

  @override
  State<AccountCreatedScreen> createState() => _AccountCreatedScreenState();
}

class _AccountCreatedScreenState extends State<AccountCreatedScreen> {
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
      backgroundColor: AppColors.background,
      body: AuthResponsiveLayout(
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: 4,
                left: 8,
                child: Material(
                  color: Colors.transparent,
                  child: IconButton(
                    onPressed: () {
                      final NavigatorState navigator = Navigator.of(context);
                      if (navigator.canPop()) {
                        navigator.pop();
                      } else {
                        navigator.pushNamedAndRemoveUntil(
                          AppRouter.dashboardFeed,
                          (Route<dynamic> route) => false,
                        );
                      }
                    },
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: AppColors.textPrimary,
                      size: 20,
                    ),
                    tooltip: 'Back',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: staggeredEntrance([
                    const Spacer(),
                    const _SuccessBadge(),
                    const SizedBox(height: AppSpacing.lg),
                    const Text(
                      AppStrings.accountCreated,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      AppStrings.accountCreatedSubtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 17,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const Spacer(flex: 2),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 358),
                      child: SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () =>
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                AppRouter.dashboardFeed,
                                (Route<dynamic> route) => false,
                              ),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            foregroundColor: AppColors.textPrimary,
                            minimumSize: const Size.fromHeight(50),
                            shape: const StadiumBorder(),
                            textStyle: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          child: const Text(AppStrings.getStarted),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ]),
                ),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confetti,
                  blastDirection: math.pi / 2,
                  blastDirectionality: BlastDirectionality.explosive,
                  emissionFrequency: 0.05,
                  numberOfParticles: 24,
                  minBlastForce: 12,
                  maxBlastForce: 24,
                  gravity: 0.35,
                  shouldLoop: false,
                  colors: const <Color>[
                    AppColors.accent,
                    Color(0xFFFFB800),
                    Color(0xFF19D36D),
                    Color(0xFF38D4D8),
                    Color(0xFFA26BFF),
                    Color(0xFFFF7A00),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SuccessBadge extends StatelessWidget {
  const _SuccessBadge();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 80,
        height: 80,
        decoration: const BoxDecoration(
          color: AppColors.accent,
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Icon(
            Icons.check_rounded,
            color: AppColors.textPrimary,
            size: 40,
          ),
        ),
      ),
    );
  }
}
