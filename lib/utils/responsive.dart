import 'package:flutter/widgets.dart';

/// Window size classes. Pigeon is designed phone-first; wider windows get
/// layouts built around a phone-width column instead of stretching it.
enum ScreenClass {
  /// Phones: the original layouts, untouched.
  compact,

  /// Tablets and small windows.
  medium,

  /// Laptops and desktops.
  expanded,
}

class Breakpoints {
  const Breakpoints._();

  /// Tablets start here.
  static const double medium = 600;

  /// Auth screens split into a showcase panel and the form from here.
  static const double split = 900;

  /// Laptops start here: the dashboard gets a full sidebar.
  static const double expanded = 1024;

  /// The dashboard adds its right-hand panel from here.
  static const double wide = 1280;

  /// Large monitors start here: the content column widens a little.
  static const double large = 1600;

  /// Width that phone-designed content is held to on wider windows.
  static const double column = 600;

  /// The content column for a window of [windowWidth].
  static double columnFor(double windowWidth) =>
      windowWidth >= large ? 640 : column;

  /// Width of the auth form column.
  static const double form = 440;

  /// Tallest the auth form and showcase get; taller windows centre them.
  static const double formHeight = 860;

  static ScreenClass classOf(double width) {
    if (width >= expanded) return ScreenClass.expanded;
    if (width >= medium) return ScreenClass.medium;
    return ScreenClass.compact;
  }
}

extension ResponsiveContext on BuildContext {
  ScreenClass get screenClass =>
      Breakpoints.classOf(MediaQuery.sizeOf(this).width);

  bool get isCompactScreen => screenClass == ScreenClass.compact;
}

/// Lays [child] out as if the window were [width] wide (and [height] tall,
/// when given), so phone layouts that read the screen size (paddings,
/// carousels, spacing) behave exactly as on a phone.
class PhoneWidthScope extends StatelessWidget {
  const PhoneWidthScope({
    super.key,
    required this.width,
    required this.child,
    this.height,
  });

  final double width;
  final double? height;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final MediaQueryData data = MediaQuery.of(context);
    return MediaQuery(
      data: data.copyWith(size: Size(width, height ?? data.size.height)),
      child: child,
    );
  }
}
