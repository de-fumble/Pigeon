import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:pigeon/constants/app_motion.dart';

/// Fades and lifts its child into place when first built.
///
/// Use [FadeSlideIn.staggered] for lists so items cascade in one after the
/// other. The delay is folded into the animation itself (no timers), so it
/// stays test-friendly and cancels cleanly if the widget is disposed early.
class FadeSlideIn extends StatefulWidget {
  const FadeSlideIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = AppMotion.slow,
    this.offset = 18,
  });

  FadeSlideIn.staggered({
    Key? key,
    required int index,
    required Widget child,
    Duration baseDelay = const Duration(milliseconds: 60),
    double offset = 18,
  }) : this(
         key: key,
         // Cap the cascade so long lists don't keep the user waiting.
         delay: baseDelay + AppMotion.stagger * math.min(index, 8),
         offset: offset,
         child: child,
       );

  final Widget child;
  final Duration delay;
  final Duration duration;

  /// Vertical distance, in logical pixels, the child travels while entering.
  final double offset;

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    final Duration total = widget.delay + widget.duration;
    _controller = AnimationController(vsync: this, duration: total);
    final double start = total.inMicroseconds == 0
        ? 0
        : widget.delay.inMicroseconds / total.inMicroseconds;
    _progress = CurvedAnimation(
      parent: _controller,
      curve: Interval(start, 1, curve: AppMotion.enter),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
      return widget.child;
    }
    return AnimatedBuilder(
      animation: _progress,
      child: widget.child,
      builder: (BuildContext context, Widget? child) {
        final double t = _progress.value;
        return Opacity(
          opacity: t.clamp(0, 1),
          child: Transform.translate(
            offset: Offset(0, widget.offset * (1 - t)),
            child: child,
          ),
        );
      },
    );
  }
}

/// Wraps each child in a staggered [FadeSlideIn]. Handy for the `children`
/// of a `Column` or `ListView`.
///
/// Flex and stack parent-data widgets ([Flexible]/[Expanded], [Spacer],
/// [Positioned]) stay the direct child of their parent; the animation goes
/// inside them instead.
List<Widget> staggeredEntrance(
  List<Widget> children, {
  Duration baseDelay = const Duration(milliseconds: 60),
}) {
  // Keyed by position and type, so when a slot's content changes (e.g. a tab
  // switch swaps a row for a different widget) the new content animates in.
  Widget wrap(int i, Widget child) => FadeSlideIn.staggered(
    key: ValueKey<String>('$i-${child.runtimeType}'),
    index: i,
    baseDelay: baseDelay,
    child: child,
  );

  return <Widget>[
    for (int i = 0; i < children.length; i++)
      switch (children[i]) {
        Spacer() || Positioned() => children[i],
        final Flexible f => Flexible(
          key: f.key,
          flex: f.flex,
          fit: f.fit,
          child: wrap(i, f.child),
        ),
        final Widget w => wrap(i, w),
      },
  ];
}
