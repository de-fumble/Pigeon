import 'package:flutter/material.dart';
import 'package:pigeon/components/shared/account_buttons.dart';
import 'package:pigeon/constants/app_colors.dart';

class NotificationsTopBar extends StatelessWidget {
  const NotificationsTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Flexible(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const SideMenuButton(),
                  const SizedBox(width: 10),
                  const Flexible(
                    child: Text(
                      'Notifications',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 22,
                    height: 22,
                    decoration: const BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      '4',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            const AccountButton(),
          ],
        ),
      ),
    );
  }
}
