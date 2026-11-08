import 'package:flutter/material.dart';
import 'package:pigeon/constants/app_colors.dart';
import 'package:pigeon/constants/app_motion.dart';

class AdminUsersTotalCard extends StatelessWidget {
  const AdminUsersTotalCard({
    super.key,
    required this.totalUsers,
    this.label = 'Total Users',
  });

  final String totalUsers;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 0),
      decoration: BoxDecoration(
        color: const Color(0xFF222222),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFB0B0B0),
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 1),
          // Roll the figure vertically when a filter changes it.
          AnimatedSwitcher(
            duration: AppMotion.medium,
            switchInCurve: AppMotion.enter,
            switchOutCurve: AppMotion.exit,
            layoutBuilder: (Widget? current, List<Widget> previous) => Stack(
              alignment: Alignment.centerLeft,
              children: <Widget>[...previous, ?current],
            ),
            transitionBuilder: (Widget child, Animation<double> animation) {
              final bool incoming = child.key == ValueKey<String>(totalUsers);
              return ClipRect(
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: Offset(0, incoming ? 0.6 : -0.6),
                    end: Offset.zero,
                  ).animate(animation),
                  child: FadeTransition(opacity: animation, child: child),
                ),
              );
            },
            child: Text(
              totalUsers,
              key: ValueKey<String>(totalUsers),
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w500,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
