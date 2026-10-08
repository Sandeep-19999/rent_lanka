import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rent_lanka_mobile/features/exchange_messaging_profile/screens/payment_methods_screen.dart';

void main() {
  for (final action in ['Add', 'Cancel']) {
    testWidgets('card dialog closes safely using $action', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: PaymentMethodsScreen()),
      );

      // Repeat to cover reopening after the previous field was disposed.
      for (var attempt = 0; attempt < 2; attempt++) {
        await tester.tap(find.text('Add payment method').first);
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField), '4242424242424242');
        await tester.tap(find.text(action));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.byType(AlertDialog), findsNothing);
        expect(find.text('Payment methods'), findsOneWidget);
        // Let the feedback snackbar expire before reopening the dialog.
        await tester.pump(const Duration(seconds: 5));
        await tester.pumpAndSettle();
      }
    });
  }
}
