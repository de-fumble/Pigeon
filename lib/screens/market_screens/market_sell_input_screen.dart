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

class MarketSellInputScreen extends StatefulWidget {
  const MarketSellInputScreen({
    super.key,
    required this.candidateName,
    required this.candidateInitials,
    required this.candidateColor,
    required this.pricePerShare,
    this.sharesOwned = 1100,
    this.walletBalance = 59674,
    this.optionCount = 2,
    this.outcomeId,
    this.liveShares,
  });

  final String candidateName;
  final String candidateInitials;
  final Color candidateColor;
  final int pricePerShare;

  /// Shares held in a stock position.
  final int sharesOwned;
  final int walletBalance;

  /// Options in a stock market, used to build its demo market maker.
  final int optionCount;

  /// Set for live positions: previews use the market's real state and
  /// shares are sold through the `sell_shares` RPC.
  final String? outcomeId;

  /// Shares held in the live position (fractional).
  final double? liveShares;

  @override
  State<MarketSellInputScreen> createState() => _MarketSellInputScreenState();
}

class _MarketSellInputScreenState extends State<MarketSellInputScreen> {
  String _amount = '';

  int? _liveBalanceKobo;

  /// Market maker the previews are computed with; null while a live market
  /// is loading.
  AmmMarket? _amm;
  int _ammIndex = 0;

  bool get _isLive => widget.outcomeId != null;

  double get _ownedShares =>
      _isLive ? (widget.liveShares ?? 0) : widget.sharesOwned.toDouble();

  int get _balanceKobo =>
      _isLive ? (_liveBalanceKobo ?? 0) : widget.walletBalance * 100;

  /// What selling the whole position would raise before the fee, in kobo.
  int? get _ownedValueKobo =>
      _amm?.quoteSell(_ammIndex, _ownedShares).proceedsKobo;

  /// Shares to sell so the sale raises the entered amount; the whole
  /// position when the amount covers it, so no dust is left behind.
  double get _sharesToSell {
    final AmmMarket? amm = _amm;
    final int? ownedValue = _ownedValueKobo;
    if (amm == null || ownedValue == null || _amountInt >= ownedValue ~/ 100) {
      return _ownedShares;
    }
    final double? shares = amm.sharesForProceeds(_ammIndex, _amountInt * 100);
    return shares == null ? _ownedShares : shares.clamp(0, _ownedShares);
  }

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
        minSelectedShares: _ownedShares,
      );
    }
  }

  int get _amountInt => int.tryParse(_amount) ?? 0;

  void _press(String key) {
    HapticFeedback.selectionClick();
    setState(() {
      if (key == 'back') {
        if (_amount.isNotEmpty) {
          _amount = _amount.substring(0, _amount.length - 1);
        }
        return;
      }
      if (_amount.length >= 8) return;
      _amount = _amount + key;
      if (_amount.length > 1 && _amount.startsWith('0')) {
        _amount = _amount.substring(1);
      }
    });
  }

  void _setPercent(double pct) {
    final int? ownedValue = _ownedValueKobo;
    if (ownedValue == null) return;
    setState(() {
      final int v = (ownedValue * pct).floor() ~/ 100;
      _amount = v > 0 ? v.toString() : '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool hasAmount = _amountInt > 0;
    final int? ownedValue = _ownedValueKobo;
    final bool tooMuch = ownedValue != null && _amountInt > ownedValue ~/ 100;
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
                    ? AppColors.textPrimary
                    : const Color(0xFF606060),
                fontSize: 56,
                fontWeight: FontWeight.w700,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              ownedValue == null
                  ? 'You own ₦…'
                  : 'You own ${LiveFormatters.naira(ownedValue)}',
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
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
            const SizedBox(height: 12),
            if (hasAmount)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton(
                    onPressed: tooMuch || _amm == null
                        ? null
                        : () {
                            Navigator.of(context).pushNamed(
                              AppRouter.marketSellReview,
                              arguments: <String, dynamic>{
                                'amount': _amountInt,
                                'candidateName': widget.candidateName,
                                'candidateInitials': widget.candidateInitials,
                                'candidateColor': widget.candidateColor,
                                'pricePerShare': widget.pricePerShare,
                                'shares': _sharesToSell,
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
                    child: Text(tooMuch ? 'More than you own' : 'Review'),
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
                'Sell',
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
