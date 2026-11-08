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

class MarketSellReviewScreen extends StatefulWidget {
  const MarketSellReviewScreen({
    super.key,
    required this.amount,
    required this.candidateName,
    required this.candidateInitials,
    required this.candidateColor,
    required this.pricePerShare,
    this.shares,
    this.amm,
    this.ammIndex = 0,
    this.outcomeId,
  });

  final int amount;
  final String candidateName;
  final String candidateInitials;
  final Color candidateColor;
  final int pricePerShare;

  /// Shares being sold. Without them (stock markets opened directly) the
  /// shares that raise [amount] are worked out from the market maker.
  final double? shares;

  /// The market maker the input screen previewed with; a demo market around
  /// [pricePerShare] when missing.
  final AmmMarket? amm;
  final int ammIndex;

  /// Set for live positions: figures come from `quote_sell` and the swipe
  /// sells [shares] for real.
  final String? outcomeId;

  @override
  State<MarketSellReviewScreen> createState() => _MarketSellReviewScreenState();
}

class _MarketSellReviewScreenState extends State<MarketSellReviewScreen> {
  double _dragOffset = 0;

  LiveSellQuote? _quote;
  bool _submitting = false;

  bool get _isLive => widget.outcomeId != null && widget.shares != null;

  late final AmmMarket? _amm =
      widget.amm ??
      (widget.outcomeId == null
          ? AmmMarket.demo(price: widget.pricePerShare / 100)
          : null);

  late final double? _shares =
      widget.shares ??
      _amm?.sharesForProceeds(widget.ammIndex, widget.amount * 100);

  /// On-device quote: the stock figures, and the live figures until the
  /// server's quote arrives.
  late final AmmSellQuote? _local = _shares == null
      ? null
      : _amm?.quoteSell(widget.ammIndex, _shares);

  int? get _proceedsKobo => _quote?.proceedsKobo ?? _local?.proceedsKobo;
  int? get _feeKobo => _quote?.feeKobo ?? _local?.feeKobo;
  int? get _netKobo => _quote?.netKobo ?? _local?.netKobo;
  int? get _avgPriceKobo {
    final double? shares = _shares;
    final int? proceeds = _proceedsKobo;
    return shares == null || shares <= 0 || proceeds == null
        ? null
        : (proceeds / shares).round();
  }

  static String _money(int? kobo) =>
      kobo == null ? '₦…' : LiveFormatters.naira(kobo, showKobo: true);

  @override
  void initState() {
    super.initState();
    if (_isLive) _loadQuote();
  }

  Future<void> _loadQuote() async {
    try {
      final LiveSellQuote q = await LiveDataService.quoteSell(
        widget.outcomeId!,
        widget.shares!,
      );
      if (mounted) setState(() => _quote = q);
    } catch (e) {
      if (mounted) AppToast.show(context, message: liveErrorMessage(e));
    }
  }

  Future<void> _submitLive() async {
    final LiveSellQuote? quote = _quote;
    if (quote == null || _submitting) {
      setState(() => _dragOffset = 0);
      return;
    }
    setState(() => _submitting = true);
    try {
      // Accept up to 2% slippage between the quote and the fill.
      await LiveDataService.sellShares(
        widget.outcomeId!,
        widget.shares!,
        minProceedsKobo: (quote.netKobo * 0.98).floor(),
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
      AppRouter.marketSellSuccess,
      arguments: <String, dynamic>{
        'candidateName': widget.candidateName,
        'avgPriceKobo': _avgPriceKobo ?? 0,
        'cashedOutKobo': _netKobo ?? 0,
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
      if (_isLive) {
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
                            _Row(
                              label: 'To',
                              valueText: 'Wallet',
                              alignRight: true,
                            ),
                            _Row(
                              label: 'Selling',
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
                              alignRight: true,
                            ),
                            _Row(
                              label: 'Amount',
                              valueText: _money(_proceedsKobo),
                              alignRight: true,
                            ),
                            _Row(
                              label: "Total you'll receive",
                              valueText: _money(_netKobo),
                              alignRight: true,
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
                                amount: _money(_netKobo),
                                label: 'Cash out',
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
  const _Row({
    required this.label,
    this.valueText,
    this.valueWidget,
    this.alignRight = false,
  });
  final String label;
  final String? valueText;
  final Widget? valueWidget;
  final bool alignRight;

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
          if (alignRight) const SizedBox.shrink(),
        ],
      ),
    );
  }
}

class _PayoutColumn extends StatelessWidget {
  const _PayoutColumn({
    required this.amount,
    required this.label,
    this.alignRight = false,
  });
  final String amount;
  final String label;
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
        Text(
          label,
          textAlign: alignRight ? TextAlign.right : TextAlign.left,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
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
