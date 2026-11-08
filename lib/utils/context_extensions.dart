import 'package:flutter/widgets.dart';

extension ContextExtensions on BuildContext {
  Size get screenSize => MediaQuery.sizeOf(this);

  double get screenHeight => screenSize.height;

  double get screenWidth => screenSize.width;
}
