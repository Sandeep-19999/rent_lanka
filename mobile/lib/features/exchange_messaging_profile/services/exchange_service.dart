import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'notification_service.dart';

class ExchangeService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  ExchangeService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  String get currentUserId {
    final User? user = _auth.currentUser;

    if (user == null) {
      throw Exception(
        'You must be logged in to use exchange requests.',
      );
    }

    return user.uid;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchMyEquipment() {
    return _firestore
        .collection('equipment')
        .where(
          'providerId',
          isEqualTo: currentUserId,
        )
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
      throw Exception(
        'Requested provider information is missing.',
      );
    }

    if (requestedProviderId == senderId) {
      throw Exception(
        'You cannot send an exchange request to yourself.',
      );
    }

    if (requestedEquipmentId == offeredEquipmentId) {
      throw Exception(
        'Requested and offered equipment cannot be the same.',
      );
    }

    final reference =
        _firestore.collection('exchange_requests').doc();

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

    final NotificationService notificationService =
        NotificationService(
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
    } catch (_) {}

    return reference.id;
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>>
      watchExchangeRequest(
    String exchangeRequestId,
  ) {
    return _firestore
        .collection('exchange_requests')
        .doc(exchangeRequestId)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>>
      watchMySentExchangeRequests() {
    return _firestore
        .collection('exchange_requests')
        .where(
          'senderId',
          isEqualTo: currentUserId,
        )
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>>
      watchIncomingExchangeRequests() {
    return _firestore
        .collection('exchange_requests')
        .where(
          'requestedProviderId',
          isEqualTo: currentUserId,
        )
        .snapshots();
  }

  Future<String> getUserDisplayName(
    String userId,
  ) async {
    if (userId.isEmpty) {
      return 'Rent Lanka User';
    }

    try {
      final document = await _firestore
          .collection('users')
          .doc(userId)
          .get();

      final data = document.data();

      final String name =
          data?['name']?.toString().trim() ?? '';

      if (name.isNotEmpty) {
        return name;
      }

      final String email =
          data?['email']?.toString().trim() ?? '';

      if (email.isNotEmpty) {
        return email.split('@').first;
      }
    } catch (_) {}

    return 'Rent Lanka User';
  }

  Future<void> respondToExchangeRequest({
    required String exchangeRequestId,
    required bool accept,
  }) async {
    final reference = _firestore
        .collection('exchange_requests')
        .doc(exchangeRequestId);

    String senderId = '';
    String requestedEquipment = 'equipment';
    String offeredEquipment = 'equipment';

    await _firestore.runTransaction(
      (transaction) async {
        final snapshot =
            await transaction.get(reference);

        if (!snapshot.exists) {
          throw Exception(
            'Exchange request not found.',
          );
        }

        final data = snapshot.data() ?? {};

        final String providerId =
            data['requestedProviderId']
                    ?.toString() ??
                '';

        senderId =
            data['senderId']?.toString() ?? '';

        requestedEquipment =
            data['requestedEquipmentName']
                    ?.toString() ??
                'equipment';

        offeredEquipment =
            data['offeredEquipmentName']
                    ?.toString() ??
                'equipment';

        final String status =
            data['status']
                    ?.toString()
                    .toLowerCase() ??
                'pending';

        if (providerId != currentUserId) {
          throw Exception(
            'You are not allowed to respond to this request.',
          );
        }

        if (status != 'pending') {
          throw Exception(
            'This exchange request has already been responded to.',
          );
        }

        transaction.update(
          reference,
          {
            'status':
                accept ? 'accepted' : 'rejected',
            'respondedAt':
                FieldValue.serverTimestamp(),
            'updatedAt':
                FieldValue.serverTimestamp(),
          },
        );
      },
    );

    if (senderId.isEmpty) {
      return;
    }

    final NotificationService notificationService =
        NotificationService(
      firestore: _firestore,
      auth: _auth,
    );

    try {
      await notificationService.createNotificationForUser(
        userId: senderId,
        title: accept
            ? 'Exchange request accepted'
            : 'Exchange request declined',
        message: accept
            ? 'Your offer of $offeredEquipment for $requestedEquipment was accepted.'
            : 'Your offer of $offeredEquipment for $requestedEquipment was declined.',
        type: 'exchange',
        referenceId: exchangeRequestId,
      );
    } catch (_) {}
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
      throw Exception(
        'Exchange request not found.',
      );
    }

    final data = document.data() ?? {};

    final String senderId =
        data['senderId']?.toString() ?? '';

    final String status =
        data['status']
                ?.toString()
                .toLowerCase() ??
            'pending';

    if (senderId != currentUserId) {
      throw Exception(
        'You cannot edit this exchange request.',
      );
    }

    if (status != 'pending') {
      throw Exception(
        'Only pending exchange requests can be edited.',
      );
    }

    await reference.update({
      'offeredEquipmentId':
          offeredEquipmentId,
      'offeredEquipmentName':
          offeredEquipmentName,
      'message': message.trim(),
      'updatedAt':
          FieldValue.serverTimestamp(),
    });
  }

  Future<void> cancelExchangeRequest(
    String exchangeRequestId,
  ) async {
    final reference = _firestore
        .collection('exchange_requests')
        .doc(exchangeRequestId);

    final document = await reference.get();

    if (!document.exists) {
      throw Exception(
        'Exchange request not found.',
      );
    }

    final data = document.data() ?? {};

    final String senderId =
        data['senderId']?.toString() ?? '';

    final String status =
        data['status']
                ?.toString()
                .toLowerCase() ??
            'pending';

    if (senderId != currentUserId) {
      throw Exception(
        'You cannot cancel this exchange request.',
      );
    }

    if (status != 'pending') {
      throw Exception(
        'Only pending exchange requests can be cancelled.',
      );
    }

    await reference.update({
      'status': 'cancelled',
      'updatedAt':
          FieldValue.serverTimestamp(),
    });

    final String providerId =
        data['requestedProviderId']
                ?.toString() ??
            '';

    final String requestedEquipment =
        data['requestedEquipmentName']
                ?.toString() ??
            'equipment';

    if (providerId.isNotEmpty) {
      final NotificationService notificationService =
          NotificationService(
        firestore: _firestore,
        auth: _auth,
      );

      try {
        await notificationService
            .createNotificationForUser(
          userId: providerId,
          title:
              'Exchange request cancelled',
          message:
              'The exchange request for $requestedEquipment was cancelled.',
          type: 'exchange',
          referenceId: exchangeRequestId,
        );
      } catch (_) {}
    }
  }
}