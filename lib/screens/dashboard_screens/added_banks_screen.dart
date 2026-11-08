import 'package:flutter/material.dart';
import 'package:pigeon/components/shared/motion/pressable.dart';
import 'package:pigeon/components/shared/motion/fade_slide_in.dart';
import 'package:pigeon/components/shared/app_svg_icon.dart';
import 'package:pigeon/constants/app_colors.dart';
import 'package:pigeon/router/app_router.dart';
import 'package:pigeon/screens/dashboard_screens/direct_debits_screen.dart'
    show BankCard;

class AddedBanksScreen extends StatelessWidget {
  const AddedBanksScreen({super.key});

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
                    'Added Banks',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Pressable(
                    onTap: () => Navigator.of(
                      context,
                    ).pushNamed(AppRouter.addBankAccount),
                    child: const AppSvgIcon(
                      asset: AppIcons.addCircle,
                      size: 32,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              BankCard(
                bankName: 'United Bank for Africa',
                accountNumber: '2039611849',
                accountName: 'ATABOH HAMID CHIDE',
                onTap: () => Navigator.of(context).pushNamed(
                  AppRouter.bankDetail,
                  arguments: <String, dynamic>{'source': 'addedBanks'},
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
