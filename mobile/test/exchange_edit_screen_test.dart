// ignore_for_file: subtype_of_sealed_class
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rent_lanka_mobile/features/exchange_messaging_profile/screens/exchange_request_screen.dart';
import 'package:rent_lanka_mobile/features/exchange_messaging_profile/services/exchange_service.dart';

import 'equipment_reviews_test.dart'
    show ReviewAuth, ReviewDocument, ReviewSnapshot;

class EditingAuth extends ReviewAuth {
  @override
  Stream<User?> authStateChanges() => Stream.value(currentUser);
}

class EditingService extends Fake implements ExchangeService {
  final changes =
      StreamController<DocumentSnapshot<Map<String, dynamic>>>.broadcast();
  final data = <String, dynamic>{
    'senderId': 'player',
    'status': 'pending',
    'requestedEquipmentId': 'wanted',
    'offeredEquipmentId': '',
    'offeredEquipmentSource': 'inline',
    'offeredEquipmentName': 'My bat',
    'offeredEquipmentDetails': 'Good condition',
    'message': 'My original note',
  };
  Map<String, dynamic>? saved;
  @override
  Stream<QuerySnapshot<Map<String, dynamic>>> watchMyEquipment() =>
      Stream.value(ReviewSnapshot([]));
  @override
  Stream<DocumentSnapshot<Map<String, dynamic>>> watchExchangeRequest(
    String id,
  ) async* {
    yield ReviewDocument(id, data);
    yield* changes.stream;
  }

  @override
  Future<void> updateExchangeRequest({
    required String exchangeRequestId,
    required String offeredEquipmentId,
    required String offeredEquipmentName,
    required String message,
    String? offeredEquipmentDetails,
    String offeredEquipmentImageUrl = '',
    String? offeredEquipmentImagePublicId,
  }) async {
    saved = {
      'id': exchangeRequestId,
      'name': offeredEquipmentName,
      'details': offeredEquipmentDetails,
      'message': message,
    };
  }
}

void main() {
  late EditingService service;
  setUp(() => service = EditingService());
  tearDown(() => service.changes.close());
  Future<void> open(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ExchangeRequestScreen(
                    requestedEquipmentId: 'wanted',
                    requestedEquipmentName: 'Football',
                    requestedProviderId: 'provider',
                    exchangeRequestId: 'request',
                    initialData: service.data,
                    exchangeService: service,
                    auth: EditingAuth(),
                  ),
                ),
              ),
              child: const Text('Open editor'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open editor'));
    await tester.pumpAndSettle();
  }

  testWidgets('pending edit is prefilled and saves to the existing request', (
    tester,
  ) async {
    await open(tester);
    expect(find.text('Edit Exchange Request'), findsOneWidget);
    expect(find.text('My bat'), findsOneWidget);
    expect(find.text('Good condition'), findsOneWidget);
    expect(find.text('My original note'), findsOneWidget);
    await tester.enterText(find.byType(TextField).at(0), 'Updated bat');
    await tester.enterText(find.byType(TextField).at(1), 'Updated condition');
    await tester.enterText(find.byType(TextField).at(2), 'Updated note');
    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();
    expect(service.saved, {
      'id': 'request',
      'name': 'Updated bat',
      'details': 'Updated condition',
      'message': 'Updated note',
    });
    expect(find.text('Open editor'), findsOneWidget);
  });
  testWidgets(
    'provider acceptance while editing removes the form and save action',
    (tester) async {
      await open(tester);
      expect(find.text('Save Changes'), findsOneWidget);
      service.changes.add(
        ReviewDocument('request', {...service.data, 'status': 'accepted'}),
      );
      await tester.pumpAndSettle();
      expect(find.text('Save Changes'), findsNothing);
      expect(find.byType(TextField), findsNothing);
      expect(
        find.textContaining('This request cannot be edited.'),
        findsOneWidget,
      );
      expect(service.saved, isNull);
    },
  );
}
