import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pigeon/constants/app_motion.dart';

/// Gives any tappable surface a tactile press: it sinks slightly while held
/// and springs back on release, with a light haptic tick on tap.
class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.pressedScale = 0.97,
    this.haptic = true,
    this.behavior = HitTestBehavior.deferToChild,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double pressedScale;
  final bool haptic;
  final HitTestBehavior behavior;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _pressed = false;

  bool get _enabled => widget.onTap != null || widget.onLongPress != null;

  void _setPressed(bool value) {
    if (_pressed == value || !_enabled) return;
    setState(() => _pressed = value);
  }

  void _handleTap() {
    if (widget.haptic) HapticFeedback.selectionClick();
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: widget.behavior,
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onTap: widget.onTap == null ? null : _handleTap,
      onLongPress: widget.onLongPress,
      child: AnimatedScale(
        scale: _pressed ? widget.pressedScale : 1,
        duration: _pressed ? AppMotion.fast : AppMotion.medium,
        curve: _pressed ? AppMotion.standard : AppMotion.spring,
        child: AnimatedOpacity(
          opacity: _pressed ? 0.85 : 1,
          duration: AppMotion.fast,
          child: widget.child,
        ),
      ),
    );
  }
}
