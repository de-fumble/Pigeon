import 'package:flutter/material.dart';
import 'package:pigeon/constants/app_colors.dart';

/// A thumbnail for database content: shows [url] when there is one, and
/// [fallback] (an emoji or initials) when it's missing or fails to load.
class LiveThumb extends StatelessWidget {
  const LiveThumb({
    super.key,
    required this.url,
    required this.fallback,
    this.size = 44,
    this.radius,
    this.backgroundColor = AppColors.surfaceMuted,
    this.fallbackStyle,
  });

  final String? url;
  final String fallback;
  final double size;

  /// Corner radius; null makes it a circle.
  final double? radius;
  final Color backgroundColor;
  final TextStyle? fallbackStyle;

  @override
  Widget build(BuildContext context) {
    final Widget fallbackWidget = Center(
      child: Text(
        fallback,
        maxLines: 1,
        style:
            fallbackStyle ??
            TextStyle(
              color: AppColors.buttonText,
              fontSize: size * 0.4,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: radius == null ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: radius == null ? null : BorderRadius.circular(radius!),
      ),
      child: url == null
          ? fallbackWidget
          : Image.network(
              url!,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => fallbackWidget,
            ),
    );
  }
}
