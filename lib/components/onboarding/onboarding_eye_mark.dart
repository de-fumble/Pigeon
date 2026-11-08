import 'package:flutter/material.dart';
import 'package:pigeon/constants/app_colors.dart';

class OnboardingEyeMark extends StatelessWidget {
  const OnboardingEyeMark({super.key, this.width = 73, this.height = 38});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _Eye(isLeftEye: true, height: height),
          _Eye(isLeftEye: false, height: height),
        ],
      ),
    );
  }
}

class _Eye extends StatelessWidget {
  const _Eye({required this.isLeftEye, required this.height});

  final bool isLeftEye;
  final double height;

  @override
  Widget build(BuildContext context) {
    final double eyeWidth = height * (32 / 38);
    final double pupilSize = height * (12 / 38);

    return Container(
      width: eyeWidth,
      height: height,
      decoration: const BoxDecoration(
        color: AppColors.textPrimary,
        borderRadius: BorderRadius.all(Radius.elliptical(18, 20)),
      ),
      alignment: isLeftEye ? Alignment.centerRight : Alignment.centerLeft,
      padding: EdgeInsets.symmetric(horizontal: eyeWidth * (5 / 32)),
      child: Container(
        width: pupilSize,
        height: pupilSize,
        decoration: const BoxDecoration(
          color: AppColors.eyePupil,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
