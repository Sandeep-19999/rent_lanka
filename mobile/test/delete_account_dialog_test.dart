import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rent_lanka_mobile/features/exchange_messaging_profile/services/account_deletion_service.dart';
import 'package:rent_lanka_mobile/features/exchange_messaging_profile/widgets/delete_account_dialog.dart';

class FakeDeletionService implements AccountDeletionService {
  @override
  bool requiresPassword = true;
  int calls = 0;
  String? submittedPassword;
  Object? failure;
  Completer<void>? pending;

  @override
  Future<void> deleteAccount({String? password}) async {
    calls++;
    submittedPassword = password;
    if (failure != null) throw failure!;
    if (pending != null) await pending!.future;
  }
}

void main() {
  Future<void> open(
    WidgetTester tester,
    FakeDeletionService service, {
    ValueChanged<bool?>? result,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async {
                final deleted = await showDialog<bool>(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => DeleteAccountDialog(service: service),
                );
                result?.call(deleted);
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
  }

  testWidgets('cancel performs no deletion', (tester) async {
    final service = FakeDeletionService();
    bool? result;
    await open(tester, service, result: (value) => result = value);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(service.calls, 0);
    expect(result, false);
  });

  testWidgets('requires password before deleting and returns success', (
    tester,
  ) async {
    final service = FakeDeletionService();
    bool? result;
    await open(tester, service, result: (value) => result = value);
    await tester.tap(find.text('Delete Account'));
    await tester.pumpAndSettle();
    expect(service.calls, 0);
    expect(find.text('Enter your current password.'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'my-password');
    await tester.tap(find.text('Delete Account'));
    await tester.pumpAndSettle();
    expect(service.submittedPassword, 'my-password');
    expect(result, true);
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('wrong password permits retry without success navigation', (
    tester,
  ) async {
    final service = FakeDeletionService()
      ..failure = FirebaseAuthException(code: 'invalid-credential');
    bool? result;
    await open(tester, service, result: (value) => result = value);
    await tester.enterText(find.byType(TextField), 'incorrect');
    await tester.tap(find.text('Delete Account'));
    await tester.pumpAndSettle();
    expect(find.text('Current password is incorrect.'), findsOneWidget);
    expect(result, isNull);
    service.failure = null;
    await tester.tap(find.text('Delete Account'));
    await tester.pumpAndSettle();
    expect(service.calls, 2);
    expect(result, true);
  });

  testWidgets(
    'blocks cancellation, back and duplicate submissions while deleting',
    (tester) async {
      final service = FakeDeletionService()..pending = Completer<void>();
      await open(tester, service);
      await tester.enterText(find.byType(TextField), 'my-password');
      await tester.tap(find.text('Delete Account'));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(
        tester
            .widget<TextButton>(find.widgetWithText(TextButton, 'Cancel'))
            .onPressed,
        isNull,
      );
      await tester.binding.handlePopRoute();
      await tester.pump();
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(service.calls, 1);
      service.pending!.complete();
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Google flow has no password field', (tester) async {
    final service = FakeDeletionService()..requiresPassword = false;
    await open(tester, service);
    expect(find.byType(TextField), findsNothing);
    await tester.tap(find.text('Delete Account'));
    await tester.pumpAndSettle();
    expect(service.calls, 1);
  });

  testWidgets('data deletion error keeps dialog open', (tester) async {
    final service = FakeDeletionService()
      ..failure = FirebaseException(
        plugin: 'cloud_firestore',
        code: 'permission-denied',
      );
    await open(tester, service);
    await tester.enterText(find.byType(TextField), 'my-password');
    await tester.tap(find.text('Delete Account'));
    await tester.pumpAndSettle();
    expect(
      find.text('Unable to delete account data. Please contact support.'),
      findsOneWidget,
    );
    expect(find.byType(AlertDialog), findsOneWidget);
  });
}
