import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pigeon/components/auth/auth_responsive_layout.dart';
import 'package:pigeon/components/auth/auth_showcase_panel.dart';
import 'package:pigeon/utils/responsive.dart';

void main() {
  Future<void> pumpAt(WidgetTester tester, double width, Widget child) async {
    tester.view.physicalSize = Size(width, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: child)));
    await tester.pump();
  }

  /// The width the page lays itself out for.
  double seenWidth(WidgetTester tester) =>
      MediaQuery.sizeOf(tester.element(find.byKey(const Key('page')))).width;

  const Widget page = SizedBox.expand(key: Key('page'));

  test('size classes', () {
    expect(Breakpoints.classOf(390), ScreenClass.compact);
    expect(Breakpoints.classOf(834), ScreenClass.medium);
    expect(Breakpoints.classOf(1440), ScreenClass.expanded);
  });

  group('AuthResponsiveLayout', () {
    testWidgets('phones get the page as designed', (WidgetTester tester) async {
      await pumpAt(tester, 390, const AuthResponsiveLayout(child: page));
      expect(seenWidth(tester), 390);
      expect(find.byType(AuthShowcasePanel), findsNothing);
    });

    testWidgets('tablets centre the form column', (WidgetTester tester) async {
      await pumpAt(tester, 834, const AuthResponsiveLayout(child: page));
      expect(seenWidth(tester), Breakpoints.form);
      expect(
        tester.getSize(find.byKey(const Key('page'))).width,
        Breakpoints.form,
      );
      expect(find.byType(AuthShowcasePanel), findsNothing);
    });

    testWidgets('laptops add the showcase panel', (WidgetTester tester) async {
      await pumpAt(tester, 1440, const AuthResponsiveLayout(child: page));
      expect(find.byType(AuthShowcasePanel), findsOneWidget);
      expect(seenWidth(tester), Breakpoints.form);
      expect(tester.takeException(), isNull);
    });

    testWidgets('the showcase fits the narrowest split', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(Breakpoints.split, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AuthResponsiveLayout(child: page)),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('tall monitors keep the auth form phone-height', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(2560, 1440);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: AuthResponsiveLayout(child: page)),
      ),
    );
    await tester.pump();
    final Size form = tester.getSize(find.byKey(const Key('page')));
    expect(form, const Size(Breakpoints.form, Breakpoints.formHeight));
    expect(
      MediaQuery.sizeOf(tester.element(find.byKey(const Key('page')))).height,
      Breakpoints.formHeight,
    );
  });

  test('the content column widens a little on large monitors', () {
    expect(Breakpoints.columnFor(1440), Breakpoints.column);
    expect(Breakpoints.columnFor(2560), 640);
  });
}
