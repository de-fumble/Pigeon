import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pigeon/components/market_cards/card_market_card.dart';
import 'package:pigeon/components/market_cards/fanbase_section_title.dart';
import 'package:pigeon/components/market_cards/list_market_card.dart';
import 'package:pigeon/components/market_cards/section_chip.dart';
import 'package:pigeon/components/market_cards/section_subtitle.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    home: Scaffold(
      backgroundColor: const Color(0xFF111111),
      body: SingleChildScrollView(child: child),
    ),
  );
}

void main() {
  group('SectionChip', () {
    testWidgets('renders correct text for shelves variant', (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(
        const SectionChip(variant: SectionChipVariant.shelves),
      ));
      expect(find.text('SHELVES'), findsOneWidget);
    });

    testWidgets('renders correct text for comingSoon variant', (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(
        const SectionChip(variant: SectionChipVariant.comingSoon),
      ));
      expect(find.text('COMING SOON MARKETS'), findsOneWidget);
    });

    testWidgets('renders correct text for listMarket variant', (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(
        const SectionChip(variant: SectionChipVariant.listMarket),
      ));
      expect(find.text('LIST MARKET'), findsOneWidget);
    });

    testWidgets('renders correct text for cardMarkets variant', (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(
        const SectionChip(variant: SectionChipVariant.cardMarkets),
      ));
      expect(find.text('CARD MARKETS'), findsOneWidget);
    });

    testWidgets('respects explicit label override', (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(
        const SectionChip(
          variant: SectionChipVariant.shelves,
          label: 'TRENDING',
        ),
      ));
      expect(find.text('TRENDING'), findsOneWidget);
      expect(find.text('SHELVES'), findsNothing);
    });

    testWidgets('has bounded max width container', (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(
        const SectionChip(variant: SectionChipVariant.shelves),
      ));
      final Finder centered = find.byType(Center);
      expect(centered, findsWidgets);
    });
  });

  group('SectionSubtitle', () {
    testWidgets('renders its text', (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(
        const SectionSubtitle(text: '(Options are just words)'),
      ));
      expect(find.text('(Options are just words)'), findsOneWidget);
    });
  });

  group('FanbaseSectionTitle', () {
    testWidgets('renders the supplied text', (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(
        const FanbaseSectionTitle(text: 'Fanbase'),
      ));
      expect(find.text('Fanbase'), findsOneWidget);
    });

    testWidgets('handles longer labels without overflow', (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(
        const FanbaseSectionTitle(text: 'Coming Soon Markets'),
      ));
      expect(find.text('Coming Soon Markets'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('ListMarketCard', () {
    const ListMarketCard activeCard = ListMarketCard(
      thumbnail: '🎤',
      thumbnailColor: Color(0xFFFA4E00),
      question: 'Will Davido drop an Album in 2026?',
      subtitle: 'Culture – Music',
      options: <MarketOption>[
        MarketOption(label: 'Yes', percentage: '59%'),
        MarketOption(label: 'No', percentage: '41%'),
      ],
      volume: '₦46,357,211',
      status: ListMarketStatus.active,
    );

    testWidgets('renders question, subtitle and all options', (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(activeCard));
      expect(find.text('Will Davido drop an Album in 2026?'), findsOneWidget);
      expect(find.text('Culture – Music'), findsOneWidget);
      expect(find.text('Yes'), findsOneWidget);
      expect(find.text('No'), findsOneWidget);
      expect(find.text('59%'), findsOneWidget);
      expect(find.text('41%'), findsOneWidget);
    });

    testWidgets('active footer renders volume + Active label', (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(activeCard));
      expect(find.text('₦46,357,211'), findsOneWidget);
      expect(find.text('Active'), findsOneWidget);
      expect(find.text('Coming soon'), findsNothing);
    });

    testWidgets('comingSoon footer replaces Active with Coming soon',
        (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(const ListMarketCard(
        thumbnail: '⚽',
        thumbnailColor: Color(0xFF38D4D8),
        question: 'How many tweets will Elon post in June?',
        subtitle: 'Culture',
        options: <MarketOption>[
          MarketOption(label: 'Under 50'),
          MarketOption(label: 'Above 50'),
        ],
        volume: '0',
        status: ListMarketStatus.comingSoon,
      )));
      expect(find.text('Coming soon'), findsOneWidget);
      expect(find.text('Active'), findsNothing);
    });

    testWidgets('renders dash when percentage is null', (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(const ListMarketCard(
        thumbnail: '⚽',
        thumbnailColor: Color(0xFF38D4D8),
        question: 'How many tweets will Elon post in June?',
        subtitle: 'Culture',
        options: <MarketOption>[
          MarketOption(label: 'Under 50'),
          MarketOption(label: 'Above 50'),
        ],
        volume: '0',
        status: ListMarketStatus.comingSoon,
      )));
      expect(find.text('-'), findsNWidgets(2));
    });

    testWidgets('closed status renders Closed label', (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(const ListMarketCard(
        thumbnail: '🎤',
        thumbnailColor: Color(0xFFFA4E00),
        question: 'Resolved question?',
        subtitle: 'Culture',
        options: <MarketOption>[
          MarketOption(label: 'Yes', percentage: '70%'),
        ],
        volume: '₦10,000,000',
        status: ListMarketStatus.closed,
      )));
      expect(find.text('Closed'), findsOneWidget);
    });
  });

  group('CardMarketCard', () {
    const CardMarketCard liveCard = CardMarketCard(
      thumbnail: '⚽',
      thumbnailColor: Color(0xFF38003C),
      question: 'Arsenal vs. Man City',
      subtitle: 'Sports – Champions League',
      liveLabel: 'Q1 · 5:19',
      options: <CardMarketOption>[
        CardMarketOption(
          label: 'Arsenal',
          imageGlyph: 'A',
          imageColor: Color(0xFFEF0101),
          count: '3',
          percentage: '59%',
        ),
        CardMarketOption(
          label: 'Man City',
          imageGlyph: 'M',
          imageColor: Color(0xFF6CABDD),
          count: '1',
          percentage: '41%',
        ),
      ],
      volume: '₦46,357,211',
      status: CardMarketStatus.active,
    );

    testWidgets('renders question, subtitle and option labels', (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(liveCard));
      expect(find.text('Arsenal vs. Man City'), findsOneWidget);
      expect(find.text('Sports – Champions League'), findsOneWidget);
      expect(find.text('Arsenal'), findsOneWidget);
      expect(find.text('Man City'), findsOneWidget);
    });

    testWidgets('renders counts and percent pills', (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(liveCard));
      expect(find.text('3'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('59%'), findsOneWidget);
      expect(find.text('41%'), findsOneWidget);
    });

    testWidgets('renders LIVE indicator when liveLabel provided', (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(liveCard));
      expect(find.text('LIVE'), findsOneWidget);
      expect(find.text('Q1 · 5:19'), findsOneWidget);
    });

    testWidgets('hides LIVE indicator when liveLabel is null', (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(const CardMarketCard(
        thumbnail: '⚽',
        thumbnailColor: Color(0xFF38003C),
        question: 'Resolved Match',
        subtitle: 'Sports',
        options: <CardMarketOption>[
          CardMarketOption(
            label: 'Option A',
            imageGlyph: 'A',
            imageColor: Color(0xFFEF0101),
            percentage: '60%',
          ),
        ],
        volume: '₦1,000,000',
        status: CardMarketStatus.closed,
      )));
      expect(find.text('LIVE'), findsNothing);
      expect(find.text('Closed'), findsOneWidget);
    });

    testWidgets('renders dash when option percentage is null', (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(const CardMarketCard(
        thumbnail: '⚽',
        thumbnailColor: Color(0xFF38003C),
        question: 'Coming Soon Match',
        subtitle: 'Sports',
        options: <CardMarketOption>[
          CardMarketOption(
            label: 'Option A',
            imageGlyph: 'A',
            imageColor: Color(0xFFEF0101),
          ),
        ],
        volume: '₦0',
        status: CardMarketStatus.comingSoon,
      )));
      expect(find.text('-'), findsOneWidget);
    });
  });

  group('Layout sanity (rendering at typical phone width)', () {
    testWidgets('ListMarketCard renders without overflow at 390px width',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390 * 3, 800 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_wrap(const SizedBox(
        width: 390,
        child: ListMarketCard(
          thumbnail: '🎤',
          thumbnailColor: Color(0xFFFA4E00),
          question: 'Will Davido drop an Album in 2026?',
          subtitle: 'Culture – Music',
          options: <MarketOption>[
            MarketOption(label: 'Yes', percentage: '59%'),
            MarketOption(label: 'No', percentage: '41%'),
          ],
          volume: '₦46,357,211',
          status: ListMarketStatus.active,
        ),
      )));
      expect(tester.takeException(), isNull);
    });

    testWidgets('CardMarketCard renders without overflow at 390px width',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390 * 3, 800 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_wrap(const SizedBox(
        width: 390,
        child: CardMarketCard(
          thumbnail: '⚽',
          thumbnailColor: Color(0xFF38003C),
          question: 'Arsenal vs. Man City',
          subtitle: 'Sports – Champions League',
          liveLabel: 'Q1 · 5:19',
          options: <CardMarketOption>[
            CardMarketOption(
              label: 'Arsenal',
              imageGlyph: 'A',
              imageColor: Color(0xFFEF0101),
              count: '3',
              percentage: '59%',
            ),
          ],
          volume: '₦46,357,211',
          status: CardMarketStatus.active,
        ),
      )));
      expect(tester.takeException(), isNull);
    });

    testWidgets('SectionChip renders within 800px width', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800 * 3, 1200 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_wrap(
        const SectionChip(
          variant: SectionChipVariant.comingSoon,
        ),
      ));
      expect(find.text('COMING SOON MARKETS'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
