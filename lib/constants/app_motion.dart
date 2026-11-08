import 'package:flutter/material.dart';

/// Shared durations and curves so every transition in the app moves with the
/// same rhythm.
class AppMotion {
  const AppMotion._();

  static const Duration fast = Duration(milliseconds: 160);
  static const Duration medium = Duration(milliseconds: 280);
  static const Duration slow = Duration(milliseconds: 420);
  static const Duration page = Duration(milliseconds: 460);
  static const Duration pageReverse = Duration(milliseconds: 340);

  /// Delay between consecutive items in a staggered entrance.
  static const Duration stagger = Duration(milliseconds: 45);

  /// How long skeletons stay up for screens backed by mock data, so the
  /// loading state is seen without slowing navigation down.
  static const Duration simulatedLoad = Duration(milliseconds: 650);

  /// Processing time shown on submit buttons for actions with no backend yet.
  static const Duration simulatedSubmit = Duration(milliseconds: 900);

  static const Curve enter = Easing.emphasizedDecelerate;
  static const Curve exit = Easing.emphasizedAccelerate;
  static const Curve standard = Curves.easeOutCubic;
  static const Curve spring = Cubic(0.34, 1.36, 0.64, 1);

  static const AnimationStyle sheet = AnimationStyle(
    duration: Duration(milliseconds: 420),
    reverseDuration: Duration(milliseconds: 260),
    curve: Easing.emphasizedDecelerate,
    reverseCurve: Easing.emphasizedAccelerate,
  );
}
