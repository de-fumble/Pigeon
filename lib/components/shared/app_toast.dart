import 'package:flutter/material.dart';
import 'package:pigeon/constants/app_colors.dart';

enum AppToastVariant { success, error }

class AppToast {
  const AppToast._();

  static void show(
    BuildContext context, {
    required String message,
    AppToastVariant variant = AppToastVariant.error,
  }) {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        content: _Bubble(message: message, variant: variant),
      ),
    );
  }
}

class AppToastInline extends StatelessWidget {
  const AppToastInline({
    super.key,
    required this.message,
    this.variant = AppToastVariant.error,
  });

  final String message;
  final AppToastVariant variant;

  @override
  Widget build(BuildContext context) {
    return _Bubble(message: message, variant: variant);
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message, required this.variant});

  static const double maxWidth = 390;
  static const double height = 44;

  final String message;
  final AppToastVariant variant;

  Color get _background => variant == AppToastVariant.success
      ? const Color(0xFF19A7E0)
      : const Color(0xFFFF2D55);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _Bubble.maxWidth),
      child: Container(
        height: _Bubble.height,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: _background,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class AppToastBanner extends StatelessWidget {
  const AppToastBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _Bubble.maxWidth),
        child: _Bubble(message: message, variant: AppToastVariant.success),
      ),
    );
  }
}
