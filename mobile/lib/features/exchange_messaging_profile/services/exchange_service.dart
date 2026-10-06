import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/exchange_request_model.dart';

class ExchangeService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  ExchangeService({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  String get currentUserId {
    final user = _auth.currentUser;

    if (user != null) {
      return user.uid;
    }

    // Temporary fallback while authentication
    // integration is still being completed.
    return 'demo_provider';
  }

  // READ:
  // Load equipment belonging to the
  // currently logged-in user.
  Stream<QuerySnapshot<Map<String, dynamic>>> watchMyEquipment() {
    return _firestore
        .collection('equipment')
        .where('providerId', isEqualTo: currentUserId)
        .snapshots();
  }

  // CREATE:
  // Create a new exchange request.
  Future<String> sendExchangeRequest({
    required String requestedProviderId,
    required String requestedEquipmentId,
    required String requestedEquipmentName,
    required String offeredEquipmentId,
    required String offeredEquipmentName,
    required String message,
  }) async {
    final request = ExchangeRequestModel(
      senderId: currentUserId,
      requestedProviderId: requestedProviderId,
      requestedEquipmentId: requestedEquipmentId,
      requestedEquipmentName: requestedEquipmentName,
      offeredEquipmentId: offeredEquipmentId,
      offeredEquipmentName: offeredEquipmentName,
      message: message.trim(),
      status: 'pending',
    );

    final document = await _firestore.collection('exchange_requests').add({
      ...request.toMap(),

      'createdAt': FieldValue.serverTimestamp(),

      'updatedAt': FieldValue.serverTimestamp(),
    });

    return document.id;
  }

  // READ:
  // Watch one exchange request in real time.
  Stream<DocumentSnapshot<Map<String, dynamic>>> watchExchangeRequest(
    String exchangeRequestId,
  ) {
    return _firestore
        .collection('exchange_requests')
        .doc(exchangeRequestId)
        .snapshots();
  }

  // READ:
  // Load requests sent by current user.
  Stream<QuerySnapshot<Map<String, dynamic>>> watchMySentExchangeRequests() {
    return _firestore
        .collection('exchange_requests')
        .where('senderId', isEqualTo: currentUserId)
        .snapshots();
  }

  // UPDATE:
  // Cancel a pending exchange request.
  Future<void> cancelExchangeRequest(String exchangeRequestId) async {
    await _firestore
        .collection('exchange_requests')
        .doc(exchangeRequestId)
        .update({
          'status': 'cancelled',
          'updatedAt': FieldValue.serverTimestamp(),
        });
  }
}
