import 'package:flutter/material.dart';
import 'package:pigeon/components/shared/motion/pressable.dart';
import 'package:pigeon/components/shared/motion/fade_slide_in.dart';
import 'package:pigeon/components/shared/app_svg_icon.dart';
import 'package:pigeon/constants/app_colors.dart';
import 'package:pigeon/router/app_router.dart';

class WithdrawAmountScreen extends StatefulWidget {
  const WithdrawAmountScreen({
    super.key,
    this.bankName = 'United Bank for Africa',
    this.bankShortName = 'Un...',
    this.balance = 59674,
  });

  final String bankName;
  final String bankShortName;
  final int balance;

  @override
  State<WithdrawAmountScreen> createState() => _WithdrawAmountScreenState();
}

class _WithdrawAmountScreenState extends State<WithdrawAmountScreen> {
  String _digits = '';
  String? _errorMessage;

  static const int _minAmount = 200;

  int get _amount => int.tryParse(_digits.isEmpty ? '0' : _digits) ?? 0;

  bool get _canReview => _amount >= _minAmount;

  bool get _hasAmount => _digits.isNotEmpty && _digits != '0';

  void _onKeyTap(String key) {
    setState(() {
      if (key == '<') {
        if (_digits.isNotEmpty) {
          _digits = _digits.substring(0, _digits.length - 1);
        }
        _errorMessage = null;
        return;
      }
      if (key == '.') {
        return;
      }
      if (_digits == '0') {
        _digits = key;
      } else if (_digits.length < 9) {
        _digits = '$_digits$key';
      }
      if (_hasAmount && _amount < _minAmount) {
        _errorMessage =
            'You cannot withdraw less than N$_minAmount. from your wallet';
      } else {
        _errorMessage = null;
      }
    });
  }

  void _onReviewTap() {
    if (!_canReview) {
      if (_hasAmount) {
        setState(() {
          _errorMessage =
              'You cannot withdraw less than N$_minAmount. from your wallet';
        });
      }
      return;
    }
    Navigator.of(context).pushNamed(
      AppRouter.withdrawReview,
      arguments: <String, dynamic>{'amount': _amount},
    );
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
    final String display = _digits.isEmpty ? '0' : _formatWithCommas(_digits);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: staggeredEntrance(<Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: const <Widget>[
                        Text(
                          'Withdraw',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'From @dotadams wallet',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _BankPill(shortName: widget.bankShortName),
                ],
              ),
            ),
            const SizedBox(height: 32),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                child: Container(
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
                    children: <Widget>[
                      const Text(
                        'Request Failed',
                        style: TextStyle(
                          color: Color(0xFFFF2D55),
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: Color(0xFFFF6B7E),
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Center(
              child: Text(
                '₦$display',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 36,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1FD36B),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: const Text('🧔🏾', style: TextStyle(fontSize: 14)),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundSecondary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '₦${_formatBalance(widget.balance)}',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _onReviewTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _canReview
                        ? AppColors.surface
                        : AppColors.surfaceDisabled,
                    foregroundColor: _canReview
                        ? AppColors.buttonText
                        : AppColors.textMuted,
                    disabledBackgroundColor: AppColors.surfaceDisabled,
                    disabledForegroundColor: AppColors.textMuted,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  child: const Text(
                    'Review',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _NumberPad(onKeyTap: _onKeyTap),
          ]),
        ),
      ),
    );
  }

  String _formatBalance(int value) {
    return _formatWithCommas(value.toString());
  }
}

class _BankPill extends StatelessWidget {
  const _BankPill({required this.shortName});

  final String shortName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: const AppSvgIcon(asset: AppIcons.ubaLarge, size: 18),
          ),
          const SizedBox(width: 8),
          Text(
            shortName,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 6),
        ],
      ),
    );
  }
}

class _NumberPad extends StatelessWidget {
  const _NumberPad({required this.onKeyTap});

  final ValueChanged<String> onKeyTap;

  @override
  Widget build(BuildContext context) {
    final List<List<String>> rows = <List<String>>[
      <String>['1', '2', '3'],
      <String>['4', '5', '6'],
      <String>['7', '8', '9'],
      <String>['.', '0', '<'],
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
      child: Column(
        children: rows.map((List<String> row) {
          return Row(
            children: row.map((String key) {
              return Expanded(
                child: _KeyButton(value: key, onTap: () => onKeyTap(key)),
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }
}

class _KeyButton extends StatelessWidget {
  const _KeyButton({required this.value, required this.onTap});

  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool isBackspace = value == '<';
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 56,
        alignment: Alignment.center,
        child: isBackspace
            ? const Icon(
                Icons.chevron_left_rounded,
                color: AppColors.textPrimary,
                size: 26,
              )
            : Text(
                value,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                ),
              ),
      ),
    );
  }
}
