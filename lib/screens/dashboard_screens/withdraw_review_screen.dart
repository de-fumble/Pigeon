import 'package:flutter/material.dart';
import 'package:pigeon/components/shared/motion/pressable.dart';
import 'package:pigeon/components/shared/motion/submit_state.dart';
import 'package:pigeon/components/shared/motion/fade_slide_in.dart';
import 'package:pigeon/constants/app_colors.dart';
import 'package:pigeon/router/app_router.dart';

class WithdrawReviewScreen extends StatelessWidget {
  const WithdrawReviewScreen({
    super.key,
    this.amount = 1000,
    this.bankName = 'United Bank For Africa',
    this.accountNumber = '2039639364',
    this.processingFee = 25,
  });

  final int amount;
  final String bankName;
  final String accountNumber;
  final int processingFee;

  String get _formattedAmount {
    final String s = amount.toString();
    final reversed = s.split('').reversed.toList();
    final withCommas = <String>[];
    for (int i = 0; i < reversed.length; i++) {
      if (i > 0 && i % 3 == 0) {
        withCommas.add(',');
      }
      withCommas.add(reversed[i]);
    }
    return withCommas.reversed.join();
  }

  String get _formattedReceive {
    final int receive = amount - processingFee;
    return _formatWithCommas(receive.toString());
  }

  String _formatWithCommas(String digits) {
    final reversed = digits.split('').reversed.toList();
    final withCommas = <String>[];
    for (int i = 0; i < reversed.length; i++) {
      if (i > 0 && i % 3 == 0) {
        withCommas.add(',');
      }
      withCommas.add(reversed[i]);
    }
    return withCommas.reversed.join();
  }

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
              Pressable(
                onTap: () => Navigator.of(context).pop(),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppColors.textPrimary,
                  size: 22,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                '-₦$_formattedAmount.00',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
              const SizedBox(height: 24),
              const _DetailRow(
                label: 'From',
                primary: 'Wallet',
                alignEnd: true,
              ),
              const SizedBox(height: 18),
              _DetailRow(
                label: 'To',
                primary: accountNumber,
                secondary: bankName,
                alignEnd: true,
              ),
              const SizedBox(height: 18),
              _DetailRow(
                label: 'Amount',
                primary: '₦$_formattedAmount.00',
                alignEnd: true,
              ),
              const SizedBox(height: 22),
              Container(
                height: 1,
                color: AppColors.divider.withValues(alpha: 0.18),
              ),
              const SizedBox(height: 14),
              Row(
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        '₦$_formattedReceive.00',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Total you\'ll receive',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        '₦$processingFee',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Processing fee',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              _ConfirmButton(amount: amount),
            ]),
          ),
        ),
      ),
    );
  }
}

class _ConfirmButton extends StatefulWidget {
  const _ConfirmButton({required this.amount});

  final int amount;

  @override
  State<_ConfirmButton> createState() => _ConfirmButtonState();
}

class _ConfirmButtonState extends State<_ConfirmButton>
    with SubmitStateMixin<_ConfirmButton> {
  void _confirm() {
    runSubmit(
      () => Navigator.of(context).pushNamed(
        AppRouter.withdrawInitiated,
        arguments: <String, dynamic>{'amount': widget.amount},
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _confirm,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.buttonText,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
        ),
        child: ButtonLoadingContent(
          isLoading: submitting,
          child: const Text(
            'Confirm',
            style: TextStyle(
              color: AppColors.buttonText,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.primary,
    this.secondary,
    this.alignEnd = false,
  });

  final String label;
  final String primary;
  final String? secondary;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    final Widget value = Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          primary,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (secondary != null) ...<Widget>[
          const SizedBox(height: 2),
          Text(
            secondary!,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ],
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
        const Spacer(),
        value,
      ],
    );
  }
}
