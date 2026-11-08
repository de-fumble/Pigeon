import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pigeon/components/shared/motion/submit_state.dart';
import 'package:pigeon/constants/app_colors.dart';
import 'package:pigeon/constants/app_motion.dart';
import 'package:pigeon/constants/app_spacing.dart';

class AppPillButton extends StatefulWidget {
  const AppPillButton({
    super.key,
    this.label,
    this.child,
    this.onPressed,
    this.isLoading = false,
  });

  static const double _maxWidth = 390;
  static const double _height = 50;

  final String? label;
  final Widget? child;
  final VoidCallback? onPressed;

  /// Swaps the label for animated dots and blocks taps while true.
  final bool isLoading;

  @override
  State<AppPillButton> createState() => _AppPillButtonState();
}

class _AppPillButtonState extends State<AppPillButton> {
  bool _pressed = false;

  bool get _enabled => widget.onPressed != null && !widget.isLoading;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: AppPillButton._maxWidth),
      child: Listener(
        onPointerDown: (_) => _setPressed(_enabled),
        onPointerUp: (_) => _setPressed(false),
        onPointerCancel: (_) => _setPressed(false),
        child: AnimatedScale(
          scale: _pressed ? 0.97 : 1,
          duration: _pressed ? AppMotion.fast : AppMotion.medium,
          curve: _pressed ? AppMotion.standard : AppMotion.spring,
          child: SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: widget.isLoading
                  // Keep the enabled styling while loading; just ignore taps.
                  ? () {}
                  : widget.onPressed == null
                  ? null
                  : () {
                      HapticFeedback.lightImpact();
                      widget.onPressed!();
                    },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.surface,
                disabledBackgroundColor: AppColors.surfaceDisabled,
                foregroundColor: AppColors.buttonText,
                disabledForegroundColor: AppColors.buttonText.withValues(
                  alpha: 0.42,
                ),
                minimumSize: const Size.fromHeight(AppPillButton._height),
                shape: const StadiumBorder(),
                elevation: 0,
                splashFactory: NoSplash.splashFactory,
                animationDuration: AppMotion.medium,
                textStyle: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.sm,
                ),
              ),
              child: ButtonLoadingContent(
                isLoading: widget.isLoading,
                child: widget.child ?? Text(widget.label ?? ''),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
