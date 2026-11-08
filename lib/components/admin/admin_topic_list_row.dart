import 'package:flutter/cupertino.dart';
import 'package:pigeon/components/shared/motion/pressable.dart';
import 'package:pigeon/models/admin_models.dart';
import 'package:pigeon/constants/app_colors.dart';

class AdminTopicListRow extends StatelessWidget {
  const AdminTopicListRow({super.key, required this.item, required this.onTap});

  final AdminTopic item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        height: 49,
        child: Row(
          children: [
            Expanded(
              child: Text(
                item.name,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  height: 1.2,
                ),
              ),
            ),
            const Icon(
              CupertinoIcons.chevron_right,
              color: AppColors.textPrimary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
