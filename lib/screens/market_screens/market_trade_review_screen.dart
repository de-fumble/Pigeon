import 'package:flutter/material.dart';
import 'package:pigeon/components/shared/app_toast.dart';
import 'package:pigeon/components/shared/data_source_builder.dart';
import 'package:pigeon/components/shared/motion/fade_slide_in.dart';
import 'package:pigeon/constants/app_colors.dart';
import 'package:pigeon/models/live_models.dart';
import 'package:pigeon/router/app_router.dart';
import 'package:pigeon/services/amm.dart';
import 'package:pigeon/services/live_data_service.dart';
import 'package:pigeon/utils/live_formatters.dart';

class MarketTradeReviewScreen extends StatefulWidget {
  const MarketTradeReviewScreen({
    super.key,
    required this.amount,
    required this.candidateName,
    required this.candidateInitials,
    required this.candidateColor,
    required this.pricePerShare,
    this.amm,
    this.ammIndex = 0,
    this.outcomeId,
  });

  final int amount;
  final String candidateName;
  final String candidateInitials;
  final Color candidateColor;
  final int pricePerShare;

  /// The market maker the input screen previewed with. Without one (stock
  /// markets opened directly) a demo market is built around [pricePerShare].
  final AmmMarket? amm;
  final int ammIndex;

  /// Set for live markets: figures come from `quote_buy` and the swipe
  /// places a real order.
  final String? outcomeId;

  @override
  State<MarketTradeReviewScreen> createState() =>
      _MarketTradeReviewScreenState();
}

class _MarketTradeReviewScreenState extends State<MarketTradeReviewScreen> {
  double _dragOffset = 0;

  /// Live quote; null for stock markets or while loading.
  LiveBuyQuote? _quote;
  bool _submitting = false;

  int get _amountKobo => widget.amount * 100;

  late final AmmMarket? _amm =
      widget.amm ??
      (widget.outcomeId == null
          ? AmmMarket.demo(price: widget.pricePerShare / 100)
          : null);

  /// On-device quote: the stock figures, and the live figures until the
  /// server's quote arrives.
  late final AmmBuyQuote? _local = _amm?.quoteBuy(widget.ammIndex, _amountKobo);

  double? get _shares => _quote?.shares ?? _local?.shares;
  int? get _feeKobo => _quote?.feeKobo ?? _local?.feeKobo;
  int? get _totalKobo => _quote?.totalKobo ?? _local?.totalKobo;
  int? get _toWinKobo => _quote?.payoutIfRightKobo ?? _local?.payoutIfRightKobo;
  int? get _avgPriceKobo {
    final double? shares = _shares;
    return shares == null || shares <= 0
        ? null
        : (_amountKobo / shares).round();
  }

  static String _money(int? kobo) =>
      kobo == null ? '₦…' : LiveFormatters.naira(kobo, showKobo: true);

  @override
  void initState() {
    super.initState();
    if (widget.outcomeId != null) _loadQuote();
  }

  Future<void> _loadQuote() async {
    try {
      final LiveBuyQuote q = await LiveDataService.quoteBuy(
        widget.outcomeId!,
        _amountKobo,
      );
      if (mounted) setState(() => _quote = q);
    } catch (e) {
      if (mounted) AppToast.show(context, message: liveErrorMessage(e));
    }
  }

  Future<void> _submitLive() async {
    final LiveBuyQuote? quote = _quote;
    if (quote == null || _submitting) {
      setState(() => _dragOffset = 0);
      return;
    }
    setState(() => _submitting = true);
    try {
      // Accept up to 2% slippage between the quote and the fill.
      await LiveDataService.buyShares(
        widget.outcomeId!,
        _amountKobo,
        minShares: quote.shares * 0.98,
      );
      if (!mounted) return;
      _openSuccess();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _dragOffset = 0;
      });
      AppToast.show(context, message: liveErrorMessage(e));
      _loadQuote();
    }
  }

  void _openSuccess() {
    Navigator.of(context).pushReplacementNamed(
      AppRouter.marketTradeSuccess,
      arguments: <String, dynamic>{
        'candidateName': widget.candidateName,
        'amount': widget.amount,
        'totalKobo': _totalKobo,
        'toWinKobo': _toWinKobo,
      },
    );
  }

  void _onDragUpdate(DragUpdateDetails d) {
    setState(() {
      _dragOffset -= d.delta.dy;
      if (_dragOffset < 0) _dragOffset = 0;
      if (_dragOffset > 120) _dragOffset = 120;
    });
  }

  void _onDragEnd(DragEndDetails _) {
    if (_dragOffset > 90) {
      if (widget.outcomeId != null) {
        _submitLive();
      } else {
        _openSuccess();
      }
    } else {
      setState(() => _dragOffset = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String feeLabel = _amm?.feeLabel ?? '2%';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onVerticalDragUpdate: _onDragUpdate,
          onVerticalDragEnd: _onDragEnd,
          child: Column(
            children: staggeredEntrance(<Widget>[
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      _TopBar(onBack: () => Navigator.of(context).pop()),
                      const SizedBox(height: 30),
                      Center(
                        child: Text(
                          '₦${_formatNumber(widget.amount)}',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 48,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 22),
                        child: Column(
                          children: <Widget>[
                            _Row(label: 'From', valueText: 'Your wallet'),
                            _Row(
                              label: 'Buying',
                              valueWidget: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Container(
                                    width: 18,
                                    height: 18,
                                    decoration: BoxDecoration(
                                      color: widget.candidateColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    widget.candidateInitials,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _Row(
                              label: 'Avg price',
                              valueText: _money(_avgPriceKobo),
                            ),
                            _Row(
                              label: 'Amount',
                              valueText: '₦${_formatNumber(widget.amount)}',
                            ),
                            _Row(
                              label: "Total you'll pay",
                              valueText: _money(_totalKobo),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 22),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              child: _PayoutColumn(
                                amount: _money(_toWinKobo),
                                label: 'Payout if Right',
                                showChevron: true,
                                alignRight: false,
                              ),
                            ),
                            const SizedBox(width: 18),
                            Expanded(
                              child: _PayoutColumn(
                                amount: _money(_feeKobo),
                                label: 'Transaction fee ($feeLabel)',
                                alignRight: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _SwipeSubmitBar(
                offset: _dragOffset,
                onDragUpdate: _onDragUpdate,
                onDragEnd: _onDragEnd,
              ),
            ]),
          ),
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
  const _TopBar({required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 6, 18, 0),
      child: Row(
        children: <Widget>[
          IconButton(
            onPressed: onBack,
            icon: const Icon(
              Icons.chevron_left_rounded,
              color: AppColors.textPrimary,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, this.valueText, this.valueWidget});
  final String label;
  final String? valueText;
  final Widget? valueWidget;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: <Widget>[
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Spacer(),
          ?valueWidget,
          ?(valueText == null
              ? null
              : Text(
                  valueText!,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                )),
        ],
      ),
    );
  }
}

class _PayoutColumn extends StatelessWidget {
  const _PayoutColumn({
    required this.amount,
    required this.label,
    this.showChevron = false,
    this.alignRight = false,
  });
  final String amount;
  final String label;
  final bool showChevron;
  final bool alignRight;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignRight
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          amount,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: alignRight
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: <Widget>[
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (showChevron) ...<Widget>[
              const SizedBox(width: 4),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.textMuted,
                size: 16,
              ),
            ] else
              const SizedBox.shrink(),
          ],
        ),
      ],
    );
  }
}

class _SwipeSubmitBar extends StatelessWidget {
  const _SwipeSubmitBar({
    required this.offset,
    required this.onDragUpdate,
    required this.onDragEnd,
  });
  final double offset;
  final void Function(DragUpdateDetails) onDragUpdate;
  final void Function(DragEndDetails) onDragEnd;

  @override
  Widget build(BuildContext context) {
    final double progress = (offset / 120).clamp(0.0, 1.0);
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1DA1F2),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
            ),
            padding: const EdgeInsets.fromLTRB(36, 18, 36, 20),
            child: const Text(
              'Review the above before confirming.\nOnce made, your transaction is irreversible.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(0, 16, 0, 28),
            width: double.infinity,
            child: Center(
              child: Text(
                progress > 0.85 ? 'Release to submit' : 'Swipe up to submit',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
