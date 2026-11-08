import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:pigeon/constants/app_colors.dart';

/// Three dots rising and falling in a wave; used inside buttons while an
/// action is in flight.
class LoadingDots extends StatefulWidget {
  const LoadingDots({
    super.key,
    this.color = AppColors.buttonText,
    this.size = 7,
  });

  final Color color;
  final double size;

  @override
  State<LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<LoadingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List<Widget>.generate(3, (int i) {
            final double phase = (_controller.value - i * 0.16) * 2 * math.pi;
            final double wave = (math.sin(phase) + 1) / 2;
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: widget.size * 0.4),
              child: Transform.translate(
                offset: Offset(0, -wave * widget.size * 0.6),
                child: Opacity(
                  opacity: 0.35 + 0.65 * wave,
                  child: Container(
                    width: widget.size,
                    height: widget.size,
                    decoration: BoxDecoration(
                      color: widget.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
