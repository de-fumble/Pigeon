import 'package:flutter/material.dart';
import 'package:pigeon/constants/app_motion.dart';
import 'package:flutter/services.dart';
import 'package:pigeon/constants/app_colors.dart';

class BankTransferSheet extends StatelessWidget {
  const BankTransferSheet({super.key});

  static const String _accountNumber = '9145702885';
  static const String _bank = 'Moniepoint MFB';
  static const String _duration = '15 minutes';
  static const String _fundingLimit = 'No limits';
  static const String _processingFee = '0%';

  Future<void> _copyDetails(BuildContext context) async {
    final String details =
        'Account number: $_accountNumber\nBank: $_bank\nDuration: $_duration\nFunding limit: $_fundingLimit\nProcessing fee: $_processingFee';
    await Clipboard.setData(ClipboardData(text: details));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Details copied to clipboard'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

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
          Center(
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFF19D36D),
                borderRadius: BorderRadius.circular(30),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.account_balance_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Center(
            child: Text(
              'Account number',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Send money to this account number to fund your wallet.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  height: 1.3,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: AppColors.backgroundSecondary,
              borderRadius: BorderRadius.circular(18),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
            child: const Column(
              children: <Widget>[
                _DetailRow(label: 'Account number:', value: _accountNumber),
                _RowDivider(),
                _DetailRow(label: 'Bank', value: _bank),
                _RowDivider(),
                _DetailRow(label: 'Duration', value: _duration),
                _RowDivider(),
                _DetailRow(label: 'Funding limit', value: _fundingLimit),
                _RowDivider(),
                _DetailRow(label: 'Processing fee', value: _processingFee),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: <Widget>[
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.surfaceDisabled,
                      foregroundColor: AppColors.textMuted,
                      disabledBackgroundColor: AppColors.surfaceDisabled,
                      disabledForegroundColor: AppColors.textMuted,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                    ),
                    child: const Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => _copyDetails(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.surface,
                      foregroundColor: AppColors.buttonText,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                    ),
                    child: const Text(
                      'Copy details',
                      style: TextStyle(
                        color: AppColors.buttonText,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: <Widget>[
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 15,
              fontWeight: FontWeight.w400,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      color: AppColors.divider.withValues(alpha: 0.18),
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

Future<void> showBankTransferSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    sheetAnimationStyle: AppMotion.sheet,
    backgroundColor: AppColors.background,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (BuildContext context) => const BankTransferSheet(),
  );
}
