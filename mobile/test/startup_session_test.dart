import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rent_lanka_mobile/features/user_discovery/screens/splash/splash_screen.dart';
import 'package:rent_lanka_mobile/features/user_discovery/services/startup_session_service.dart';

Widget app(Future<StartupDestination> Function() resolve) => MaterialApp(
  home: SplashScreen(
    resolveDestination: resolve,
    destinationBuilder: (destination) =>
        Scaffold(body: Text('Opened ${destination.name}')),
  ),
);

void main() {
  test('saved player/provider roles restore their existing landing screen', () {
    expect(
      StartupSessionService.destinationForRole('player'),
      StartupDestination.player,
    );
    expect(
      StartupSessionService.destinationForRole(' provider '),
      StartupDestination.provider,
    );
    expect(
      StartupSessionService.destinationForRole(null),
      StartupDestination.roleSelection,
    );
    expect(
      () => StartupSessionService.destinationForRole('admin'),
      throwsStateError,
    );
  });
  for (final destination in StartupDestination.values) {
    testWidgets(
      'cold startup restores ${destination.name} without showing another route',
      (tester) async {
        await tester.pumpWidget(app(() async => destination));
        await tester.pump(const Duration(seconds: 3));
        await tester.pumpAndSettle();
        expect(find.text('Opened ${destination.name}'), findsOneWidget);
        expect(find.byType(SplashScreen), findsNothing);
      },
    );
  }
  testWidgets(
    'waits for restored auth/profile instead of treating a delay as signed out',
    (tester) async {
      final result = Completer<StartupDestination>();
      await tester.pumpWidget(app(() => result.future));
      await tester.pump(const Duration(seconds: 3));
      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.textContaining('Opened'), findsNothing);
      result.complete(StartupDestination.provider);
      await tester.pumpAndSettle();
      expect(find.text('Opened provider'), findsOneWidget);
    },
  );
  testWidgets('temporary profile failure preserves session and offers retry', (
    tester,
  ) async {
    var attempts = 0;
    await tester.pumpWidget(
      app(() async {
        if (++attempts == 1) throw StateError('Network unavailable');
        return StartupDestination.player;
      }),
    );
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(
      find.text('Unable to load your account. Please try again.'),
      findsOneWidget,
    );
    expect(find.textContaining('Opened'), findsNothing);
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(find.text('Opened player'), findsOneWidget);
  });
  testWidgets('disposing splash cancels startup timer', (tester) async {
    var calls = 0;
    await tester.pumpWidget(
      app(() async {
        calls++;
        return StartupDestination.player;
      }),
    );
    await tester.pumpWidget(const MaterialApp(home: Text('Closed')));
    await tester.pump(const Duration(seconds: 4));
    expect(calls, 0);
    expect(tester.takeException(), isNull);
  });
}
