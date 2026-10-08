import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/booking_model.dart';
import '../models/equipment_model.dart';
import '../utils/date_utils.dart';
import '../../../services/auth_service.dart';
import 'payment_service.dart';

class BookingException implements Exception {
  final String message;
  const BookingException(this.message);

  @override
  String toString() => message;
}

/// Everything the player chose before paying, passed from the
/// Booking screen through Summary and Payment.
class BookingDraft {
  final Equipment equipment;
  final DateTime startDate;
  final DateTime endDate;
  final PickupMethod pickupMethod;
  final String deliveryAddress;
  final String note;

  const BookingDraft({
    required this.equipment,
    required this.startDate,
    required this.endDate,
    required this.pickupMethod,
    this.deliveryAddress = '',
    this.note = '',
  });

  int get rentalDays => AppDates.rentalDays(startDate, endDate);

  PriceBreakdown get price => PriceBreakdown.calculate(
        pricePerDay: equipment.pricePerDay,
        rentalDays: rentalDays,
        pickupMethod: pickupMethod,
        deposit: equipment.depositAmount,
      );

  String get pickupLocation {
    switch (pickupMethod) {
      case PickupMethod.delivery:
        return deliveryAddress;
      case PickupMethod.shopPickup:
      case PickupMethod.ownerPickup:
        return equipment.location.isNotEmpty
            ? equipment.location
            : 'Provider location';
    }
  }
}

/// Firestore backend for Equipment Details, Booking, Payment,
/// Booking Confirmation and My Bookings.
///
/// Collections:
/// - `equipment`        listings (written by the provider screens)
/// - `rental_requests`  bookings (shared with provider Rental Requests)
/// - `booking_slots`    dates + status only, keyed by booking id, so players
///                      can check availability without reading other
///                      players' bookings (names, addresses)
/// - `payments`         one record per payment / refund
/// - `notifications`    booking + payment notifications for both users
class BookingService {
  BookingService({FirebaseFirestore? firestore, PaymentService? payments})
      : _db = firestore ?? FirebaseFirestore.instance,
        _payments = payments ?? PaymentService();

  final FirebaseFirestore _db;
  final PaymentService _payments;

  String _requirePlayerId() {
    try {
      return AuthService.playerId;
    } on StateError {
      throw const BookingException('Please log in to access bookings.');
    }
  }

  static const int maxRentalDays = 30;
  static const int bookingWindowDays = 90;

  CollectionReference<Map<String, dynamic>> get _equipment =>
      _db.collection('equipment');
  CollectionReference<Map<String, dynamic>> get _bookings =>
      _db.collection('rental_requests');
  CollectionReference<Map<String, dynamic>> get _slots =>
      _db.collection('booking_slots');
  CollectionReference<Map<String, dynamic>> get _paymentRecords =>
      _db.collection('payments');
  CollectionReference<Map<String, dynamic>> get _notifications =>
      _db.collection('notifications');

  // ---------------------------------------------------------------------------
  // Equipment Details
  // ---------------------------------------------------------------------------

  Stream<Equipment?> watchEquipment(String equipmentId) {
    return _equipment.doc(equipmentId).snapshots().map(
          (doc) => doc.exists ? Equipment.fromDoc(doc) : null,
        );
  }

  /// Available listings, used by the temporary browse screen until the
  /// Home / Search screens are connected.
  Stream<List<Equipment>> watchBookableEquipment() {
    return _equipment.where('isAvailable', isEqualTo: true).snapshots().map(
          (snapshot) => snapshot.docs.map(Equipment.fromDoc).toList()
            ..sort((a, b) => a.name.compareTo(b.name)),
        );
  }

  /// Dates that cannot be booked: provider-blocked dates plus every day
  /// covered by an existing pending / accepted / active booking.
  Future<Set<String>> unavailableDateKeys(Equipment equipment) async {
    final keys = <String>{...equipment.unavailableDates};

    // Single-field query (no composite index needed); status filtered here.
    final snapshot =
        await _slots.where('equipmentId', isEqualTo: equipment.id).get();

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final status = data['status']?.toString().toLowerCase() ?? '';
      if (!BookingStatus.blocking.contains(status)) continue;

      final start = AppDates.parseKey(data['startDate']?.toString() ?? '');
      final end = AppDates.parseKey(data['endDate']?.toString() ?? '');
      if (start == null || end == null) continue;

      keys.addAll(AppDates.daysInRange(start, end).map(AppDates.key));
    }
    return keys;
  }

  /// Returns an error message, or null when the range can be booked.
  static String? validateDates({
    required DateTime start,
    required DateTime end,
    required Set<String> unavailable,
    DateTime? today,
  }) {
    final firstAllowed = AppDates.dateOnly(today ?? DateTime.now());
    final startDay = AppDates.dateOnly(start);
    final endDay = AppDates.dateOnly(end);

    if (startDay.isBefore(firstAllowed)) {
      return 'Start date cannot be in the past.';
    }
    if (endDay.isBefore(startDay)) {
      return 'End date must be on or after the start date.';
    }
    if (AppDates.rentalDays(startDay, endDay) > maxRentalDays) {
      return 'Rentals can be at most $maxRentalDays days.';
    }

    final clash = AppDates.daysInRange(startDay, endDay)
        .map(AppDates.key)
        .where(unavailable.contains)
        .toList();
    if (clash.isNotEmpty) {
      return 'Not available on ${AppDates.prettyKey(clash.first)}'
          '${clash.length > 1 ? ' and ${clash.length - 1} other day(s)' : ''}. '
          'Please choose different dates.';
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Booking + Payment
  // ---------------------------------------------------------------------------

  /// Re-checks availability, takes payment, then writes the booking,
  /// payment record and notifications in one batch.
  ///
  /// Returns the new booking id. Throws [BookingException] with a
  /// user-facing message on failure.
  Future<String> confirmBooking({
    required BookingDraft draft,
    required PaymentMethod paymentMethod,
    CardDetails? card,
    String? bank,
  }) async {
    final playerId = _requirePlayerId();
    final equipmentDoc = await _equipment.doc(draft.equipment.id).get();
    if (!equipmentDoc.exists) {
      throw const BookingException('This equipment is no longer listed.');
    }
    final Equipment equipment;
    try {
      equipment = Equipment.fromDiscovery({
        ...equipmentDoc.data()!,
        'id': equipmentDoc.id,
      });
    } on FormatException catch (error) {
      throw BookingException(error.message);
    }
    if (!equipment.canBeBooked) {
      throw const BookingException(
          'This equipment is not available for booking right now.');
    }
    if (equipment.providerId == playerId) {
      throw const BookingException('You cannot book your own equipment.');
    }
    if (draft.pickupMethod == PickupMethod.delivery &&
        draft.deliveryAddress.trim().length < 5) {
      throw const BookingException('Please enter a delivery address.');
    }

    // Someone may have booked these dates while the player was on the
    // summary screen, so check again right before charging.
    final dateError = validateDates(
      start: draft.startDate,
      end: draft.endDate,
      unavailable: await unavailableDateKeys(equipment),
    );
    if (dateError != null) throw BookingException(dateError);

    // Price is recalculated from the latest listing, not trusted from the UI.
    final latestDraft = BookingDraft(
      equipment: equipment,
      startDate: draft.startDate,
      endDate: draft.endDate,
      pickupMethod: draft.pickupMethod,
      deliveryAddress: draft.deliveryAddress.trim(),
      note: draft.note.trim(),
    );
    final price = latestDraft.price;

    if (_requirePlayerId() != playerId) {
      throw const BookingException('Your login changed. Please start booking again.');
    }
    final payment = await _payments.process(
      method: paymentMethod,
      amount: price.totalPayable,
      card: card,
      bank: bank,
    );
    if (!payment.success) throw BookingException(payment.message);

    final bookingRef = _bookings.doc();
    final reference = Booking.referenceFor(bookingRef.id);
    final now = FieldValue.serverTimestamp();
    final period = AppDates.prettyRange(
      AppDates.key(latestDraft.startDate),
      AppDates.key(latestDraft.endDate),
    );

    final batch = _db.batch();

    batch.set(bookingRef, {
      'bookingReference': reference,
      'equipmentId': equipment.id,
      'equipmentName': equipment.name,
      'equipmentCategory': equipment.category,
      'providerId': equipment.providerId,
      'providerName': equipment.providerName,
      'playerId': playerId,
      'playerName': AuthService.playerName,
      'verifiedUser': AuthService.isEmailVerified,
      'startDate': AppDates.key(latestDraft.startDate),
      'endDate': AppDates.key(latestDraft.endDate),
      'startTimestamp': Timestamp.fromDate(latestDraft.startDate),
      'endTimestamp': Timestamp.fromDate(latestDraft.endDate),
      'rentalDays': price.rentalDays,
      'pickupMethod': latestDraft.pickupMethod.value,
      'pickupLocation': latestDraft.pickupLocation,
      'deliveryAddress': latestDraft.deliveryAddress,
      'note': latestDraft.note,
      'pricePerDay': price.pricePerDay,
      // Rental value only, which is what the provider dashboard totals.
      'totalAmount': price.rentalCost,
      'deliveryFee': price.deliveryFee,
      'serviceFee': price.serviceFee,
      'depositAmount': price.deposit,
      'totalPayable': price.totalPayable,
      'paymentMethod': paymentMethod.value,
      'paymentStatus': payment.paymentStatus,
      'transactionId': payment.transactionId,
      'cardLast4': payment.cardLast4,
      'status': BookingStatus.pending,
      'handoverConfirmed': false,
      'returnConfirmed': false,
      'createdAt': now,
      'statusUpdatedAt': now,
    });

    batch.set(_slots.doc(bookingRef.id), {
      'equipmentId': equipment.id,
      'startDate': AppDates.key(latestDraft.startDate),
      'endDate': AppDates.key(latestDraft.endDate),
      'status': BookingStatus.pending,
      'updatedAt': now,
    });

    batch.set(_paymentRecords.doc(), {
      'bookingId': bookingRef.id,
      'bookingReference': reference,
      'playerId': playerId,
      'providerId': equipment.providerId,
      'type': 'charge',
      'method': paymentMethod.value,
      'amount': price.totalPayable,
      'currency': 'LKR',
      'status': payment.paymentStatus,
      'transactionId': payment.transactionId,
      'cardLast4': payment.cardLast4,
      'bank': bank ?? '',
      'createdAt': now,
    });

    _addNotification(
      batch,
      userId: playerId,
      bookingId: bookingRef.id,
      type: 'booking',
      title: 'Booking request sent',
      message: '$reference: ${equipment.name} for $period. '
          'We will notify you when the provider responds.',
    );

    if (payment.paymentStatus == PaymentStatus.paid) {
      _addNotification(
        batch,
        userId: playerId,
        bookingId: bookingRef.id,
        type: 'payment',
        title: 'Payment confirmed',
        message: '${formatLkr(price.totalPayable)} paid for $reference '
            '(${payment.transactionId}).',
      );
    }

    _addNotification(
      batch,
      userId: equipment.providerId,
      bookingId: bookingRef.id,
      type: 'rental_request',
      title: 'New rental request',
      message: '${AuthService.playerName} wants to rent ${equipment.name} '
          'for $period.',
    );

    if (_requirePlayerId() != playerId) {
      throw const BookingException('Your login changed. Please start booking again.');
    }
    await batch.commit();
    return bookingRef.id;
  }

  // ---------------------------------------------------------------------------
  // My Bookings / Booking Details
  // ---------------------------------------------------------------------------

  Stream<List<Booking>> watchMyBookings() async* {
    final playerId = _requirePlayerId();
    // Sorted on the client to avoid needing a composite index.
    yield* _bookings
        .where('playerId', isEqualTo: playerId)
        .snapshots()
        .map((snapshot) {
      final bookings = snapshot.docs.map(Booking.fromDoc).toList();
      bookings.sort((a, b) {
        final aTime = a.createdAt ?? DateTime.now();
        final bTime = b.createdAt ?? DateTime.now();
        return bTime.compareTo(aTime);
      });
      return bookings;
    });
  }

  Stream<Booking?> watchBooking(String bookingId) async* {
    final playerId = _requirePlayerId();
    yield* _bookings.doc(bookingId).snapshots().map((doc) {
      if (!doc.exists) return null;
      final booking = Booking.fromDoc(doc);
      if (booking.playerId != playerId) {
        throw const BookingException('This booking does not belong to you.');
      }
      return booking;
    });
  }

  /// Cancels a pending/accepted booking and refunds a prepaid amount.
  Future<void> cancelBooking(String bookingId, {String reason = ''}) async {
    final playerId = _requirePlayerId();
    final bookingRef = _bookings.doc(bookingId);

    final booking = await _db.runTransaction<Booking>((transaction) async {
      final doc = await transaction.get(bookingRef);
      if (!doc.exists) throw const BookingException('Booking not found.');

      final booking = Booking.fromDoc(doc);
      if (booking.playerId != playerId) {
        throw const BookingException('You can only cancel your own bookings.');
      }
      if (!booking.canCancel) {
        throw const BookingException(
            'This booking can no longer be cancelled.');
      }

      final refund = booking.paymentStatus == PaymentStatus.paid;
      transaction.update(bookingRef, {
        'status': BookingStatus.cancelled,
        'cancelReason': reason.trim(),
        'cancelledAt': FieldValue.serverTimestamp(),
        'statusUpdatedAt': FieldValue.serverTimestamp(),
        if (refund) 'paymentStatus': PaymentStatus.refunded,
      });
      return booking;
    });

    final batch = _db.batch();

    _setSlotStatus(batch, bookingId, BookingStatus.cancelled);

    if (booking.paymentStatus == PaymentStatus.paid) {
      batch.set(_paymentRecords.doc(), {
        'bookingId': bookingId,
        'bookingReference': booking.bookingReference,
        'playerId': booking.playerId,
        'providerId': booking.providerId,
        'type': 'refund',
        'method': booking.paymentMethod.value,
        'amount': booking.totalPayable,
        'currency': 'LKR',
        'status': PaymentStatus.refunded,
        'transactionId': booking.transactionId,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    _addNotification(
      batch,
      userId: booking.playerId,
      bookingId: bookingId,
      type: 'booking',
      title: 'Booking cancelled',
      message: booking.paymentStatus == PaymentStatus.paid
          ? '${booking.bookingReference} was cancelled. '
              '${formatLkr(booking.totalPayable)} will be refunded.'
          : '${booking.bookingReference} was cancelled.',
    );
    _addNotification(
      batch,
      userId: booking.providerId,
      bookingId: bookingId,
      type: 'rental_request',
      title: 'Booking cancelled by player',
      message: '${booking.playerName} cancelled the booking for '
          '${booking.equipmentName}.',
    );

    await batch.commit();
  }

  /// Keeps the availability slot in step when the provider accepts,
  /// rejects or completes a booking, so rejected dates become free again.
  Future<void> syncSlotStatus(String bookingId, String status) async {
    final batch = _db.batch();
    _setSlotStatus(batch, bookingId, status);
    await batch.commit();
  }

  void _setSlotStatus(WriteBatch batch, String bookingId, String status) {
    batch.set(
      _slots.doc(bookingId),
      {'status': status, 'updatedAt': FieldValue.serverTimestamp()},
      SetOptions(merge: true),
    );
  }

  void _addNotification(
    WriteBatch batch, {
    required String userId,
    required String bookingId,
    required String type,
    required String title,
    required String message,
  }) {
    if (userId.isEmpty) return;
    batch.set(_notifications.doc(), {
      'userId': userId,
      'bookingId': bookingId,
      'type': type,
      'title': title,
      'message': message,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
