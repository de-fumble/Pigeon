import 'package:flutter/material.dart';
import 'package:pigeon/components/shared/motion/pressable.dart';
import 'package:pigeon/constants/app_colors.dart';

class OnboardingFooter extends StatelessWidget {
  const OnboardingFooter({
    super.key,
    required this.prompt,
    required this.actionLabel,
    this.onTap,
  });

  final String prompt;
  final String actionLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    // Wraps onto two lines rather than overflowing when the text is large.
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          prompt,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
        Pressable(
          onTap: onTap,
          child: Text(
            ' $actionLabel',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.accent,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
