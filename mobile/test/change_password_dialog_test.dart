import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rent_lanka_mobile/features/exchange_messaging_profile/services/password_service.dart';
import 'package:rent_lanka_mobile/features/exchange_messaging_profile/widgets/change_password_dialog.dart';

class FakePasswordService implements PasswordService {
  @override
  bool supportsPassword = true;
  int calls = 0;
  String? failure;
  List<String>? submitted;

  @override
  Future<void> changePassword(String current, String next) async {
    calls++;
    submitted = [current, next];
    if (failure != null) throw FirebaseAuthException(code: failure!);
  }
}

void main() {
  Future<void> open(WidgetTester tester, FakePasswordService service) async {
    await tester.pumpWidget(MaterialApp(home: Builder(builder: (context) {
      return Scaffold(body: TextButton(
        onPressed: () => showDialog<bool>(context: context,
          builder: (_) => ChangePasswordDialog(service: service)),
        child: const Text('Open'),
      ));
    })));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
  }

  testWidgets('validates confirmation, updates, and disposes safely', (tester) async {
    final service = FakePasswordService();
    await open(tester, service);
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'old-password');
    await tester.enterText(fields.at(1), 'new-password');
    await tester.enterText(fields.at(2), 'mismatch');
    await tester.tap(find.text('Update'));
    await tester.pumpAndSettle();
    expect(service.calls, 0);
    expect(find.text('Passwords do not match.'), findsOneWidget);
    await tester.enterText(fields.at(2), 'new-password');
    await tester.tap(find.text('Update'));
    await tester.pumpAndSettle();
    expect(service.submitted, ['old-password', 'new-password']);
    expect(find.byType(AlertDialog), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('wrong password keeps dialog open for retry', (tester) async {
    final service = FakePasswordService()..failure = 'invalid-credential';
    await open(tester, service);
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'incorrect');
    await tester.enterText(fields.at(1), 'new-password');
    await tester.enterText(fields.at(2), 'new-password');
    await tester.tap(find.text('Update'));
    await tester.pumpAndSettle();
    expect(find.text('Current password is incorrect.'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('provider-only accounts cannot submit a password', (tester) async {
    final service = FakePasswordService()..supportsPassword = false;
    await open(tester, service);
    expect(find.byType(TextFormField), findsNothing);
    expect(find.text('Update'), findsNothing);
    expect(service.calls, 0);
  });
}
