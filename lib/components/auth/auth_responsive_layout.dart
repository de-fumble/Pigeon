import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:pigeon/components/auth/auth_showcase_panel.dart';
import 'package:pigeon/constants/app_colors.dart';
import 'package:pigeon/utils/responsive.dart';

/// Lays out an onboarding or auth page for the window size:
///
/// * Phones: [child] as designed.
/// * Tablets: [child] in a centred form-width column.
/// * Laptops (from [Breakpoints.split]): the [AuthShowcasePanel] on the left
///   and [child] in the form column on the right.
///
/// [child] is the page body exactly as it appears on a phone.
class AuthResponsiveLayout extends StatelessWidget {
  const AuthResponsiveLayout({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final Size window = MediaQuery.sizeOf(context);
    if (window.width < Breakpoints.medium) return child;

    // On tall monitors the form stays a phone-height block in the middle
    // instead of pinning its button to the bottom of the screen.
    final double height = math.min(window.height, Breakpoints.formHeight);
    final Widget form = ColoredBox(
      color: AppColors.background,
      child: Center(
        child: SizedBox(
          width: Breakpoints.form,
          height: height,
          child: PhoneWidthScope(
            width: Breakpoints.form,
            height: height,
            child: child,
          ),
        ),
      ),
    );
    if (window.width < Breakpoints.split) return form;

    return AuthLayoutScope(
      split: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const Expanded(flex: 6, child: AuthShowcasePanel()),
          Expanded(flex: 5, child: form),
        ],
      ),
    );
  }
}

/// Tells pages inside an [AuthResponsiveLayout] whether the showcase panel is
/// beside them, so they can avoid repeating its artwork.
class AuthLayoutScope extends InheritedWidget {
  const AuthLayoutScope({super.key, required this.split, required super.child});

  final bool split;

  static bool isSplit(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AuthLayoutScope>()?.split ??
      false;

  @override
  bool updateShouldNotify(AuthLayoutScope oldWidget) =>
      split != oldWidget.split;
}
