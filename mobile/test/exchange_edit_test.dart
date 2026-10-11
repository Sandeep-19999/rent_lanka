// ignore_for_file: subtype_of_sealed_class
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rent_lanka_mobile/features/exchange_messaging_profile/models/exchange_edit_policy.dart';
import 'package:rent_lanka_mobile/features/exchange_messaging_profile/services/exchange_service.dart';

import 'equipment_reviews_test.dart'
    show ReviewStore, ReviewAuth, ReviewTransaction;

class EditTransaction extends ReviewTransaction {
  EditTransaction(super.store);
  @override
  Transaction update(
    DocumentReference<Object?> reference,
    Map<Object, Object?> data,
  ) {
    pending[reference.path] = Map<String, dynamic>.from(data);
    return this;
  }
}

class EditStore extends ReviewStore {
  bool providerAcceptsDuringEdit = false;
  int attempts = 0;
  @override
  Future<T> runTransaction<T>(
    Future<T> Function(Transaction) handler, {
    Duration timeout = const Duration(seconds: 30),
    int maxAttempts = 5,
  }) async {
    var transaction = EditTransaction(this);
    attempts++;
    var result = await handler(transaction);
    if (providerAcceptsDuringEdit) {
      records['exchange_requests/request']!['status'] = 'accepted';
      transaction = EditTransaction(this);
      attempts++;
      result = await handler(transaction);
    }
    for (final entry in transaction.pending.entries) {
      records[entry.key] = {...?records[entry.key], ...resolve(entry.value)};
    }
    return result;
  }
}

void main() {
  late EditStore store;
  late ExchangeService service;
  setUp(() {
    store = EditStore();
    service = ExchangeService(firestore: store, auth: ReviewAuth());
    store.records['exchange_requests/request'] = {
      'senderId': 'player',
      'requestedProviderId': 'provider',
      'requestedEquipmentId': 'wanted',
      'requestedEquipmentName': 'Football',
      'status': 'pending',
      'createdAt': Timestamp(1, 0),
      'message': 'Original',
      'offeredEquipmentId': '',
      'offeredEquipmentSource': 'inline',
      'offeredEquipmentName': 'Old offer',
      'offeredEquipmentDetails': 'Old details',
      'offeredEquipmentImageUrl': 'https://example.com/old.jpg',
      'offeredEquipmentImagePublicId': 'old-photo',
    };
    store.records['equipment/owned'] = {
      'providerId': 'player',
      'name': 'Live listed bat',
      'isAvailable': true,
      'status': 'Available',
      'imageUrl': 'https://example.com/listed.jpg',
    };
  });
  tearDown(() => store.changes.close());
  Future<void> editInline() => service.updateExchangeRequest(
    exchangeRequestId: 'request',
    offeredEquipmentId: '',
    offeredEquipmentName: ' New bat ',
    offeredEquipmentDetails: ' Good grip ',
    offeredEquipmentImageUrl: 'https://example.com/old.jpg',
    offeredEquipmentImagePublicId: 'old-photo',
    message: ' Revised offer ',
  );

  test('pending owner can update inline offer, preserving requested item, status and creation date', () async {
    await editInline();
    final data = store.records['exchange_requests/request']!;
    expect(data['offeredEquipmentName'], 'New bat');
    expect(data['offeredEquipmentDetails'], 'Good grip');
    expect(data['message'], 'Revised offer');
    expect(data['offeredEquipmentImagePublicId'], 'old-photo');
    expect(data['status'], 'pending');
    expect(data['requestedEquipmentId'], 'wanted');
    expect(data['requestedProviderId'], 'provider');
    expect(data['createdAt'], Timestamp(1, 0));
    expect(store.attempts, 1);
  });
  test('listed offer validates ownership and clears obsolete inline details/photo metadata', () async {
    await service.updateExchangeRequest(
      exchangeRequestId: 'request',
      offeredEquipmentId: 'owned',
      offeredEquipmentName: 'Stale client name',
      message: 'New',
    );
    final data = store.records['exchange_requests/request']!;
    expect(data['offeredEquipmentName'], 'Live listed bat');
    expect(data['offeredEquipmentSource'], 'equipment');
    expect(data['offeredEquipmentDetails'], '');
    expect(data['offeredEquipmentImageUrl'], 'https://example.com/listed.jpg');
    expect(data['offeredEquipmentImagePublicId'], isNull);
  });
  test('accepted, rejected, cancelled, completed and non-owner requests reject edits', () async {
    for (final status in ['accepted', 'rejected', 'cancelled', 'completed']) {
      store.records['exchange_requests/request']!['status'] = status;
      await expectLater(editInline(), throwsException);
      expect(
        store.records['exchange_requests/request']!['message'],
        'Original',
      );
    }
    store.records['exchange_requests/request']!.addAll({
      'status': 'pending',
      'senderId': 'other',
    });
    await expectLater(editInline(), throwsException);
    expect(store.records['exchange_requests/request']!['message'], 'Original');
  });
  test(
    'accept racing with save forces revalidation and prevents the edit',
    () async {
      store.providerAcceptsDuringEdit = true;
      await expectLater(editInline(), throwsException);
      expect(store.attempts, 2);
      expect(store.records['exchange_requests/request']!['status'], 'accepted');
      expect(
        store.records['exchange_requests/request']!['message'],
        'Original',
      );
    },
  );
  test('another owner, unavailable or the requested equipment cannot replace an offer', () async {
    for (final patch in [
      {'providerId': 'other'},
      {'isAvailable': false},
    ]) {
      store.records['equipment/owned']!.addAll(patch);
      await expectLater(
        service.updateExchangeRequest(
          exchangeRequestId: 'request',
          offeredEquipmentId: 'owned',
          offeredEquipmentName: 'Name',
          message: 'Changed',
        ),
        throwsException,
      );
      expect(
        store.records['exchange_requests/request']!['message'],
        'Original',
      );
      store.records['equipment/owned']!.addAll({
        'providerId': 'player',
        'isAvailable': true,
      });
    }
    store.records['equipment/wanted'] = {...store.records['equipment/owned']!};
    await expectLater(
      service.updateExchangeRequest(
        exchangeRequestId: 'request',
        offeredEquipmentId: 'wanted',
        offeredEquipmentName: 'Requested item',
        message: 'Changed',
      ),
      throwsException,
    );
    expect(
      ExchangeEditPolicy.canEdit({
        'senderId': 'player',
        'status': 'pending',
        'respondedAt': Timestamp(1, 0),
      }, 'player'),
      isFalse,
    );
  });
}
