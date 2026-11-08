import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pigeon/components/shared/app_svg_icon.dart';

class OnboardingBrandMark extends StatelessWidget {
  const OnboardingBrandMark({super.key});

  static const double _markWidth = 100;
  static const double _markHeight = 17;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _markWidth,
      height: _markHeight,
      child: SvgPicture.asset(AppIcons.pigeonWordmark, fit: BoxFit.contain),
    );
  }
}
