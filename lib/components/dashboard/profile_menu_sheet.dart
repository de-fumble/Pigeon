import 'package:flutter/material.dart';
import 'package:pigeon/components/shared/motion/pressable.dart';
import 'package:pigeon/constants/app_colors.dart';

class ProfileMenuSheet extends StatelessWidget {
  const ProfileMenuSheet({
    super.key,
    required this.onShare,
    required this.onSettings,
    required this.onEditProfile,
  });

  final VoidCallback onShare;
  final VoidCallback onSettings;
  final VoidCallback onEditProfile;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Item(
            label: 'Share Profile',
            icon: Icons.open_in_new_rounded,
            onTap: onShare,
          ),
          const _Divider(),
          _Item(
            label: 'Settings',
            icon: Icons.settings_rounded,
            onTap: onSettings,
          ),
          const _Divider(),
          _Item(
            label: 'Edit Profile',
            icon: Icons.edit_rounded,
            onTap: onEditProfile,
          ),
        ],
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({required this.label, required this.icon, required this.onTap});

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
            ),
            const Spacer(),
            Icon(icon, color: AppColors.textPrimary, size: 18),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      color: AppColors.divider.withValues(alpha: 0.18),
    );
  }
}
