import '../../booking_payment/services/booking_lifecycle_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';
import '../models/rental_request_model.dart';

class RentalRequestService {
  final FirebaseFirestore _firestore;

  RentalRequestService({
    FirebaseFirestore? firestore,
  }) : _firestore =
            firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>>
      get _requestsCollection =>
          _firestore.collection('rental_requests');



  // =========================================================
  // PROVIDER REQUEST LIST
  // =========================================================

  String get _providerId {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw StateError('Please log in to manage requests.');
    return uid;
  }

  Stream<List<RentalRequestModel>>
      watchMyRentalRequests() async* {
    yield* _requestsCollection
        .where(
          'providerId',
          isEqualTo: _providerId,
        )
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                RentalRequestModel.fromFirestore,
              )
              .toList(),
        );
  }

  // =========================================================
  // SINGLE REQUEST - LIVE
  // =========================================================

  Stream<RentalRequestModel?> watchRentalRequest(
    String requestId,
  ) async* {
    final uid = _providerId;
    yield* _requestsCollection
        .doc(requestId)
        .snapshots()
        .map((document) {
          if (!document.exists) return null;
          final request = RentalRequestModel.fromFirestore(document);
          if (request.providerId != uid) throw StateError('This request does not belong to you.');
          return request;
        });
  }

  // =========================================================
  // SINGLE REQUEST - ONCE
  // =========================================================

  Future<RentalRequestModel?> getRentalRequest(
    String requestId,
  ) async {
    final document =
        await _requestsCollection
            .doc(requestId)
            .get();

    if (!document.exists) {
      return null;
    }

    final request = RentalRequestModel.fromFirestore(document);
    if (request.providerId != _providerId) throw StateError('This request does not belong to you.');
    return request;
  }

  // =========================================================
  // UPDATE STATUS
  // =========================================================

  Future<void> updateStatus({required String requestId, required String status}) =>
      BookingLifecycleService(_firestore).transition(requestId, status);

  Future<void> acceptRequest(RentalRequestModel request) =>
      BookingLifecycleService(_firestore).transition(request.id, 'accepted');

  Future<void> confirmHandover(String requestId) =>
      BookingLifecycleService(_firestore).transition(requestId, 'active');

  Future<void> confirmReturn({required String requestId,
    required bool returnedWithoutDamage, required bool depositRefunded}) =>
      BookingLifecycleService(_firestore).transition(requestId, 'completed',
        returnedWithoutDamage: returnedWithoutDamage, depositRefunded: depositRefunded);
}
