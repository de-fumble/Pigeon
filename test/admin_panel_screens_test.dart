import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pigeon/components/admin/admin_radio_dot.dart';
import 'package:pigeon/models/admin_models.dart';
import 'package:pigeon/router/app_router.dart';
import 'package:pigeon/services/admin_service.dart';

/// In-memory stand-in for the database, recording the writes it receives.
class FakeAdminService extends AdminService {
  final List<String> calls = <String>[];

  static const AdminCategory sports = AdminCategory(
    id: 'cat-sports',
    name: 'Sports',
    slug: 'sports',
    isActive: true,
    emoji: '⚽',
    color: '#19D36D',
  );

  final List<AdminCategory> categories = <AdminCategory>[
    const AdminCategory(
      id: 'cat-politics',
      name: 'Politics',
      slug: 'politics',
      isActive: true,
    ),
    sports,
    const AdminCategory(
      id: 'cat-culture',
      name: 'Culture',
      slug: 'culture',
      isActive: true,
    ),
    const AdminCategory(
      id: 'cat-football',
      name: 'Football',
      slug: 'football',
      isActive: true,
      parentId: 'cat-sports',
    ),
  ];

  static AdminMarket market(
    String id,
    String title, {
    String status = 'active',
    String category = 'Politics',
    int volumeKobo = 0,
    bool hidden = false,
  }) => AdminMarket(
    id: id,
    title: title,
    status: status,
    isHidden: hidden,
    isPublished: status != 'draft',
    categoryId: 'cat-${category.toLowerCase()}',
    categoryName: category,
    volumeKobo: volumeKobo,
    tradersCount: 0,
    outcomes: const <AdminOutcome>[
      AdminOutcome(id: 'o1', label: 'Yes', emoji: '👍'),
      AdminOutcome(id: 'o2', label: 'No'),
    ],
    topicIds: const <String>[],
  );

  final List<AdminMarket> markets = <AdminMarket>[
    market('m1', 'Next Lagos state Governor?', volumeKobo: 500000),
    market('m2', 'Will Burna Boy outsell his last album?', category: 'Culture'),
    market('m3', 'Draft market', status: 'draft'),
    market('m4', 'Old resolved market', status: 'resolved'),
  ];

  @override
  Future<AdminOverview> fetchOverview() async => const AdminOverview(
    totalUsers: 112056,
    totalMarkets: 92,
    wagerVolumeKobo: 32410621100,
    categoriesCount: 6,
    topicsCount: 50,
    shelvesCount: 6,
    bannersCount: 4,
  );

  @override
  Future<AdminUserStats> fetchUserStats({int? days}) async => AdminUserStats(
    totalUsers: 112056,
    newUsers: days == 7 ? 3042 : 112056,
    activeUsers: 54056,
    joinedToday: 1127,
  );

  @override
  Future<List<AdminSeriesPoint>> fetchUserGrowth({int? days}) async =>
      <AdminSeriesPoint>[
        AdminSeriesPoint(day: DateTime(2026, 4, 15), value: 10),
        AdminSeriesPoint(day: DateTime(2026, 4, 26), value: 40),
        AdminSeriesPoint(day: DateTime(2026, 5, 6), value: 90),
      ];

  @override
  Future<List<AdminSeriesPoint>> fetchVolumeSeries({int? days}) async =>
      <AdminSeriesPoint>[
        AdminSeriesPoint(day: DateTime(2026, 5, 5), value: 100000),
        AdminSeriesPoint(day: DateTime(2026, 5, 6), value: 250000),
      ];

  @override
  Future<List<AdminMarket>> fetchMarkets() async => markets;

  @override
  Future<List<AdminCategory>> fetchCategories() async => categories;

  @override
  Future<List<AdminTopic>> fetchTopics() async => const <AdminTopic>[
    AdminTopic(id: 't1', name: 'World Cup', categoryId: 'cat-sports'),
    AdminTopic(id: 't2', name: 'Elections', categoryId: 'cat-politics'),
  ];

  @override
  Future<List<String>> fetchTopicMarketIds(String topicId) async =>
      <String>['m1'];

  @override
  Future<List<AdminShelf>> fetchShelves() async => const <AdminShelf>[
    AdminShelf(
      id: 's1',
      title: 'Trending',
      heading: 'Nigerian Elections',
      items: <AdminShelfItem>[
        AdminShelfItem(label: 'Next Lagos state Governor?', marketId: 'm1'),
      ],
    ),
    AdminShelf(
      id: 's2',
      title: 'Most Predicted',
      heading: 'Champions',
      items: <AdminShelfItem>[],
    ),
  ];

  @override
  Future<List<AdminBanner>> fetchBanners() async => const <AdminBanner>[];

  @override
  Future<void> setMarketStatus(String marketId, String status) async =>
      calls.add('status $marketId $status');

  @override
  Future<void> createCategory({
    required String name,
    String? parentId,
    String? emoji,
    String? color,
    int sortOrder = 0,
  }) async => calls.add('createCategory $name ${parentId ?? '-'}');

  @override
  Future<void> createMarket({
    required String title,
    required String categoryId,
    String? subcategoryId,
    required List<({String label, String? emoji})> options,
    List<String> topicIds = const <String>[],
    List<String> linkUrls = const <String>[],
    String? period,
    String? resolutionCriteria,
    String? settlementTerms,
    String? wagerTerms,
    required int seedKobo,
    required String status,
  }) async => calls.add(
    'createMarket $title $categoryId '
    '${options.map((o) => '${o.emoji ?? ''}${o.label}').join('|')} '
    '$seedKobo $status',
  );
}

void main() {
  late FakeAdminService fake;

  setUp(() => AdminService.instance = fake = FakeAdminService());
  tearDown(() => AdminService.instance = AdminService());

  Future<void> open(
    WidgetTester tester,
    String route, {
    Object? arguments,
  }) async {
    // A tall phone, so long screens fit without scrolling.
    tester.view.physicalSize = const Size(430, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    // Pushed over a blank page, so screens that close themselves land there.
    final GlobalKey<NavigatorState> navigator = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigator,
        onGenerateRoute: AppRouter.onGenerateRoute,
        home: const Scaffold(),
      ),
    );
    navigator.currentState!.pushNamed(route, arguments: arguments);
    await tester.pumpAndSettle();
  }

  testWidgets('renders admin panel overview from the database', (
    WidgetTester tester,
  ) async {
    await open(tester, AppRouter.adminPanel);

    expect(find.text('Admin Panel'), findsOneWidget);
    expect(find.text('Users'), findsOneWidget);
    expect(find.text('112,056'), findsOneWidget);
    expect(find.text('Wage Volume'), findsOneWidget);
    expect(find.text('₦324,106,211'), findsOneWidget);
    expect(find.text('Topics & Shelves'), findsOneWidget);
    expect(find.text('56'), findsOneWidget);
  });

  testWidgets('renders user analytics screen', (WidgetTester tester) async {
    await open(tester, AppRouter.adminUsers);

    expect(find.text('Users'), findsOneWidget);
    expect(find.text('Total Users'), findsOneWidget);
    expect(find.text('User growth'), findsOneWidget);
    expect(find.text('Engagement'), findsOneWidget);
    expect(find.text('54,056'), findsOneWidget);
    expect(find.text('Apr 15'), findsOneWidget);
  });

  testWidgets('switches user analytics filters', (WidgetTester tester) async {
    await open(tester, AppRouter.adminUsers);

    await tester.tap(find.text('7D'));
    await tester.pumpAndSettle();

    expect(find.text('3,042'), findsOneWidget);
    expect(find.text('New Users (7D)'), findsOneWidget);
  });

  testWidgets('wage volume charts traded amounts', (WidgetTester tester) async {
    await open(
      tester,
      AppRouter.adminSection,
      arguments: const <String, String>{'title': 'Wage Volume'},
    );

    expect(find.text('Total Volume'), findsOneWidget);
    expect(find.text('₦3,500'), findsOneWidget);
  });

  testWidgets('lists markets, filters them and changes a status', (
    WidgetTester tester,
  ) async {
    await open(tester, AppRouter.adminMarkets);

    expect(find.text('Total Markets'), findsOneWidget);
    // Drafts don't count towards the total.
    expect(find.text('3'), findsOneWidget);
    expect(find.text('Top Markets'), findsOneWidget);
    expect(find.text('Draft market'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.more_horiz_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Resolved'), findsOneWidget);
    await tester.tap(find.text('Resolved'));
    await tester.pumpAndSettle();
    expect(find.text('Old resolved market'), findsOneWidget);
    expect(find.text('Draft market'), findsNothing);

    await tester.tap(find.byIcon(Icons.more_horiz_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('All').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Will Burna Boy outsell his last album?'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Paused'));
    await tester.pumpAndSettle();
    expect(fake.calls, contains('status m2 paused'));
  });

  testWidgets('renders market category selection from the database', (
    WidgetTester tester,
  ) async {
    await open(tester, AppRouter.adminMarketCategorySelect);

    expect(find.text('Select category'), findsOneWidget);
    expect(find.text('Politics'), findsOneWidget);
    expect(find.text('Sports'), findsOneWidget);
    // Subcategories aren't top-level choices.
    expect(find.text('Football'), findsNothing);
    expect(find.text('Next'), findsOneWidget);

    await tester.tap(find.text('Culture'));
    await tester.pumpAndSettle();

    expect(
      find.byWidgetPredicate(
        (Widget widget) => widget is AdminRadioDot && widget.selected,
      ),
      findsOneWidget,
    );
  });

  testWidgets('creates a market with its options', (WidgetTester tester) async {
    await open(
      tester,
      AppRouter.adminMarketCreate,
      arguments: FakeAdminService.sports,
    );

    await tester.enterText(find.byType(TextField).first, 'Who wins the cup?');
    for (final String option in <String>['🦅 Nigeria', 'Ghana']) {
      await tester.tap(find.text('Add other option'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, option);
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
    }
    expect(find.text('Nigeria'), findsOneWidget);
    expect(find.text('₦50'), findsNWidgets(2));

    // No seed yet, so an Active market is saved as a draft.
    await tester.tap(find.text('Save draft'));
    await tester.pumpAndSettle();
    expect(
      fake.calls,
      contains('createMarket Who wins the cup? cat-sports 🦅Nigeria|Ghana 0 draft'),
    );
  });

  testWidgets('categories come from the database and can be added', (
    WidgetTester tester,
  ) async {
    await open(tester, AppRouter.adminCategories);

    expect(find.text('Categories'), findsOneWidget);
    expect(find.text('Politics'), findsOneWidget);
    expect(find.text('Football'), findsNothing);

    await tester.tap(find.text('Sports'));
    await tester.pumpAndSettle();
    expect(find.text('Sub categories'), findsOneWidget);
    expect(find.text('Football'), findsOneWidget);

    await tester.tap(find.text('Add other option'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Golf');
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();
    expect(fake.calls, contains('createCategory Golf cat-sports'));
  });

  testWidgets('renders topics and shelves from the database', (
    WidgetTester tester,
  ) async {
    await open(tester, AppRouter.adminTopicsShelves);

    expect(find.text('Topics & Shelves'), findsOneWidget);
    expect(find.text('World Cup'), findsOneWidget);
    expect(find.text('Elections'), findsOneWidget);

    await tester.tap(find.text('Shelves'));
    await tester.pumpAndSettle();

    expect(find.text('Trending'), findsOneWidget);
    expect(find.text('Most Predicted'), findsOneWidget);
    expect(find.text('Nigerian Elections'), findsOneWidget);
    expect(find.text('Champions'), findsOneWidget);
  });

  testWidgets('topic detail lists the topic markets', (
    WidgetTester tester,
  ) async {
    await open(
      tester,
      AppRouter.adminTopicDetail,
      arguments: const AdminTopic(id: 't1', name: 'World Cup'),
    );

    expect(find.text('World Cup'), findsOneWidget);
    expect(find.text('Next Lagos state Governor?'), findsOneWidget);
    expect(find.text('Draft market'), findsNothing);
  });

  testWidgets('renders topic creation screen', (WidgetTester tester) async {
    await open(tester, AppRouter.adminCreateTopic);

    expect(find.text('Create Topic'), findsOneWidget);
    expect(find.text('Select Markets'), findsOneWidget);
    expect(find.text('Next Lagos state Governor?'), findsOneWidget);
  });

  testWidgets('renders shelf creation screen', (WidgetTester tester) async {
    await open(tester, AppRouter.adminCreateShelf);

    expect(find.text('Create Shelf'), findsOneWidget);
    expect(find.text('Select Market'), findsWidgets);
  });

  testWidgets('renders banners screen', (WidgetTester tester) async {
    await open(tester, AppRouter.adminBanners);

    expect(find.text('Banners'), findsOneWidget);
    expect(find.text('MARKETS'), findsOneWidget);
    expect(find.text('No banners yet.'), findsNWidgets(2));
  });
}
