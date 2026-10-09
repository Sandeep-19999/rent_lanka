import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rent_lanka_mobile/features/exchange_messaging_profile/screens/payment_methods_screen.dart';

void main() {
  testWidgets('payment methods remains visible without the add button', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: PaymentMethodsScreen()));
    expect(find.text('Payment methods'), findsOneWidget);
    expect(find.text('Add payment method'), findsNothing);
    expect(find.byIcon(Icons.add), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
