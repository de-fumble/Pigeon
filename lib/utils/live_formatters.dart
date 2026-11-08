import 'package:flutter/material.dart';
import 'package:pigeon/utils/date_formatters.dart';

/// Formatting for values coming from the database. Money is stored as kobo
/// (₦1 = 100 kobo) and prices as probabilities in [0, 1]; see the conventions
/// at the top of supabase/schema.sql.
class LiveFormatters {
  const LiveFormatters._();

  static String groupDigits(int n) {
    final bool negative = n < 0;
    final String s = n.abs().toString();
    final StringBuffer buf = StringBuffer(negative ? '-' : '');
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  /// 4635721100 → "₦46,357,211". Drops kobo unless [showKobo] is set and
  /// they're non-zero.
  static String naira(int kobo, {bool showKobo = false}) {
    final int whole = kobo ~/ 100;
    final int rem = (kobo % 100).abs();
    final String sign = kobo < 0 ? '-' : '';
    final String base = '$sign₦${groupDigits(whole.abs())}';
    if (!showKobo || rem == 0) return base;
    return '$base.${rem.toString().padLeft(2, '0')}';
  }

  /// "+₦11.20" / "-₦34.70".
  static String nairaDelta(int kobo) =>
      '${kobo < 0 ? '-' : '+'}${naira(kobo.abs(), showKobo: true)}';

  /// 40000000 kobo → "₦400K".
  static String nairaCompact(int kobo) {
    final double n = kobo / 100;
    if (n >= 1e9) return '₦${_trim(n / 1e9)}B';
    if (n >= 1e6) return '₦${_trim(n / 1e6)}M';
    if (n >= 1e3) return '₦${_trim(n / 1e3)}K';
    return '₦${n.round()}';
  }

  static String countCompact(int n) {
    if (n >= 1e6) return '${_trim(n / 1e6)}M';
    if (n >= 1e3) return '${_trim(n / 1e3)}K';
    return '$n';
  }

  static String _trim(double v) => v >= 100
      ? v.round().toString()
      : v.toStringAsFixed(1).replaceAll('.0', '');

  /// 0.5912 → "59%", null (unpublished) → "-".
  static String percent(double? price) =>
      price == null ? '-' : '${(price * 100).round()}%';

  /// Share price in whole naira: a share pays ₦100, so price 0.59 → 59.
  static int pricePerShareNaira(double? price) =>
      price == null ? 0 : (price * 100).round();

  static String timeAgo(DateTime time, {DateTime? now}) {
    final Duration d = (now ?? DateTime.now()).difference(time);
    if (d.inMinutes < 1) return 'now';
    if (d.inHours < 1) return '${d.inMinutes}m';
    if (d.inDays < 1) return '${d.inHours}h';
    if (d.inDays < 7) return '${d.inDays}d';
    return shortDate(time);
  }

  /// "Jan 16, 2025".
  static String shortDate(DateTime time) {
    final DateTime t = time.toLocal();
    return '${DateFormatters.monthShort(t.month)} ${t.day}, ${t.year}';
  }

  static String initials(String name) {
    final List<String> parts = name
        .split(RegExp(r'\s+'))
        .where((String p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length.clamp(1, 3)).toUpperCase();
    }
    return parts.take(3).map((String p) => p[0]).join().toUpperCase();
  }

  /// '#FFD500' → Color. Falls back to [fallback] for null/invalid input.
  static Color color(String? hex, {Color fallback = const Color(0xFF34343A)}) {
    if (hex == null) return fallback;
    final String h = hex.replaceFirst('#', '');
    if (h.length != 6) return fallback;
    final int? v = int.tryParse(h, radix: 16);
    return v == null ? fallback : Color(0xFF000000 | v);
  }

  /// Deterministic avatar colour for users who haven't picked one.
  static Color avatarColorFor(String seed) {
    const List<Color> palette = <Color>[
      Color(0xFFF9D4DC),
      Color(0xFFEFF5FF),
      Color(0xFFFFE462),
      Color(0xFF7FFFB3),
      Color(0xFFFFD6D6),
      Color(0xFFD9D9D9),
    ];
    return palette[seed.hashCode.abs() % palette.length];
  }
}
