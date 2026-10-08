import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../services/auth_service.dart';
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

  CollectionReference<Map<String, dynamic>>
      get _equipmentCollection =>
          _firestore.collection('equipment');

  // =========================================================
  // PROVIDER REQUEST LIST
  // =========================================================

  Stream<List<RentalRequestModel>>
      watchMyRentalRequests() {
    return _requestsCollection
        .where(
          'providerId',
          isEqualTo: AuthService.providerId,
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
  ) {
    return _requestsCollection
        .doc(requestId)
        .snapshots()
        .map(
          (document) => document.exists
              ? RentalRequestModel.fromFirestore(
                  document,
                )
              : null,
        );
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

    return RentalRequestModel.fromFirestore(
      document,
    );
  }

  // =========================================================
  // UPDATE STATUS
  // =========================================================

  Future<void> updateStatus({
    required String requestId,
    required String status,
  }) async {
    await _requestsCollection
        .doc(requestId)
        .update({
      'status': status,
      'statusUpdatedAt':
          FieldValue.serverTimestamp(),
    });
  }

  // =========================================================
  // ACCEPT REQUEST + RESERVE DATES
  // =========================================================

  Future<void> acceptRequest(
    RentalRequestModel request,
  ) async {
    final String equipmentId =
        request.equipmentId.trim();

    final String startDate =
        request.startDate.trim();

    final String endDate =
        request.endDate.trim();

    if (equipmentId.isEmpty ||
        startDate.isEmpty ||
        endDate.isEmpty) {
      throw Exception(
        'Request information is incomplete.',
      );
    }

    final DateTime? start =
        DateTime.tryParse(startDate);

    final DateTime? end =
        DateTime.tryParse(endDate);

    if (start == null || end == null) {
      throw Exception(
        'Invalid rental dates.',
      );
    }

    if (start.isAfter(end)) {
      throw Exception(
        'Start date cannot be after end date.',
      );
    }

    final List<String> requestedDates = [];

    DateTime currentDate = DateTime(
      start.year,
      start.month,
      start.day,
    );

    final DateTime finalDate = DateTime(
      end.year,
      end.month,
      end.day,
    );

    while (!currentDate.isAfter(finalDate)) {
      requestedDates.add(
        _formatDate(currentDate),
      );

      currentDate = currentDate.add(
        const Duration(days: 1),
      );
    }

    final equipmentRef =
        _equipmentCollection.doc(
      equipmentId,
    );

    final requestRef =
        _requestsCollection.doc(
      request.id,
    );

    await _firestore.runTransaction(
      (transaction) async {
        final equipmentSnapshot =
            await transaction.get(
          equipmentRef,
        );

        if (!equipmentSnapshot.exists) {
          throw Exception(
            'Equipment could not be found.',
          );
        }

        final equipmentData =
            equipmentSnapshot.data() ?? {};

        final bool isAvailable =
            equipmentData['isAvailable'] != false;

        if (!isAvailable) {
          throw Exception(
            'This equipment is currently unavailable.',
          );
        }

        final dynamic unavailableValue =
            equipmentData['unavailableDates'];

        final Set<String> unavailableDates = {};

        if (unavailableValue is List) {
          unavailableDates.addAll(
            unavailableValue.map(
              (date) => date.toString(),
            ),
          );
        }

        final List<String> conflictDates =
            requestedDates
                .where(
                  (date) =>
                      unavailableDates.contains(
                    date,
                  ),
                )
                .toList();

        if (conflictDates.isNotEmpty) {
          throw Exception(
            'Equipment is unavailable on '
            '${conflictDates.join(', ')}.',
          );
        }

        final requestSnapshot =
            await transaction.get(
          requestRef,
        );

        if (!requestSnapshot.exists) {
          throw Exception(
            'Rental request could not be found.',
          );
        }

        final requestData =
            requestSnapshot.data() ?? {};

        final String currentStatus =
            requestData['status']
                    ?.toString()
                    .toLowerCase() ??
                'pending';

        if (currentStatus != 'pending') {
          throw Exception(
            'This request has already been updated.',
          );
        }

        transaction.update(
          equipmentRef,
          {
            'unavailableDates':
                FieldValue.arrayUnion(
              requestedDates,
            ),
            'availabilityUpdatedAt':
                FieldValue.serverTimestamp(),
          },
        );

        transaction.update(
          requestRef,
          {
            'status': 'accepted',
            'reservedDates': requestedDates,
            'statusUpdatedAt':
                FieldValue.serverTimestamp(),
            'availabilityCheckedAt':
                FieldValue.serverTimestamp(),
            'datesReservedAt':
                FieldValue.serverTimestamp(),
          },
        );
      },
    );
  }

  // =========================================================
  // CONFIRM HANDOVER
  // accepted -> active
  // =========================================================

  Future<void> confirmHandover(
    String requestId,
  ) async {
    final requestRef =
        _requestsCollection.doc(
      requestId,
    );

    await _firestore.runTransaction(
      (transaction) async {
        final snapshot =
            await transaction.get(
          requestRef,
        );

        if (!snapshot.exists) {
          throw Exception(
            'Rental request could not be found.',
          );
        }

        final data =
            snapshot.data() ?? {};

        final String status =
            data['status']
                    ?.toString()
                    .toLowerCase() ??
                '';

        if (status == 'completed') {
          throw Exception(
            'This rental has already been completed.',
          );
        }

        if (data['handoverConfirmed'] == true) {
          throw Exception(
            'Handover has already been confirmed.',
          );
        }

        if (status != 'accepted') {
          throw Exception(
            'Only an accepted request can be handed over.',
          );
        }

        transaction.update(
          requestRef,
          {
            'handoverConfirmed': true,
            'handoverConfirmedAt':
                FieldValue.serverTimestamp(),
            'status': 'active',
            'statusUpdatedAt':
                FieldValue.serverTimestamp(),
          },
        );
      },
    );
  }

  // =========================================================
  // CONFIRM RETURN
  // active -> completed
  // =========================================================

  Future<void> confirmReturn({
    required String requestId,
    required bool returnedWithoutDamage,
    required bool depositRefunded,
  }) async {
    if (!returnedWithoutDamage ||
        !depositRefunded) {
      throw Exception(
        'Please complete both condition checks.',
      );
    }

    final requestRef =
        _requestsCollection.doc(
      requestId,
    );

    await _firestore.runTransaction(
      (transaction) async {
        final snapshot =
            await transaction.get(
          requestRef,
        );

        if (!snapshot.exists) {
          throw Exception(
            'Rental request could not be found.',
          );
        }

        final data =
            snapshot.data() ?? {};

        final String status =
            data['status']
                    ?.toString()
                    .toLowerCase() ??
                '';

        final bool handoverConfirmed =
            data['handoverConfirmed'] == true;

        if (status == 'completed') {
          throw Exception(
            'This rental has already been completed.',
          );
        }

        if (!handoverConfirmed) {
          throw Exception(
            'Please confirm the handover first.',
          );
        }

        if (status != 'active') {
          throw Exception(
            'Only an active rental can be returned.',
          );
        }

        transaction.update(
          requestRef,
          {
            'returnedWithoutDamage':
                returnedWithoutDamage,
            'depositRefunded':
                depositRefunded,
            'returnConfirmed': true,
            'returnConfirmedAt':
                FieldValue.serverTimestamp(),
            'status': 'completed',
            'statusUpdatedAt':
                FieldValue.serverTimestamp(),
          },
        );
      },
    );
  }

  // =========================================================
  // DATE FORMAT
  // =========================================================

  String _formatDate(
    DateTime date,
  ) {
    final String year = date.year
        .toString()
        .padLeft(4, '0');

    final String month = date.month
        .toString()
        .padLeft(2, '0');

    final String day = date.day
        .toString()
        .padLeft(2, '0');

    return '$year-$month-$day';
  }
}