import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pigeon/components/admin/admin_data_source_card.dart';
import 'package:pigeon/components/shared/data_source_builder.dart';
import 'package:pigeon/models/live_models.dart';
import 'package:pigeon/services/data_source_service.dart';
import 'package:pigeon/utils/live_formatters.dart';

void main() {
  tearDown(() => DataSourceService.current.value = UserDataSource.stock);

  group('UserDataSource.parse', () {
    test('reads live, defaults everything else to stock', () {
      expect(UserDataSource.parse('live'), UserDataSource.live);
      expect(UserDataSource.parse('stock'), UserDataSource.stock);
      expect(UserDataSource.parse(null), UserDataSource.stock);
      expect(UserDataSource.parse('nonsense'), UserDataSource.stock);
    });
  });

  testWidgets('DataSourceBuilder follows the admin setting', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: DataSourceBuilder(
          stock: (_) => const Text('stock view'),
          live: (_) => const Text('live view'),
        ),
      ),
    );
    expect(find.text('stock view'), findsOneWidget);

    DataSourceService.current.value = UserDataSource.live;
    await tester.pump();
    expect(find.text('live view'), findsOneWidget);
    expect(find.text('stock view'), findsNothing);

    DataSourceService.current.value = UserDataSource.stock;
    await tester.pump();
    expect(find.text('stock view'), findsOneWidget);
  });

  testWidgets('admin card reflects the current data source', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: AdminDataSourceCard())),
    );
    expect(find.text('User data'), findsOneWidget);
    expect(find.text('Stock'), findsOneWidget);

    DataSourceService.current.value = UserDataSource.live;
    await tester.pump();
    expect(find.text('Live'), findsOneWidget);
  });

  group('LiveFormatters', () {
    test('formats kobo as naira', () {
      expect(LiveFormatters.naira(4635721100), '₦46,357,211');
      expect(LiveFormatters.naira(1120, showKobo: true), '₦11.20');
      expect(LiveFormatters.nairaDelta(1120), '+₦11.20');
      expect(LiveFormatters.nairaDelta(-3470), '-₦34.70');
      expect(LiveFormatters.nairaCompact(40000000), '₦400K');
    });

    test('formats prices and share prices', () {
      expect(LiveFormatters.percent(0.5912), '59%');
      expect(LiveFormatters.percent(null), '-');
      expect(LiveFormatters.pricePerShareNaira(0.59), 59);
    });

    test('parses hex colours with a fallback', () {
      expect(LiveFormatters.color('#FFD500'), const Color(0xFFFFD500));
      expect(LiveFormatters.color('bad'), const Color(0xFF34343A));
    });
  });

  group('LiveMarket.fromJson', () {
    test('reads a market_feed row', () {
      final LiveMarket m = LiveMarket.fromJson(<String, dynamic>{
        'id': 'm1',
        'title': 'Will Davido drop an Album in 2026?',
        'market_type': 'binary',
        'status': 'active',
        'category_id': 'c1',
        'category_name': 'Culture',
        'subcategory_name': 'Music',
        'volume_kobo': 4635721100,
        'outcomes': <Map<String, dynamic>>[
          <String, dynamic>{'id': 'o1', 'label': 'Yes', 'price': 0.59},
          <String, dynamic>{'id': 'o2', 'label': 'No', 'price': 0.41},
        ],
      });
      expect(m.subtitle(), 'Culture – Music');
      expect(m.isTradable, isTrue);
      expect(m.isBinary, isTrue);
      expect(m.outcomes.map((LiveOutcome o) => o.label), <String>['Yes', 'No']);
      expect(m.outcomes.first.price, 0.59);
    });

    test('reads nested category and outcomes from the markets table', () {
      final LiveMarket m = LiveMarket.fromJson(<String, dynamic>{
        'id': 'm2',
        'title': 'Arsenal vs. Man City',
        'status': 'live',
        'category_id': 'c2',
        'category': <String, dynamic>{'name': 'Sports', 'color': '#19D36D'},
        'market_outcomes': <Map<String, dynamic>>[
          <String, dynamic>{'id': 'o1', 'label': 'Arsenal', 'price': '0.55'},
        ],
        'event': <String, dynamic>{
          'status': 'live',
          'live_period': '1H',
          'live_clock': '5:17',
          'home_team': <String, dynamic>{
            'name': 'Man City',
            'short_name': 'MAN',
          },
          'away_team': <String, dynamic>{
            'name': 'Arsenal',
            'short_name': 'ARS',
          },
        },
      });
      expect(m.categoryName, 'Sports');
      expect(m.outcomes.single.price, 0.55);
      expect(m.event!.hasTeams, isTrue);
      expect(m.event!.liveLabel, '1H 5:17');
    });
  });

  test('LivePost lists non-zero reactions in display order', () {
    final LivePost p = LivePost.fromJson(<String, dynamic>{
      'id': 'p1',
      'author_id': 'u1',
      'author_username': 'pigeonuniverse',
      'body': 'hello',
      'reaction_counts': <String, dynamic>{'ok_hand': 93, 'eyes': 54, 'cap': 0},
      'created_at': '2026-10-18T10:00:00Z',
    });
    expect(p.handle, '@pigeonuniverse');
    expect(p.visibleReactions.map((MapEntry<String, int> e) => e.key), <String>[
      'eyes',
      'ok_hand',
    ]);
  });
}
