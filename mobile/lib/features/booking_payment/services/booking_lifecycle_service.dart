import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../utils/date_utils.dart';

/// Separates manual blocks from individually-owned booking reservations.
class ReservationDates {
  static List<String> dates(dynamic value) => value is List
      ? value.map((item) => item.toString()).toList()
      : <String>[];

  static Map<String, dynamic> reservations(Map<String, dynamic> data) =>
      data['rentalReservations'] is Map
      ? Map<String, dynamic>.from(data['rentalReservations'])
      : {};

  static Set<String> manual(Map<String, dynamic> data) =>
      dates(data['manualUnavailableDates'] ?? data['unavailableDates']).toSet();

  static Set<String> effective(
    Map<String, dynamic> data, {
    String? excluding,
  }) => {
    ...manual(data),
    for (final entry in reservations(data).entries)
      if (entry.key != excluding) ...dates(entry.value),
  };

  static Map<String, dynamic> change(
    Map<String, dynamic> data,
    String bookingId,
    List<String>? reservation,
  ) {
    final entries = reservations(data);
    if (reservation == null) {
      entries.remove(bookingId);
    } else {
      entries[bookingId] = reservation;
    }
    return {
      'manualUnavailableDates': manual(data).toList()..sort(),
      'rentalReservations': entries,
      'unavailableDates': effective({
        'manualUnavailableDates': manual(data).toList(),
        'rentalReservations': entries,
      }).toList()..sort(),
      'availabilityUpdatedAt': FieldValue.serverTimestamp(),
    };
  }

  static Map<String, dynamic> manualSelection(
    Map<String, dynamic> data,
    List<String> selected,
  ) {
    final reserved = reservations(data).values.expand(dates).toSet();
    final requested = selected.toSet();
    if (!requested.containsAll(reserved)) {
      throw StateError(
        'Reserved rental dates cannot be unblocked here. Complete or cancel the rental first.',
      );
    }
    final manualDates = requested.difference(reserved)
      ..addAll(manual(data).intersection(requested));
    return {
      'manualUnavailableDates': manualDates.toList()..sort(),
      'unavailableDates': {...manualDates, ...reserved}.toList()..sort(),
    };
  }

  static bool canTransition(String from, String to) => switch (to) {
    'accepted' || 'rejected' => from == 'pending',
    'active' => from == 'accepted',
    'completed' => from == 'active',
    'cancelled' => from == 'pending' || from == 'accepted',
    _ => false,
  };
}

class BookingLifecycleService {
  final FirebaseFirestore db;
  BookingLifecycleService(this.db);

  Future<void> transition(
    String bookingId,
    String status, {
    String reason = '',
    bool returnedWithoutDamage = false,
    bool depositRefunded = false,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('Please log in to manage rentals.');
    final requestRef = db.collection('rental_requests').doc(bookingId);
    await db.runTransaction((transaction) async {
      if (FirebaseAuth.instance.currentUser?.uid != uid) {
        throw StateError('Your login changed. Please reopen the request.');
      }
      final requestDoc = await transaction.get(requestRef);
      if (!requestDoc.exists) throw Exception('Rental request not found.');
      final data = requestDoc.data()!;
      final ownerKey = status == 'cancelled' ? 'playerId' : 'providerId';
      if (data[ownerKey] != uid) {
        throw Exception('This rental does not belong to you.');
      }
      final current = data['status']?.toString().toLowerCase() ?? '';
      final sameStatus = current == status;
      if (!sameStatus && !ReservationDates.canTransition(current, status)) {
        throw Exception('This rental cannot change from $current to $status.');
      }
      if (!sameStatus &&
          status == 'completed' &&
          (!returnedWithoutDamage || !depositRefunded)) {
        throw Exception('Please complete both return condition checks.');
      }
      final equipmentId = data['equipmentId']?.toString() ?? '';
      if (equipmentId.isEmpty) {
        throw Exception('Equipment information is missing.');
      }
      final equipmentRef = db.collection('equipment').doc(equipmentId);
      final equipmentDoc = await transaction.get(equipmentRef);
      final equipment = equipmentDoc.data();
      final start = AppDates.parseKey(data['startDate']?.toString() ?? '');
      final end = AppDates.parseKey(data['endDate']?.toString() ?? '');
      if (start == null || end == null || end.isBefore(start)) {
        throw Exception('Rental dates are invalid.');
      }
      final dates = AppDates.daysInRange(start, end).map(AppDates.key).toList();
      final blocking = ['pending', 'accepted', 'active'].contains(status);
      if (blocking && equipment == null) {
        throw Exception('Equipment no longer exists.');
      }
      if (!sameStatus && status == 'accepted' && equipment != null) {
        if (equipment['isAvailable'] == false ||
            dates.any(
              ReservationDates.effective(
                equipment,
                excluding: bookingId,
              ).contains,
            )) {
          throw Exception('Equipment is unavailable on the requested dates.');
        }
      }
      final now = FieldValue.serverTimestamp();
      final refund = status == 'cancelled' && data['paymentStatus'] == 'paid';
      if (!sameStatus) {
        transaction.update(requestRef, {
          'status': status,
          'statusUpdatedAt': now,
          if (status == 'accepted') 'reservedDates': dates,
          if (status == 'active') ...{
            'handoverConfirmed': true,
            'handoverConfirmedAt': now,
          },
          if (status == 'completed') ...{
            'returnConfirmed': true,
            'returnConfirmedAt': now,
            'returnedWithoutDamage': returnedWithoutDamage,
            'depositRefunded': depositRefunded,
          },
          if (status == 'cancelled') ...{
            'cancelReason': reason.trim(),
            'cancelledAt': now,
            if (refund) 'paymentStatus': 'refunded',
          },
        });
      }
      transaction.set(db.collection('booking_slots').doc(bookingId), {
        'equipmentId': equipmentId,
        'startDate': data['startDate'],
        'endDate': data['endDate'],
        'status': status,
        'updatedAt': now,
      }, SetOptions(merge: true));
      if (equipment != null) {
        transaction.update(
          equipmentRef,
          ReservationDates.change(
            equipment,
            bookingId,
            blocking ? dates : null,
          ),
        );
      }
      if (sameStatus) {
        return; // Reconcile availability without repeating side effects.
      }
      if (refund) {
        transaction.set(db.collection('payments').doc('${bookingId}_refund'), {
          'bookingId': bookingId,
          'bookingReference': data['bookingReference'] ?? '',
          'playerId': data['playerId'],
          'providerId': data['providerId'],
          'type': 'refund',
          'method': data['paymentMethod'],
          'amount': data['totalPayable'],
          'currency': 'LKR',
          'status': 'refunded',
          'transactionId': data['transactionId'] ?? '',
          'createdAt': now,
        });
      }
      final playerId = data['playerId']?.toString() ?? '';
      final messages = {
        'accepted': 'Your rental request has been accepted.',
        'rejected': 'Your rental request was declined.',
        'active': 'Equipment handover confirmed.',
        'completed': 'Rental completed.',
        'cancelled': 'Booking cancelled.',
      };
      if (playerId.isNotEmpty) {
        transaction.set(
          db.collection('notifications').doc('${bookingId}_${status}_player'),
          {
            'userId': playerId,
            'title': messages[status],
            'message': '${data['equipmentName'] ?? ''}: ${messages[status]}',
            'type': 'booking',
            'referenceId': bookingId,
            'bookingId': bookingId,
            'isRead': false,
            'createdAt': now,
          },
        );
      }
      if (status == 'cancelled') {
        transaction.set(
          db.collection('notifications').doc('${bookingId}_cancelled_provider'),
          {
            'userId': data['providerId'],
            'title': 'Booking cancelled by player',
            'message': '${data['equipmentName'] ?? ''}: Booking cancelled.',
            'type': 'rental_request',
            'referenceId': bookingId,
            'bookingId': bookingId,
            'isRead': false,
            'createdAt': now,
          },
        );
      }
    });
  }
}
