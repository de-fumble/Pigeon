import 'package:flutter/material.dart';
import 'package:pigeon/components/shared/motion/fade_slide_in.dart';
import 'package:pigeon/components/shared/motion/pressable.dart';
import 'package:flutter/services.dart';
import 'package:pigeon/constants/app_colors.dart';
import 'package:pigeon/models/live_models.dart';
import 'package:pigeon/router/app_router.dart';
import 'package:pigeon/services/amm.dart';
import 'package:pigeon/services/live_data_service.dart';
import 'package:pigeon/utils/live_formatters.dart';

class MarketTradeInputScreen extends StatefulWidget {
  const MarketTradeInputScreen({
    super.key,
    required this.candidateName,
    required this.candidateInitials,
    required this.candidateColor,
    required this.pricePerShare,
    this.walletBalance = 59674,
    this.optionCount = 2,
    this.outcomeId,
  });

  final String candidateName;
  final String candidateInitials;
  final Color candidateColor;
  final int pricePerShare;
  final int walletBalance;

  /// Options in a stock market, used to build its demo market maker.
  final int optionCount;

  /// Set for live markets: the balance comes from the user's wallet, previews
  /// use the market's real state, and the order goes through `buy_shares`.
  final String? outcomeId;

  @override
  State<MarketTradeInputScreen> createState() => _MarketTradeInputScreenState();
}

class _MarketTradeInputScreenState extends State<MarketTradeInputScreen> {
  String _amount = '';

  /// Live wallet balance in kobo; null until loaded.
  int? _liveBalanceKobo;

  /// Market maker the previews are computed with; null while a live market
  /// is loading.
  AmmMarket? _amm;
  int _ammIndex = 0;

  bool get _isLive => widget.outcomeId != null;

  int get _balanceKobo =>
      _isLive ? (_liveBalanceKobo ?? 0) : widget.walletBalance * 100;

  @override
  void initState() {
    super.initState();
    if (_isLive) {
      LiveDataService.fetchWallet().then((LiveWallet w) {
        if (mounted) setState(() => _liveBalanceKobo = w.cashBalanceKobo);
      }, onError: (_) {});
      LiveDataService.fetchAmmState(widget.outcomeId!).then((
        ({AmmMarket market, int index})? state,
      ) {
        if (mounted && state != null) {
          setState(() {
            _amm = state.market;
            _ammIndex = state.index;
          });
        }
      }, onError: (_) {});
    } else {
      _amm = AmmMarket.demo(
        price: widget.pricePerShare / 100,
        optionCount: widget.optionCount,
      );
    }
  }

  int get _amountInt => int.tryParse(_amount) ?? 0;

  AmmBuyQuote? get _quote => _amountInt > 0 && _amm != null
      ? _amm!.quoteBuy(_ammIndex, _amountInt * 100)
      : null;

  void _press(String key) {
    HapticFeedback.selectionClick();
    setState(() {
      if (key == 'back') {
        if (_amount.isNotEmpty) {
          _amount = _amount.substring(0, _amount.length - 1);
        }
        return;
      }
      if (_amount.length >= 6) return;
      _amount = _amount + key;
      if (_amount.length > 1 && _amount.startsWith('0')) {
        _amount = _amount.substring(1);
      }
    });
  }

  void _setPercent(double pct) {
    final AmmMarket? amm = _amm;
    if (amm == null) return;
    setState(() {
      // Leave room for the fee charged on top of the stake.
      final int v = amm.maxStakeNaira((_balanceKobo * pct).floor());
      _amount = v > 0 ? v.toString() : '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool hasAmount = _amountInt > 0;
    final AmmBuyQuote? quote = _quote;
    final bool insufficient =
        quote != null &&
        (!_isLive || _liveBalanceKobo != null) &&
        quote.totalKobo > _balanceKobo;
    final String displayAmount = hasAmount
        ? '₦${_formatNumber(_amountInt)}'
        : '₦59';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: staggeredEntrance(<Widget>[
            _TopBar(
              candidateName: widget.candidateName,
              onBack: () => Navigator.of(context).pop(),
            ),
            const Spacer(flex: 2),
            Text(
              displayAmount,
              style: TextStyle(
                color: hasAmount
                    ? const Color(0xFF1FD36B)
                    : const Color(0xFF606060),
                fontSize: 56,
                fontWeight: FontWeight.w700,
                letterSpacing: -1,
              ),
            ),
            if (hasAmount) ...<Widget>[
              const SizedBox(height: 6),
              Text(
                quote == null
                    ? 'wins ₦…'
                    : 'wins ${LiveFormatters.naira(quote.payoutIfRightKobo, showKobo: true)}',
                style: const TextStyle(
                  color: Color(0xFF1FD36B),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const Spacer(flex: 3),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: widget.candidateColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isLive && _liveBalanceKobo == null
                        ? '₦…'
                        : LiveFormatters.naira(_balanceKobo, showKobo: true),
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (insufficient) ...<Widget>[
              const SizedBox(height: 14),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 18),
                child: _InsufficientBalanceBanner(),
              ),
            ],
            const SizedBox(height: 12),
            if (hasAmount)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton(
                    onPressed: insufficient || quote == null
                        ? null
                        : () {
                            Navigator.of(context).pushNamed(
                              AppRouter.marketTradeReview,
                              arguments: <String, dynamic>{
                                'amount': _amountInt,
                                'candidateName': widget.candidateName,
                                'candidateInitials': widget.candidateInitials,
                                'candidateColor': widget.candidateColor,
                                'pricePerShare': widget.pricePerShare,
                                'amm': _amm,
                                'ammIndex': _ammIndex,
                                'outcomeId': widget.outcomeId,
                              },
                            );
                          },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.surface,
                      disabledBackgroundColor: AppColors.surfaceDisabled,
                      foregroundColor: AppColors.buttonText,
                      shape: const StadiumBorder(),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    child: const Text('Review'),
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: _PercentButton(
                        label: '25%',
                        onTap: () => _setPercent(0.25),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _PercentButton(
                        label: '50%',
                        onTap: () => _setPercent(0.5),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _PercentButton(
                        label: 'Max',
                        onTap: () => _setPercent(1.0),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 18),
            _Keypad(onPress: _press),
            const SizedBox(height: 8),
          ]),
        ),
      ),
    );
  }
}

String _formatNumber(int n) {
  final String s = n.toString();
  final StringBuffer buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return buf.toString();
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.candidateName, required this.onBack});
  final String candidateName;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 6, 18, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          IconButton(
            onPressed: onBack,
            icon: const Icon(
              Icons.chevron_left_rounded,
              color: AppColors.textPrimary,
              size: 28,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Buy',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                candidateName,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InsufficientBalanceBanner extends StatelessWidget {
  const _InsufficientBalanceBanner();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 18,
          height: 18,
          decoration: const BoxDecoration(
            color: Color(0xFFFF2D55),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.error_outline_rounded,
            color: Colors.white,
            size: 12,
          ),
        ),
        const SizedBox(width: 8),
        const Expanded(
          child: Text(
            'Insufficient balance. Fund wallet to continue activity.',
            style: TextStyle(
              color: Color(0xFFFF2D55),
              fontSize: 12,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

class _PercentButton extends StatelessWidget {
  const _PercentButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: AppColors.surfaceMutedAlt,
          borderRadius: BorderRadius.circular(25),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _Keypad extends StatelessWidget {
  const _Keypad({required this.onPress});
  final void Function(String key) onPress;

  @override
  Widget build(BuildContext context) {
    final List<List<String>> layout = <List<String>>[
      <String>['1', '2', '3'],
      <String>['4', '5', '6'],
      <String>['7', '8', '9'],
      <String>[' ', '0', 'back'],
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        children: <Widget>[
          for (final List<String> row in layout) ...<Widget>[
            const SizedBox(height: 4),
            Row(
              children: <Widget>[
                for (final String k in row) ...<Widget>[
                  Expanded(
                    child: _Key(label: k, onTap: () => onPress(k)),
                  ),
                  if (k != row.last) const SizedBox(width: 4),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Key extends StatelessWidget {
  const _Key({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (label == ' ') return const SizedBox(height: 56);
    final bool isBack = label == 'back';
    return Pressable(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 56,
        child: Center(
          child: isBack
              ? const Icon(
                  Icons.chevron_left_rounded,
                  color: AppColors.textPrimary,
                  size: 26,
                )
              : Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                  ),
                ),
        ),
      ),
    );
  }
}
