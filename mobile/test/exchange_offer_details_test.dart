import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rent_lanka_mobile/features/exchange_messaging_profile/widgets/exchange_offer_details.dart';

void main() {
  testWidgets('new offer details appear for sender and receiver summary', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: ExchangeOfferDetails(
      data: {'offeredEquipmentDetails': 'SS bat, excellent condition'},
    ))));
    expect(find.text('SS bat, excellent condition'), findsOneWidget);
  });
  testWidgets('legacy request without photo or details renders safely', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: ExchangeOfferDetails(data: {}))));
    expect(find.byType(Image), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
