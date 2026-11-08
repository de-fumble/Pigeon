import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pigeon/router/app_router.dart';
import 'package:pigeon/services/amm.dart';
import 'package:pigeon/utils/live_formatters.dart';

// A stock 4-option market priced at ₦25 is the same market maker as a fresh
// ₦100,000-seed market on the server, so these figures are the ones
// quote_buy returns for ₦649 (see test/amm_test.dart).
void main() {
  Future<void> openBuy(WidgetTester tester) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        onGenerateRoute: AppRouter.onGenerateRoute,
        onGenerateInitialRoutes: (String name) => <Route<dynamic>>[
          AppRouter.onGenerateRoute(
            const RouteSettings(
              name: AppRouter.marketTradeInput,
              arguments: <String, dynamic>{
                'candidateName': 'Peter Obi',
                'candidateInitials': 'PO',
                'pricePerShare': 25,
                'optionCount': 4,
                'walletBalance': 59674,
              },
            ),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> type(WidgetTester tester, String digits) async {
    for (final String d in digits.split('')) {
      await tester.tap(find.text(d).last);
      await tester.pump();
    }
  }

  testWidgets('buy input previews the market maker payout', (
    WidgetTester tester,
  ) async {
    await openBuy(tester);
    await type(tester, '649');
    expect(find.text('₦649'), findsOneWidget);
    expect(find.text('wins ₦2,561.68'), findsOneWidget);
  });

  testWidgets('buy review shows the exact quote', (WidgetTester tester) async {
    await openBuy(tester);
    await type(tester, '649');
    await tester.tap(find.text('Review'));
    await tester.pumpAndSettle();

    expect(find.text('₦25.33'), findsOneWidget); // average price per share
    expect(find.text('₦661.98'), findsOneWidget); // stake + 2% fee
    expect(find.text('₦2,561.68'), findsOneWidget); // payout if right
    expect(find.text('₦12.98'), findsOneWidget); // fee
    expect(find.text('Transaction fee (2%)'), findsOneWidget);
  });

  testWidgets('Max leaves room for the fee', (WidgetTester tester) async {
    await openBuy(tester);
    await tester.tap(find.text('Max'));
    await tester.pump();
    expect(find.text('₦58,503'), findsOneWidget);
    expect(find.textContaining('Insufficient'), findsNothing);
  });

  testWidgets('selling all of a stock position quotes the market maker', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        onGenerateRoute: AppRouter.onGenerateRoute,
        onGenerateInitialRoutes: (String name) => <Route<dynamic>>[
          AppRouter.onGenerateRoute(
            const RouteSettings(
              name: AppRouter.marketSellInput,
              arguments: <String, dynamic>{
                'candidateName': 'Yes',
                'candidateInitials': 'Y',
                'pricePerShare': 52,
                'sharesOwned': 1100,
              },
            ),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    final AmmSellQuote all = AmmMarket.demo(
      price: 0.52,
      minSelectedShares: 1100,
    ).quoteSell(0, 1100);
    expect(
      find.text('You own ${LiveFormatters.naira(all.proceedsKobo)}'),
      findsOneWidget,
    );

    await tester.tap(find.text('Max'));
    await tester.pump();
    await tester.tap(find.text('Review'));
    await tester.pumpAndSettle();
    expect(
      find.text(LiveFormatters.naira(all.netKobo, showKobo: true)),
      findsNWidgets(2), // "Total you'll receive" and "Cash out"
    );
    expect(
      find.text(LiveFormatters.naira(all.feeKobo, showKobo: true)),
      findsOneWidget,
    );
  });
}
