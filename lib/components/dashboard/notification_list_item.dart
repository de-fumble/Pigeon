import 'package:flutter/material.dart';
import 'package:pigeon/constants/app_colors.dart';

class NotificationListItem extends StatelessWidget {
  const NotificationListItem({
    super.key,
    required this.iconBackground,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.unread = false,
    this.onTap,
    this.iconImage,
    this.iconForeground,
    this.replaceBackground = false,
  }) : assert(
         !replaceBackground || iconImage != null,
         'replaceBackground requires iconImage to be set',
       );

  final Color iconBackground;
  final IconData icon;
  final String title;
  final String subtitle;
  final bool unread;
  final VoidCallback? onTap;
  final String? iconImage;
  final String? iconForeground;
  final bool replaceBackground;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 18, 16, 18),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Color(0xFF2A2A2A), width: 1),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(14),
                  image: replaceBackground
                      ? DecorationImage(
                          image: AssetImage(iconImage!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                alignment: Alignment.center,
                child: replaceBackground && iconForeground != null
                    ? Image.asset(
                        iconForeground!,
                        width: 22,
                        height: 22,
                        fit: BoxFit.contain,
                      )
                    : iconImage != null && !replaceBackground
                    ? Image.asset(
                        iconImage!,
                        width: 26,
                        height: 26,
                        fit: BoxFit.contain,
                      )
                    : Icon(icon, color: AppColors.buttonText, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: title,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              height: 1.25,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              if (unread)
                Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                )
              else
                const SizedBox(width: 10),
            ],
          ),
        ),
      ),
    );
  }
}
