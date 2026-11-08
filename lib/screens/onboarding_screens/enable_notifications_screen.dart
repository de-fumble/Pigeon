import 'package:flutter/material.dart';
import 'package:pigeon/components/auth/auth_responsive_layout.dart';
import 'package:pigeon/components/shared/motion/fade_slide_in.dart';
import 'package:pigeon/components/onboarding/onboarding_eye_mark.dart';
import 'package:pigeon/constants/app_colors.dart';
import 'package:pigeon/router/app_router.dart';

class EnableNotificationsScreen extends StatelessWidget {
  const EnableNotificationsScreen({super.key});

  static const double _buttonMaxWidth = 358;
  static const double _buttonHeight = 50;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AuthResponsiveLayout(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: staggeredEntrance([
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: AppColors.accent,
                      size: 26,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: OnboardingEyeMark(),
                ),
                const SizedBox(height: 28),
                const Text(
                  'Enable Notifications',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    height: 1.12,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Stay informed with the latest\nupdates, event details, and critical\nannouncements from Pigeon Arena.',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 28),
                const _BenefitRow(
                  icon: Icons.notifications_active_rounded,
                  iconColor: AppColors.accent,
                  title: 'Timely Alerts',
                  body:
                      'Get instant alerts for new events, discussions, and markets updates.',
                ),
                const SizedBox(height: 22),
                const _BenefitRow(
                  icon: Icons.event_available_rounded,
                  iconColor: AppColors.accent,
                  title: 'Live Event Updates',
                  body:
                      'Never miss crucial shifts in chances or the start of live games and events.',
                ),
                const SizedBox(height: 22),
                const _BenefitRow(
                  icon: Icons.campaign_rounded,
                  iconColor: AppColors.accent,
                  title: 'Critical Communications',
                  body:
                      'Receive instant notifications for your position changes and final market payouts.',
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        color: AppColors.accent,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Your information will be used by Pigeon Arena to facilitate '
                          'market transactions, improve social feed, send you '
                          'market-related communications, and improve the '
                          'prediction algorithm. You can always change this later '
                          'from within the app settings.',
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: _buttonMaxWidth,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            AppRouter.dashboardFeed,
                            (Route<dynamic> route) => false,
                          );
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: AppColors.textPrimary,
                          minimumSize: const Size.fromHeight(_buttonHeight),
                          shape: const StadiumBorder(),
                          textStyle: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: const Text('Allow notifications'),
                      ),
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                body,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
