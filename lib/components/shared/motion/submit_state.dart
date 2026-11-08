import 'package:flutter/material.dart';
import 'package:pigeon/components/shared/motion/loading_dots.dart';
import 'package:pigeon/constants/app_colors.dart';
import 'package:pigeon/constants/app_motion.dart';

/// Tracks an in-flight submit for a screen's primary button.
///
/// [runSubmit] ignores repeat taps, shows the loading state for at least
/// [AppMotion.simulatedSubmit] (mock flows have no real request yet), then
/// runs [onDone] if the screen is still mounted.
mixin SubmitStateMixin<T extends StatefulWidget> on State<T> {
  bool submitting = false;

  Future<void> runSubmit(VoidCallback onDone, {Future<void>? request}) async {
    if (submitting) return;
    setState(() => submitting = true);
    await Future.wait(<Future<void>>[
      Future<void>.delayed(AppMotion.simulatedSubmit),
      ?request,
    ]);
    if (!mounted) return;
    setState(() => submitting = false);
    onDone();
  }
}

/// Cross-fades a button's label into [LoadingDots] while [isLoading].
class ButtonLoadingContent extends StatelessWidget {
  const ButtonLoadingContent({
    super.key,
    required this.isLoading,
    required this.child,
    this.dotsColor = AppColors.buttonText,
  });

  final bool isLoading;
  final Widget child;
  final Color dotsColor;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: AppMotion.medium,
      switchInCurve: AppMotion.enter,
      switchOutCurve: AppMotion.exit,
      transitionBuilder: (Widget child, Animation<double> animation) =>
          FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.85, end: 1).animate(animation),
              child: child,
            ),
          ),
      child: isLoading
          ? LoadingDots(
              key: const ValueKey<String>('loading'),
              color: dotsColor,
            )
          : KeyedSubtree(key: const ValueKey<String>('label'), child: child),
    );
  }
}
