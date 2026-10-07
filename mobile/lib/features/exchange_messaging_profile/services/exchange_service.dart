import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'notification_service.dart';

class ExchangeService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  ExchangeService({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  String get currentUserId {
    final User? user = _auth.currentUser;

    if (user == null) {
      throw Exception('You must be logged in to use exchange requests.');
    }

    return user.uid;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchMyEquipment() {
    return _firestore
        .collection('equipment')
        .where('providerId', isEqualTo: currentUserId)
        .snapshots();
  }

  Future<String> sendExchangeRequest({
    required String requestedProviderId,
    required String requestedEquipmentId,
    required String requestedEquipmentName,
    required String offeredEquipmentId,
    required String offeredEquipmentName,
    required String message,
  }) async {
    final String senderId = currentUserId;

    if (requestedProviderId.isEmpty) {
      throw Exception('Requested provider information is missing.');
    }

    if (requestedProviderId == senderId) {
      throw Exception('You cannot send an exchange request to yourself.');
    }

    if (requestedEquipmentId == offeredEquipmentId) {
      throw Exception('Requested and offered equipment cannot be the same.');
    }

    final reference = _firestore.collection('exchange_requests').doc();

    await reference.set({
      'senderId': senderId,
      'requestedProviderId': requestedProviderId,
      'requestedEquipmentId': requestedEquipmentId,
      'requestedEquipmentName': requestedEquipmentName,
      'offeredEquipmentId': offeredEquipmentId,
      'offeredEquipmentName': offeredEquipmentName,
      'message': message.trim(),
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    final NotificationService notificationService = NotificationService(
      firestore: _firestore,
      auth: _auth,
    );

    try {
      await notificationService.createNotificationForUser(
        userId: requestedProviderId,
        title: 'New exchange request',
        message:
            '$offeredEquipmentName was offered for $requestedEquipmentName.',
        type: 'exchange',
        referenceId: reference.id,
      );
    } catch (_) {
      // The exchange request has already been saved.
      // A notification failure should not duplicate
      // the exchange request if the user retries.
    }

    return reference.id;
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> watchExchangeRequest(
    String exchangeRequestId,
  ) {
    return _firestore
        .collection('exchange_requests')
        .doc(exchangeRequestId)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchMySentExchangeRequests() {
    return _firestore
        .collection('exchange_requests')
        .where('senderId', isEqualTo: currentUserId)
        .snapshots();
  }

  Future<void> updateExchangeRequest({
    required String exchangeRequestId,
    required String offeredEquipmentId,
    required String offeredEquipmentName,
    required String message,
  }) async {
    final reference = _firestore
        .collection('exchange_requests')
        .doc(exchangeRequestId);

    final document = await reference.get();

    if (!document.exists) {
      throw Exception('Exchange request not found.');
    }

    final data = document.data() ?? {};

    final String senderId = data['senderId']?.toString() ?? '';

    final String status = data['status']?.toString().toLowerCase() ?? 'pending';

    if (senderId != currentUserId) {
      throw Exception('You cannot edit this exchange request.');
    }

    if (status != 'pending') {
      throw Exception('Only pending exchange requests can be edited.');
    }

    await reference.update({
      'offeredEquipmentId': offeredEquipmentId,
      'offeredEquipmentName': offeredEquipmentName,
      'message': message.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> cancelExchangeRequest(String exchangeRequestId) async {
    final reference = _firestore
        .collection('exchange_requests')
        .doc(exchangeRequestId);

    final document = await reference.get();

    if (!document.exists) {
      throw Exception('Exchange request not found.');
    }

    final data = document.data() ?? {};

    final String senderId = data['senderId']?.toString() ?? '';

    final String status = data['status']?.toString().toLowerCase() ?? 'pending';

    if (senderId != currentUserId) {
      throw Exception('You cannot cancel this exchange request.');
    }

    if (status != 'pending') {
      throw Exception('Only pending exchange requests can be cancelled.');
    }

    await reference.update({
      'status': 'cancelled',
      'updatedAt': FieldValue.serverTimestamp(),
    });

    final String providerId = data['requestedProviderId']?.toString() ?? '';

    final String requestedEquipment =
        data['requestedEquipmentName']?.toString() ?? 'equipment';

    if (providerId.isNotEmpty) {
      final NotificationService notificationService = NotificationService(
        firestore: _firestore,
        auth: _auth,
      );

      try {
        await notificationService.createNotificationForUser(
          userId: providerId,
          title: 'Exchange request cancelled',
          message:
              'The exchange request for $requestedEquipment was cancelled.',
          type: 'exchange',
          referenceId: exchangeRequestId,
        );
      } catch (_) {}
    }
  }
}
