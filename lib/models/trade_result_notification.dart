class TradeSummaryRow {
  const TradeSummaryRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final String value;
  final bool highlight;
}

class TradeResultNotification {
  const TradeResultNotification({
    required this.questionTitle,
    required this.summary,
  });

  final String questionTitle;
  final List<TradeSummaryRow> summary;
}
