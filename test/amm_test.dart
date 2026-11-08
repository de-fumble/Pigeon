import 'package:flutter_test/flutter_test.dart';
import 'package:pigeon/services/amm.dart';

// Expected values were computed by the SQL functions in supabase/schema.sql
// (private.lmsr_* with the quote_buy / quote_sell rounding), so these tests
// pin the on-device copy to the server.
void main() {
  // ₦100,000 seed, 4 options: b = 10,000,000 / (10,000 · ln 4).
  final AmmMarket election = AmmMarket(
    shares: <double>[0, 0, 0, 0],
    liquidity: 721.3475204445,
  );

  group('buy', () {
    test('₦649 of a fresh 4-option market', () {
      final AmmBuyQuote q = election.quoteBuy(1, 64900);
      expect(q.shares, closeTo(25.616841, 1e-9));
      expect(q.feeKobo, 1298);
      expect(q.totalKobo, 66198);
      expect(q.payoutIfRightKobo, 256168);
      expect(q.avgPriceKobo, 2533);
      expect(q.priceBefore, closeTo(0.25, 1e-12));
      expect(q.priceAfter, closeTo(0.2567175234, 1e-9));
    });

    test('a buy the size of the seed', () {
      final AmmBuyQuote q = election.quoteBuy(0, 10000000);
      expect(q.shares, closeTo(1850.219859, 1e-9));
      expect(q.priceAfter, closeTo(0.8125, 1e-9));
    });

    test('a skewed market', () {
      final AmmMarket m = AmmMarket(
        shares: <double>[1200, 300, 0],
        liquidity: 500,
      );
      expect(m.prices()[0], closeTo(0.7961676683, 1e-9));
      expect(m.prices()[1], closeTo(0.1316056304, 1e-9));
      expect(m.prices()[2], closeTo(0.0722267013, 1e-9));
      expect(m.quoteBuy(2, 500000).shares, closeTo(449.291924, 1e-9));
    });

    test('a huge order against a tiny seed does not overflow', () {
      final AmmMarket m = AmmMarket(
        shares: <double>[0, 0],
        liquidity: 7.2134752045,
      );
      expect(m.quoteBuy(0, 400000000).shares, closeTo(40005, 1e-9));
    });
  });

  group('sell', () {
    final AmmMarket m = AmmMarket(
      shares: <double>[1200, 300, 0],
      liquidity: 500,
    );

    test('proceeds and fee', () {
      final AmmSellQuote q = m.quoteSell(1, 123.4567);
      expect(q.proceedsKobo, 146084);
      expect(q.feeKobo, 2922);
      expect(q.netKobo, 143162);
      expect(m.quoteSell(1, 300).proceedsKobo, 306074);
    });

    test('sharesForProceeds inverts quoteSell', () {
      final double shares = m.sharesForProceeds(1, 146084)!;
      // 146,084 was floored, so the exact inverse sits within a kobo's worth.
      expect(shares, closeTo(123.4567, 1e-3));
      expect(m.quoteSell(1, shares).proceedsKobo, closeTo(146084, 1));
      expect(m.sharesForProceeds(1, 400000), isNull);
    });

    test('cannot sell more than is outstanding', () {
      expect(m.quoteSell(1, 1000).shares, 300);
    });
  });

  group('demo markets', () {
    test('are priced at the displayed price', () {
      final AmmMarket m = AmmMarket.demo(price: 0.59, optionCount: 4);
      expect(m.priceOf(0), closeTo(0.59, 1e-9));
      expect(
        m.prices().reduce((double a, double b) => a + b),
        closeTo(1, 1e-9),
      );
    });

    test('hold enough shares to sell a stock position', () {
      final AmmMarket m = AmmMarket.demo(price: 0.52, minSelectedShares: 1100);
      expect(m.shares[0], greaterThanOrEqualTo(1100));
      expect(m.priceOf(0), closeTo(0.52, 1e-9));
    });
  });

  test('maxStakeNaira leaves room for the fee', () {
    expect(election.maxStakeNaira(5967400), 58503);
    final int stake = election.maxStakeNaira(5967400) * 100;
    expect(stake + election.feeFor(stake), lessThanOrEqualTo(5967400));
    expect(election.feeLabel, '2%');
  });
}
