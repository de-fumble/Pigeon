import 'package:flutter/material.dart';
import 'package:pigeon/constants/app_motion.dart';
import 'package:pigeon/components/shared/app_svg_icon.dart';
import 'package:pigeon/constants/app_colors.dart';
import 'package:pigeon/router/app_router.dart';
import 'package:pigeon/screens/dashboard_screens/direct_debits_screen.dart'
    show BankCard;

class SelectBankAccountSheet extends StatelessWidget {
  const SelectBankAccountSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const _SheetGrabber(),
          const SizedBox(height: 18),
          const Center(
            child: Text(
              'Select bank account',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 20),
          BankCard(
            bankName: 'United Bank for Africa',
            accountNumber: '2039039364',
            accountName: 'ATABOH HAMID CHIDE',
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed(AppRouter.directDeposit);
            },
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed(AppRouter.addBankAccount);
            },
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
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    alignment: Alignment.center,
                    child: const AppSvgIcon(asset: AppIcons.add01, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: const <Widget>[
                        Text(
                          'Add bank account',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Add bank details',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetGrabber extends StatelessWidget {
  const _SheetGrabber();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.surfaceDisabled,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

Future<void> showSelectBankAccountSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    sheetAnimationStyle: AppMotion.sheet,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (BuildContext context) => const SelectBankAccountSheet(),
  );
}
