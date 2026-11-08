import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pigeon/components/admin/admin_shell.dart';
import 'package:pigeon/router/app_router.dart';
import 'package:pigeon/screens/admin_screens/admin_markets_screen.dart';
import 'package:pigeon/screens/admin_screens/admin_panel_screen.dart';
import 'package:pigeon/screens/admin_screens/admin_users_screen.dart';
import 'package:pigeon/screens/onboarding_screens/onboarding_screen.dart';
import 'package:pigeon/services/admin_service.dart';

import 'admin_panel_screens_test.dart' show FakeAdminService;

void main() {
  setUp(() => AdminService.instance = FakeAdminService());
  tearDown(() => AdminService.instance = AdminService());

  Future<void> open(WidgetTester tester, double width) async {
    tester.view.physicalSize = Size(width, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        onGenerateRoute: AppRouter.onGenerateRoute,
        onGenerateInitialRoutes: (String _) => <Route<dynamic>>[
          AppRouter.onGenerateRoute(
            const RouteSettings(name: AppRouter.onboarding),
          ),
          AppRouter.onGenerateRoute(
            const RouteSettings(name: AppRouter.adminPanel),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tapSidebar(WidgetTester tester, String label) async {
    await tester.tap(
      find
          .descendant(of: find.byType(AdminShell), matching: find.text(label))
          .last,
    );
    await tester.pumpAndSettle();
  }

  testWidgets('phones keep the admin pages as designed', (
    WidgetTester tester,
  ) async {
    await open(tester, 390);
    expect(find.byType(AdminShellScope), findsNothing);
    expect(find.text('Back to Pigeon'), findsNothing);
  });

  testWidgets('laptops get the admin sidebar', (WidgetTester tester) async {
    await open(tester, 1440);
    expect(find.byType(AdminShellScope), findsOneWidget);
    expect(find.text('Overview'), findsOneWidget);
    expect(find.text('Back to Pigeon'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('sidebar sections replace each other instead of stacking', (
    WidgetTester tester,
  ) async {
    await open(tester, 1440);
    await tapSidebar(tester, 'Markets');
    expect(find.byType(AdminMarketsScreen), findsOneWidget);

    await tapSidebar(tester, 'Users');
    expect(find.byType(AdminUsersScreen), findsOneWidget);
    expect(find.byType(AdminMarketsScreen), findsNothing);

    // Back from a section returns to the Overview, not the previous section.
    final NavigatorState nav = tester.state(find.byType(Navigator));
    nav.pop();
    await tester.pumpAndSettle();
    expect(find.byType(AdminPanelScreen), findsOneWidget);
  });

  testWidgets('Back to Pigeon leaves the admin area', (
    WidgetTester tester,
  ) async {
    await open(tester, 1440);
    await tapSidebar(tester, 'Markets');
    // The onboarding showcase animates continuously, so pump a fixed time.
    await tester.tap(find.text('Back to Pigeon').last);
    // Pressable fires after its press animation; then the pages animate out.
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(find.byType(AdminShell), findsNothing);
  });
}
