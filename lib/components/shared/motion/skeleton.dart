import 'package:flutter/material.dart';
import 'package:pigeon/constants/app_colors.dart';

/// Drives a single shimmer sweep shared by every [SkeletonBox] beneath it, so
/// all placeholders on screen pulse in sync.
class Shimmer extends StatefulWidget {
  const Shimmer({super.key, required this.child});

  final Widget child;

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _ShimmerScope(animation: _controller, child: widget.child);
  }
}

class _ShimmerScope extends InheritedWidget {
  const _ShimmerScope({required this.animation, required super.child});

  final Animation<double> animation;

  @override
  bool updateShouldNotify(_ShimmerScope oldWidget) =>
      animation != oldWidget.animation;
}

class SkeletonBox extends StatelessWidget {
  const SkeletonBox({super.key, this.width, this.height = 14, this.radius = 8});

  const SkeletonBox.circle({super.key, required double size})
    : width = size,
      height = size,
      radius = size / 2;

  final double? width;
  final double height;
  final double radius;

  static const Color _base = AppColors.surfaceMutedAlt;
  static const Color _highlight = Color(0xFF34343A);

  @override
  Widget build(BuildContext context) {
    final Animation<double>? animation = context
        .dependOnInheritedWidgetOfExactType<_ShimmerScope>()
        ?.animation;

    final Widget box = SizedBox(width: width, height: height);
    final BorderRadius borderRadius = BorderRadius.circular(radius);

    if (animation == null) {
      return DecoratedBox(
        decoration: BoxDecoration(color: _base, borderRadius: borderRadius),
        child: box,
      );
    }

    return AnimatedBuilder(
      animation: animation,
      child: box,
      builder: (BuildContext context, Widget? child) {
        // Sweep a soft highlight band from left to right across the box.
        final double t = animation.value * 3 - 1;
        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            gradient: LinearGradient(
              begin: Alignment(-1 + t, -0.3),
              end: Alignment(1 + t, 0.3),
              colors: const <Color>[_base, _highlight, _base],
              stops: const <double>[0.3, 0.5, 0.7],
            ),
          ),
          child: child,
        );
      },
    );
  }
}

/// Placeholder for a row with a leading avatar and two lines of text.
class SkeletonListTile extends StatelessWidget {
  const SkeletonListTile({
    super.key,
    this.avatarSize = 44,
    this.trailing = false,
    this.padding = const EdgeInsets.symmetric(vertical: 12),
  });

  final double avatarSize;
  final bool trailing;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: <Widget>[
          SkeletonBox.circle(size: avatarSize),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                FractionallySizedBox(
                  widthFactor: 0.7,
                  child: SkeletonBox(height: 14),
                ),
                SizedBox(height: 8),
                FractionallySizedBox(
                  widthFactor: 0.45,
                  child: SkeletonBox(height: 11),
                ),
              ],
            ),
          ),
          if (trailing) ...<Widget>[
            const SizedBox(width: 12),
            const SkeletonBox(width: 56, height: 28, radius: 14),
          ],
        ],
      ),
    );
  }
}

/// Placeholder for a rounded content card (market card, summary card, …).
class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key, this.height = 140, this.lines = 2});

  final double height;
  final int lines;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Row(
            children: <Widget>[
              SkeletonBox.circle(size: 36),
              SizedBox(width: 12),
              Expanded(child: SkeletonBox(height: 14)),
              SizedBox(width: 48),
            ],
          ),
          const Spacer(),
          for (int i = 0; i < lines; i++) ...<Widget>[
            FractionallySizedBox(
              widthFactor: i.isEven ? 0.9 : 0.6,
              child: const SkeletonBox(height: 12),
            ),
            if (i < lines - 1) const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

/// A ready-made shimmering page body: optional header block, then cards or
/// list rows. Covers most list/feed screens without bespoke skeletons.
class SkeletonPage extends StatelessWidget {
  const SkeletonPage({
    super.key,
    this.header = true,
    this.cards = 0,
    this.rows = 6,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  });

  final bool header;
  final int cards;
  final int rows;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (header) ...<Widget>[
              const SkeletonBox(width: 160, height: 22),
              const SizedBox(height: 18),
            ],
            for (int i = 0; i < cards; i++) ...<Widget>[
              const SkeletonCard(),
              const SizedBox(height: 14),
            ],
            for (int i = 0; i < rows; i++)
              const SkeletonListTile(trailing: true),
          ],
        ),
      ),
    );
  }
}
