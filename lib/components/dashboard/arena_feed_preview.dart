import 'package:flutter/material.dart';
import 'package:pigeon/components/shared/app_svg_icon.dart';
import 'package:pigeon/constants/app_colors.dart';

class ArenaFeedPreview extends StatelessWidget {
  const ArenaFeedPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: const [
        Row(
          children: [
            SizedBox(
              width: 32,
              height: 32,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Color(0xFFFF1C2D),
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                child: Padding(
                  padding: EdgeInsets.all(7),
                  child: AppSvgIcon(
                    asset: AppIcons.pigeonUniverse,
                    size: 18,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ),
            ),
            SizedBox(width: 10),
            Text(
              '@PigeonUniverse',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(width: 6),
            Text(
              '• 6h',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            Spacer(),
            Icon(
              Icons.more_horiz_rounded,
              color: AppColors.textMuted,
              size: 22,
            ),
          ],
        ),
        SizedBox(height: 10),
        Text(
          'Optimism resides where the people believe it resides.',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            height: 1.3,
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Icon(
              Icons.mode_comment_outlined,
              size: 20,
              color: AppColors.textMuted,
            ),
            SizedBox(width: 8),
            Text(
              '900',
              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
            SizedBox(width: 14),
            Icon(Icons.edit_outlined, size: 20, color: AppColors.textMuted),
            SizedBox(width: 8),
            Text(
              '406',
              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
            SizedBox(width: 14),
            Text('👀', style: TextStyle(fontSize: 18)),
            SizedBox(width: 4),
            Text(
              '54',
              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
            SizedBox(width: 12),
            Text('👌', style: TextStyle(fontSize: 18)),
            SizedBox(width: 4),
            Text(
              '93',
              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
          ],
        ),
      ],
    );
  }
}
