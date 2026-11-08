import 'package:flutter/material.dart';
import 'package:pigeon/components/shared/motion/pressable.dart';
import 'package:pigeon/components/shared/motion/submit_state.dart';
import 'package:pigeon/components/shared/motion/fade_slide_in.dart';
import 'package:pigeon/constants/app_colors.dart';
import 'package:pigeon/router/app_router.dart';

class DirectDepositReviewScreen extends StatefulWidget {
  const DirectDepositReviewScreen({
    super.key,
    this.amount = 1000,
    this.bankName = 'United Bank For Africa',
    this.accountNumber = '2039039364',
  });

  final int amount;
  final String bankName;
  final String accountNumber;

  @override
  State<DirectDepositReviewScreen> createState() =>
      _DirectDepositReviewScreenState();
}

class _DirectDepositReviewScreenState extends State<DirectDepositReviewScreen>
    with SubmitStateMixin<DirectDepositReviewScreen> {
  bool _showError = false;

  String get _formattedAmount {
    final String s = widget.amount.toString();
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

  void _onFundTap() {
    runSubmit(() {
      setState(() {
        _showError = !_showError;
      });
      if (!_showError) {
        Navigator.of(context).pushNamed(AppRouter.directDepositPending);
      }
    });
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
              const SizedBox(height: 22),
              Text(
                '+₦$_formattedAmount.00',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 22),
              _DetailRow(
                label: 'From',
                primary: widget.accountNumber,
                secondary: widget.bankName,
                alignEnd: true,
              ),
              const SizedBox(height: 18),
              const _DetailRow(label: 'To', primary: 'Wallet', alignEnd: true),
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
                    children: const <Widget>[
                      Text(
                        'Total you\'ll pay',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '₦0.00',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: const <Widget>[
                      Text(
                        'Processing fee',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '₦0.00',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (_showError) ...<Widget>[
                const Spacer(),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3A0A0A),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: const <Widget>[
                      Text(
                        'Request Failed',
                        style: TextStyle(
                          color: Color(0xFFFF2D55),
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Unable to fund wallet.',
                        style: TextStyle(
                          color: Color(0xFFFF6B7E),
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
              ] else
                const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _onFundTap,
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
                      'Fund',
                      style: TextStyle(
                        color: AppColors.buttonText,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ]),
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
