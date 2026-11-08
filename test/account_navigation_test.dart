import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pigeon/components/shared/account_buttons.dart';
import 'package:pigeon/components/shared/app_side_menu.dart';
import 'package:pigeon/models/live_models.dart';
import 'package:pigeon/services/account_service.dart';

AccountState _account({bool isAdmin = false}) => AccountState(
  profile: LiveProfile(
    id: 'u1',
    username: 'ada',
    createdAt: DateTime(2026, 1, 16),
  ),
  isAdmin: isAdmin,
  email: 'ada@example.com',
);

void main() {
  tearDown(() => AccountService.current.value = null);

  Future<void> pumpMenu(WidgetTester tester, {bool showAdminLink = false}) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: SidebarSheet(showAdminLink: showAdminLink)),
      ),
    );
  }

  testWidgets('signed-in side menu shows the account and its shortcuts', (
    WidgetTester tester,
  ) async {
    AccountService.current.value = _account();
    await pumpMenu(tester);

    expect(find.text('@ada'), findsOneWidget);
    expect(find.text('View account'), findsOneWidget);
    expect(find.text('My profile'), findsOneWidget);
    expect(find.text('Wallet'), findsOneWidget);
    expect(find.text('Account & settings'), findsOneWidget);
    expect(find.text('Help & Support'), findsOneWidget);
    expect(find.text('Log out'), findsOneWidget);
    // Visitors' prompt and admin-only links stay hidden.
    expect(find.text('Welcome to Pigeon'), findsNothing);
    expect(find.text('Admin Panel'), findsNothing);
  });

  testWidgets('admins also get the Admin Panel link', (
    WidgetTester tester,
  ) async {
    AccountService.current.value = _account(isAdmin: true);
    await pumpMenu(tester);

    expect(find.text('Admin Panel'), findsOneWidget);
  });

  testWidgets('menu updates when the account changes', (
    WidgetTester tester,
  ) async {
    AccountService.current.value = _account();
    await pumpMenu(tester);
    expect(find.text('@ada'), findsOneWidget);
    expect(find.text('Admin Panel'), findsNothing);

    AccountService.current.value = _account(isAdmin: true);
    await tester.pump();
    expect(find.text('Admin Panel'), findsOneWidget);
  });

  testWidgets('account button shows the signed-in user', (
    WidgetTester tester,
  ) async {
    AccountService.current.value = _account();
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: Center(child: AccountButton()))),
    );

    // Initial on the user's colour, not the Join button.
    expect(find.text('A'), findsOneWidget);
    expect(find.text('Join'), findsNothing);
  });

  test('AccountState exposes handle and contact', () {
    final AccountState account = _account();
    expect(account.handle, '@ada');
    expect(account.contact, 'ada@example.com');
  });
}
