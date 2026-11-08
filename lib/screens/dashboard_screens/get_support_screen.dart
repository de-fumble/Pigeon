import 'package:flutter/material.dart';
import 'package:pigeon/components/shared/motion/pressable.dart';
import 'package:pigeon/components/shared/motion/fade_slide_in.dart';
import 'package:pigeon/constants/app_colors.dart';

class GetSupportScreen extends StatelessWidget {
  const GetSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: staggeredEntrance(<Widget>[
              Row(
                children: <Widget>[
                  Pressable(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: AppColors.textPrimary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Get Support',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const _SupportRow(
                leadingIcon: Icons.mail_outline_rounded,
                label: 'support@pigeonarena.com',
              ),
              const SizedBox(height: 12),
              const _SupportRow(
                leadingIcon: Icons.chat_bubble_outline_rounded,
                label: 'Reach out to us on WhatsApp',
              ),
              const SizedBox(height: 12),
              const _SupportRow(
                leadingIcon: Icons.support_agent_rounded,
                label: 'Chat with Customer Service',
              ),
              const SizedBox(height: 12),
              const _SupportRow(
                leadingIcon: Icons.phone_in_talk_outlined,
                label: 'Contact us via Phone',
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

class _SupportRow extends StatelessWidget {
  const _SupportRow({required this.leadingIcon, required this.label});

  final IconData leadingIcon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.backgroundSecondary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: <Widget>[
            Icon(leadingIcon, color: const Color(0xFFFF2D55), size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textPrimary,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
