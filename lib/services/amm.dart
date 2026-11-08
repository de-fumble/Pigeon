import 'dart:math' as math;

/// On-device copy of the LMSR market maker in supabase/schema.sql
/// (`private.lmsr_*` plus the rounding in `quote_buy` / `quote_sell`), so the
/// trade screens show the same figures the server will charge while the user
/// is still typing. For live markets the server's quotes stay authoritative:
/// the review screens fetch them before an order is sent.
///
/// Units match the server: one share pays ₦100 (10,000 kobo) if its option
/// wins; [shares] is the shares-outstanding vector q and [liquidity] is b,
/// both counted in shares.
class AmmMarket {
  AmmMarket({
    required List<double> shares,
    required this.liquidity,
    this.feeBps = defaultFeeBps,
  }) : shares = List<double>.unmodifiable(shares);

  /// A market where option 0 trades at [price] and the other options split
  /// the rest evenly. Stock markets only know a displayed price, so this
  /// builds a consistent market around it, funded like a real one by
  /// [seedKobo]. [minSelectedShares] guarantees option 0 has at least that
  /// many shares outstanding, so a stock position of that size can be sold.
  factory AmmMarket.demo({
    required double price,
    int optionCount = 2,
    double minSelectedShares = 0,
    int seedKobo = demoSeedKobo,
    int feeBps = defaultFeeBps,
  }) {
    final int n = math.max(optionCount, 2);
    final double b = seedKobo / (koboPerShare * math.log(n));
    final double p = price.clamp(0.01, 0.99);
    final double rest = (1 - p) / (n - 1);
    // Prices only depend on differences in q, so any shift is the same market.
    final List<double> raw = <double>[
      b * math.log(p),
      for (int i = 1; i < n; i++) b * math.log(rest),
    ];
    final double shift = math.max(
      -raw.reduce(math.min),
      minSelectedShares - raw.first,
    );
    return AmmMarket(
      shares: <double>[for (final double q in raw) q + shift],
      liquidity: b,
      feeBps: feeBps,
    );
  }

  /// `platform_settings.trade_fee_bps` default (2%).
  static const int defaultFeeBps = 200;

  /// What one winning share pays.
  static const int koboPerShare = 10000;

  /// Seed used for stock (demo) markets: ₦100,000.
  static const int demoSeedKobo = 10000000;

  final List<double> shares;
  final double liquidity;
  final int feeBps;

  /// Fee on [kobo], rounded up to the next kobo like the server's `ceil`.
  int feeFor(int kobo) => (kobo * feeBps + 9999) ~/ 10000;

  /// "2%" / "1.5%".
  String get feeLabel =>
      feeBps % 100 == 0 ? '${feeBps ~/ 100}%' : '${feeBps / 100}%';

  /// Current probability of every option; they sum to 1.
  List<double> prices() {
    final _Sums s = _sums();
    return <double>[for (final double q in shares) s.scaled(q) / s.total];
  }

  double priceOf(int index) => prices()[index];

  /// Buying ₦[amountKobo] of option [index] (fee charged on top).
  AmmBuyQuote quoteBuy(int index, int amountKobo) {
    final double b = liquidity;
    final _Sums s = _sums();
    final double ei = s.scaled(shares[index]);
    final double cost = amountKobo / koboPerShare;
    // Δ = b·ln(S·e^(cost/b) − S + e_i) − q_i, rearranged so e^(cost/b) can't
    // overflow on a large order against a small seed.
    final double bought = _truncate6(
      b *
              (s.m +
                  cost / b +
                  math.log(s.total - (s.total - ei) * math.exp(-cost / b))) -
          shares[index],
    );
    final int fee = feeFor(amountKobo);
    return AmmBuyQuote(
      amountKobo: amountKobo,
      shares: bought,
      feeKobo: fee,
      totalKobo: amountKobo + fee,
      payoutIfRightKobo: (bought * koboPerShare).floor(),
      priceBefore: priceOf(index),
      priceAfter: _withShares(index, bought).priceOf(index),
    );
  }

  /// Selling [sellShares] of option [index] (fee taken from the proceeds).
  AmmSellQuote quoteSell(int index, double sellShares) {
    final double b = liquidity;
    final double sold = math.min(sellShares, shares[index]);
    final _Sums s = _sums();
    final double ei = s.scaled(shares[index]);
    final double units =
        b *
        (math.log(s.total) -
            math.log(
              s.total - ei + math.exp((shares[index] - sold) / b - s.m),
            ));
    final int proceeds = math.max(0, (units * koboPerShare).floor());
    final int fee = feeFor(proceeds);
    return AmmSellQuote(
      shares: sold,
      proceedsKobo: proceeds,
      feeKobo: fee,
      netKobo: proceeds - fee,
      priceBefore: priceOf(index),
      priceAfter: _withShares(index, -sold).priceOf(index),
    );
  }

  /// Shares of option [index] to sell for gross proceeds of [proceedsKobo]
  /// (the inverse of [quoteSell]), or null if selling every outstanding share
  /// still wouldn't raise that much.
  double? sharesForProceeds(int index, int proceedsKobo) {
    final double b = liquidity;
    final _Sums s = _sums();
    final double ei = s.scaled(shares[index]);
    final double inner =
        s.total * math.exp(-(proceedsKobo / koboPerShare) / b) - s.total + ei;
    if (inner <= 0) return null;
    final double delta = shares[index] - b * (s.m + math.log(inner));
    if (delta > shares[index]) return null;
    return _truncate6(math.max(0, delta));
  }

  /// Largest whole-naira stake whose stake + fee fits in [budgetKobo].
  int maxStakeNaira(int budgetKobo) {
    int naira = (budgetKobo * 10000) ~/ (100 * (10000 + feeBps));
    while (naira > 0 && naira * 100 + feeFor(naira * 100) > budgetKobo) {
      naira--;
    }
    return naira;
  }

  AmmMarket _withShares(int index, double delta) {
    final List<double> next = List<double>.of(shares);
    next[index] = next[index] + delta;
    return AmmMarket(shares: next, liquidity: liquidity, feeBps: feeBps);
  }

  _Sums _sums() {
    final double m = shares.reduce(math.max) / liquidity;
    double total = 0;
    for (final double q in shares) {
      total += math.exp(q / liquidity - m);
    }
    return _Sums(m, total, liquidity);
  }

  /// The server keeps share counts to 6 decimal places, rounding down.
  static double _truncate6(double v) => (v * 1e6).floorToDouble() / 1e6;
}

/// Σ e^(q/b − m) and the scaling m = max(q)/b that keeps it from overflowing.
class _Sums {
  const _Sums(this.m, this.total, this.b);

  final double m;
  final double total;
  final double b;

  double scaled(double q) => math.exp(q / b - m);
}

class AmmBuyQuote {
  const AmmBuyQuote({
    required this.amountKobo,
    required this.shares,
    required this.feeKobo,
    required this.totalKobo,
    required this.payoutIfRightKobo,
    required this.priceBefore,
    required this.priceAfter,
  });

  final int amountKobo;
  final double shares;
  final int feeKobo;

  /// Stake + fee: what leaves the wallet.
  final int totalKobo;

  /// ₦100 per share if the option wins.
  final int payoutIfRightKobo;
  final double priceBefore;
  final double priceAfter;

  /// Average cost per share, in kobo.
  int get avgPriceKobo => shares > 0 ? (amountKobo / shares).round() : 0;
}

class AmmSellQuote {
  const AmmSellQuote({
    required this.shares,
    required this.proceedsKobo,
    required this.feeKobo,
    required this.netKobo,
    required this.priceBefore,
    required this.priceAfter,
  });

  final double shares;
  final int proceedsKobo;
  final int feeKobo;

  /// Proceeds − fee: what lands in the wallet.
  final int netKobo;
  final double priceBefore;
  final double priceAfter;

  /// Average sale price per share, in kobo.
  int get avgPriceKobo => shares > 0 ? (proceedsKobo / shares).round() : 0;
}
