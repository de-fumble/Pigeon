import 'package:flutter/material.dart';
import 'package:pigeon/components/shared/motion/pressable.dart';
import 'package:pigeon/components/shared/motion/fade_slide_in.dart';
import 'package:pigeon/components/shared/app_svg_icon.dart';
import 'package:pigeon/constants/app_colors.dart';
import 'package:pigeon/router/app_router.dart';

class DirectDebitsScreen extends StatelessWidget {
  const DirectDebitsScreen({super.key});

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
                    'Direct Debits',
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
                  arguments: <String, dynamic>{'source': 'directDebits'},
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

class BankCard extends StatelessWidget {
  const BankCard({
    super.key,
    required this.bankName,
    required this.accountNumber,
    required this.accountName,
    this.onTap,
    this.showChevron = true,
  });

  final String bankName;
  final String accountNumber;
  final String accountName;
  final VoidCallback? onTap;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.backgroundSecondary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
              alignment: Alignment.center,
              child: AppSvgIcon(asset: AppIcons.uba1, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      children: <InlineSpan>[
                        TextSpan(text: bankName),
                        const TextSpan(
                          text: '  •  ',
                          style: TextStyle(color: Color(0xFFFF2D55)),
                        ),
                        TextSpan(
                          text: '${accountNumber.substring(0, 5)}...',
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    accountName,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
            ),
            if (showChevron)
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
