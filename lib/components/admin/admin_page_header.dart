import 'package:flutter/cupertino.dart';
import 'package:pigeon/components/shared/motion/pressable.dart';
import 'package:pigeon/constants/app_colors.dart';

/// Back chevron + title header shared by the admin sub screens.
class AdminPageHeader extends StatelessWidget {
  const AdminPageHeader({
    super.key,
    required this.title,
    this.trailing,
    this.titleLeading,
    this.onBack,
    this.compact = false,
  });

  final String title;
  final Widget? trailing;

  /// Optional widget shown between the back chevron and the title.
  final Widget? titleLeading;
  final VoidCallback? onBack;

  /// Sits 12px higher; used by the market creation flow screens.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, compact ? 0 : 10, 22, 0),
      child: SizedBox(
        height: compact ? 36 : 40,
        child: Row(
          children: [
            Pressable(
              behavior: HitTestBehavior.opaque,
              onTap: onBack ?? () => Navigator.of(context).maybePop(),
              child: const SizedBox(
                width: 30,
                height: 30,
                child: Icon(
                  CupertinoIcons.chevron_left,
                  color: AppColors.textPrimary,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 10),
            if (titleLeading != null) ...[
              titleLeading!,
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  height: 1.2,
                ),
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}
