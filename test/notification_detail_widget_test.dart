import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pigeon/components/notification_detail/notification_action_sheet.dart';
import 'package:pigeon/components/notification_detail/trade_result_hero.dart';
import 'package:pigeon/components/notification_detail/trade_summary_list.dart';
import 'package:pigeon/components/shared/app_svg_icon.dart';
import 'package:pigeon/models/trade_result_notification.dart';
import 'package:pigeon/screens/notifications_screens/notification_detail_screen.dart';

Widget _wrap(Widget child, {Color background = const Color(0xFF1A91FF)}) {
  return MaterialApp(
    home: Scaffold(
      backgroundColor: background,
      body: child,
    ),
  );
}

void main() {
  group('TradeResultHero', () {
    testWidgets('renders the headline', (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(const TradeResultHero(headline: 'You Won!')));
      expect(find.text('You Won!'), findsOneWidget);
    });

    testWidgets('renders TradeResultHero widget', (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(const TradeResultHero(headline: 'You Won!')));
      expect(find.byType(TradeResultHero), findsOneWidget);
    });
  });

  group('TradeSummaryList', () {
    testWidgets('renders all rows', (WidgetTester tester) async {
      const List<TradeSummaryRow> rows = <TradeSummaryRow>[
        TradeSummaryRow(label: 'Bought', value: 'Peter Obi'),
        TradeSummaryRow(label: 'Cost', value: '₦2,300'),
        TradeSummaryRow(label: 'Won', value: '₦6,700'),
      ];

      await tester.pumpWidget(_wrap(
        TradeSummaryList(rows: rows),
        background: const Color(0xFF000000),
      ));

      expect(find.text('Bought'), findsOneWidget);
      expect(find.text('Peter Obi'), findsOneWidget);
      expect(find.text('Cost'), findsOneWidget);
      expect(find.text('₦2,300'), findsOneWidget);
      expect(find.text('Won'), findsOneWidget);
      expect(find.text('₦6,700'), findsOneWidget);
    });

    testWidgets('renders highlight row with larger font', (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(
        const TradeSummaryList(rows: <TradeSummaryRow>[
          TradeSummaryRow(label: 'Won', value: '₦6,700', highlight: true),
        ]),
        background: const Color(0xFF000000),
      ));

      final TextStyle style =
          tester.widget<Text>(find.text('₦6,700')).style!;
      expect(style.fontSize, 22);
      expect(style.fontWeight, FontWeight.w800);
    });
  });

  group('NotificationActionSheet', () {
    testWidgets('renders Share and View Market tiles', (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(
        Align(
          alignment: Alignment.topRight,
          child: Builder(
            builder: (BuildContext context) => ElevatedButton(
              onPressed: () => NotificationActionSheet.show(context),
              child: const Text('Open'),
            ),
          ),
        ),
        background: const Color(0xFF000000),
      ));

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Share'), findsOneWidget);
      expect(find.text('View Market'), findsOneWidget);
      expect(find.byIcon(Icons.open_in_new), findsOneWidget);
      expect(find.byIcon(Icons.storefront_outlined), findsOneWidget);
    });

    testWidgets('Share tile calls onShareTap and dismisses', (WidgetTester tester) async {
      bool called = false;

      await tester.pumpWidget(_wrap(
        Align(
          alignment: Alignment.topRight,
          child: Builder(
            builder: (BuildContext context) => ElevatedButton(
              onPressed: () => NotificationActionSheet.show(
                context,
                onShareTap: () => called = true,
              ),
              child: const Text('Open'),
            ),
          ),
        ),
        background: const Color(0xFF000000),
      ));

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Share'));
      await tester.pumpAndSettle();

      expect(called, isTrue);
      expect(find.text('Share'), findsNothing);
    });
  });

  group('NotificationDetailScreen', () {
    testWidgets('renders the You Won! headline by default', (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(const NotificationDetailScreen()));
      expect(find.text('You Won!'), findsOneWidget);
    });

    testWidgets('renders default summary rows', (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(const NotificationDetailScreen()));
      expect(find.text('Bought'), findsOneWidget);
      expect(find.text('Peter Obi'), findsOneWidget);
      expect(find.text('Cost'), findsOneWidget);
      expect(find.text('₦2,300'), findsOneWidget);
      expect(find.text('Won'), findsOneWidget);
      expect(find.text('₦6,700'), findsOneWidget);
    });

    testWidgets('renders the overflow button', (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(const NotificationDetailScreen()));
      expect(
        find.byWidgetPredicate(
          (Widget widget) =>
              widget is AppSvgIcon &&
              widget.asset == AppIcons.notificationDetailDotButton,
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders the underlined Close button', (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(const NotificationDetailScreen()));
      expect(find.text('Close'), findsOneWidget);
      final TextStyle closeStyle = tester.widget<Text>(find.text('Close')).style!;
      expect(closeStyle.decoration, TextDecoration.underline);
      expect(closeStyle.color, Colors.white);
    });

    testWidgets('tapping Close pops the route', (WidgetTester tester) async {
      bool popped = false;

      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (BuildContext context) => Scaffold(
            backgroundColor: const Color(0xFF1A91FF),
            body: ElevatedButton(
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const NotificationDetailScreen(),
                  ),
                );
                popped = true;
              },
              child: const Text('Go'),
            ),
          ),
        ),
      ));

      await tester.tap(find.text('Go'));
      await tester.pumpAndSettle();

      expect(find.text('You Won!'), findsOneWidget);
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      expect(popped, isTrue);
      expect(find.text('You Won!'), findsNothing);
    });

    testWidgets('lost variant uses "You Lost" headline', (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(
        const NotificationDetailScreen(kind: NotificationDetailKind.lost),
      ));
      expect(find.text('You Lost'), findsOneWidget);
      expect(find.text('You Won!'), findsNothing);
    });

    testWidgets('bought variant uses "Position Opened" headline', (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(
        const NotificationDetailScreen(kind: NotificationDetailKind.bought),
      ));
      expect(find.text('Position Opened'), findsOneWidget);
    });

    testWidgets('renders custom notification data when provided',
        (WidgetTester tester) async {
      const TradeResultNotification custom = TradeResultNotification(
        questionTitle: 'Arsenal vs Man City',
        summary: <TradeSummaryRow>[
          TradeSummaryRow(label: 'Bought', value: 'Arsenal'),
          TradeSummaryRow(label: 'Cost', value: '₦500'),
          TradeSummaryRow(label: 'Won', value: '₦2,400', highlight: true),
        ],
      );

      await tester.pumpWidget(_wrap(
        const NotificationDetailScreen(notification: custom),
      ));
      expect(find.text('Arsenal'), findsOneWidget);
      expect(find.text('₦500'), findsOneWidget);
      expect(find.text('₦2,400'), findsOneWidget);
    });
  });
}
