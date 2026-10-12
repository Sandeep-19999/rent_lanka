import 'booking_lifecycle_service.dart';
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

/// What the Edit Booking screen needs: the latest listing (for the new
/// price) and the days the booking cannot move to.
class BookingEditOptions {
  final Equipment equipment;
  final Set<String> unavailable;

  const BookingEditOptions({required this.equipment, required this.unavailable});
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
    return {
      ...equipment.unavailableDates,
      ...blockingSlotDays(await _slotsFor(equipment.id)),
    };
  }

  // Single-field query (no composite index needed); status filtered later.
  Future<Map<String, Map<String, dynamic>>> _slotsFor(String equipmentId) async {
    final snapshot =
        await _slots.where('equipmentId', isEqualTo: equipmentId).get();
    return {for (final doc in snapshot.docs) doc.id: doc.data()};
  }

  /// Every day held by a pending / accepted / active booking slot.
  /// [excludingBookingId] leaves out the booking that is being edited.
  static Set<String> blockingSlotDays(
    Map<String, Map<String, dynamic>> slots, {
    String? excludingBookingId,
  }) {
    final keys = <String>{};
    slots.forEach((bookingId, data) {
      if (bookingId == excludingBookingId) return;
      final status = data['status']?.toString().toLowerCase() ?? '';
      if (!BookingStatus.blocking.contains(status)) return;

      final start = AppDates.parseKey(data['startDate']?.toString() ?? '');
      final end = AppDates.parseKey(data['endDate']?.toString() ?? '');
      if (start == null || end == null) return;

      keys.addAll(AppDates.daysInRange(start, end).map(AppDates.key));
    });
    return keys;
  }

  /// Days an edited booking cannot move to: provider-blocked dates and other
  /// bookings' reservations. The booking's own current dates stay free.
  static Set<String> unavailableForEdit({
    required Map<String, dynamic> listing,
    required Map<String, Map<String, dynamic>> slots,
    required String bookingId,
  }) => {
    ...ReservationDates.effective(listing, excluding: bookingId),
    ...blockingSlotDays(slots, excludingBookingId: bookingId),
  };

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
    final profile = (await _db.collection('users').doc(playerId).get()).data() ?? {};
    final savedName = profile['name']?.toString().trim() ?? '';
    final playerName = savedName.isNotEmpty ? savedName : AuthService.playerName;
    if (playerName.isEmpty) throw const BookingException('Please add your name in Edit Profile before booking.');
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

    await _db.runTransaction((batch) async {
    final lockedEquipment = await batch.get(_equipment.doc(equipment.id));
    final listing = lockedEquipment.data();
    if (listing == null || listing['isAvailable'] == false ||
        listing['status']?.toString().trim().toLowerCase() != 'available') {
      throw const BookingException('Equipment is no longer available.');
    }
    if (listing['providerId'] != equipment.providerId ||
        listing['pricePerDay'] != equipment.pricePerDay ||
        listing['securityDeposit'] != equipment.securityDeposit) {
      throw const BookingException('The listing changed. Please restart booking.');
    }
    final reserved = AppDates.daysInRange(latestDraft.startDate, latestDraft.endDate)
        .map(AppDates.key).toList();
    if (reserved.any(ReservationDates.effective(listing).contains)) {
      throw const BookingException('These dates were just reserved. Please choose other dates.');
    }
    batch.update(lockedEquipment.reference,
        ReservationDates.change(listing, bookingRef.id, reserved));
    batch.set(bookingRef, {
      'bookingReference': reference,
      'equipmentId': equipment.id,
      'equipmentName': equipment.name,
      'equipmentCategory': equipment.category,
      'providerId': equipment.providerId,
      'providerName': equipment.providerName,
      'playerId': playerId,
      'playerName': playerName,
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
      message: '$playerName wants to rent ${equipment.name} '
          'for $period.',
    );

    if (_requirePlayerId() != playerId) {
      throw const BookingException('Your login changed. Please start booking again.');
    }
    });
    return bookingRef.id;
  }

  // ---------------------------------------------------------------------------
  // Edit Booking (pending + Cash on Pickup only)
  // ---------------------------------------------------------------------------

  static const String _notEditable =
      'This booking can no longer be changed. Only Cash on Pickup bookings '
      'waiting for provider approval can be edited.';

  /// Loads the latest listing and the blocked days for the edit screen.
  Future<BookingEditOptions> loadEditOptions(Booking booking) async {
    final playerId = _requirePlayerId();
    if (booking.playerId != playerId) {
      throw const BookingException('This booking does not belong to you.');
    }
    if (!booking.canEdit) throw const BookingException(_notEditable);

    final equipmentDoc = await _equipment.doc(booking.equipmentId).get();
    final listing = equipmentDoc.data();
    if (listing == null) {
      throw const BookingException('This equipment is no longer listed.');
    }
    final Equipment equipment;
    try {
      equipment = Equipment.fromDiscovery({...listing, 'id': equipmentDoc.id});
    } on FormatException {
      throw const BookingException(
          'This equipment is not available right now, so the booking cannot '
          'be changed. You can still cancel it.');
    }
    if (equipment.providerId != booking.providerId) {
      throw const BookingException('The listing changed. Please cancel and book again.');
    }

    return BookingEditOptions(
      equipment: equipment,
      unavailable: unavailableForEdit(
        listing: listing,
        slots: await _slotsFor(booking.equipmentId),
        bookingId: booking.id,
      ),
    );
  }

  /// Moves a pending Cash on Pickup booking to new dates and/or switches it
  /// to Card / Online Banking (charged now).
  ///
  /// The price is recalculated from the latest listing, the new dates are
  /// re-checked, and the booking, its slot, the equipment reservation,
  /// any payment record and the notifications are written in one
  /// transaction. Throws [BookingException] with a user-facing message.
  Future<void> updateBooking({
    required Booking booking,
    required DateTime startDate,
    required DateTime endDate,
    required PaymentMethod paymentMethod,
    CardDetails? card,
    String? bank,
  }) async {
    final playerId = _requirePlayerId();
    final start = AppDates.dateOnly(startDate);
    final end = AppDates.dateOnly(endDate);
    final datesChanged = AppDates.key(start) != booking.startDate ||
        AppDates.key(end) != booking.endDate;
    if (!datesChanged && paymentMethod == booking.paymentMethod) {
      throw const BookingException('You have not changed anything.');
    }

    // Also checks ownership and that the booking is still editable.
    final options = await loadEditOptions(booking);
    final dateError = validateDates(
      start: start,
      end: end,
      unavailable: options.unavailable,
    );
    if (dateError != null) throw BookingException(dateError);

    final equipment = options.equipment;
    final draft = BookingDraft(
      equipment: equipment,
      startDate: start,
      endDate: end,
      pickupMethod: booking.pickupMethod,
      deliveryAddress: booking.deliveryAddress,
      note: booking.note,
    );
    final price = draft.price;

    if (_requirePlayerId() != playerId) {
      throw const BookingException('Your login changed. Please try again.');
    }
    // Cash returns pay_on_pickup without charging; card / bank are charged.
    final payment = await _payments.process(
      method: paymentMethod,
      amount: price.totalPayable,
      card: card,
      bank: bank,
    );
    if (!payment.success) throw BookingException(payment.message);

    final bookingRef = _bookings.doc(booking.id);
    final equipmentRef = _equipment.doc(booking.equipmentId);
    final startKey = AppDates.key(start);
    final endKey = AppDates.key(end);
    final newDates = AppDates.daysInRange(start, end).map(AppDates.key).toList();
    final period = AppDates.prettyRange(startKey, endKey);
    final now = FieldValue.serverTimestamp();

    await _db.runTransaction((transaction) async {
      final currentDoc = await transaction.get(bookingRef);
      final listingDoc = await transaction.get(equipmentRef);
      if (!currentDoc.exists) throw const BookingException('Booking not found.');

      // The provider may have accepted / rejected it while the player was editing.
      final current = Booking.fromDoc(currentDoc);
      if (current.playerId != playerId) {
        throw const BookingException('This booking does not belong to you.');
      }
      if (!current.canEdit) throw const BookingException(_notEditable);

      final listing = listingDoc.data();
      if (listing == null || listing['isAvailable'] == false ||
          listing['status']?.toString().trim().toLowerCase() != 'available') {
        throw const BookingException('Equipment is no longer available.');
      }
      if (listing['providerId'] != equipment.providerId ||
          listing['pricePerDay'] != equipment.pricePerDay ||
          listing['securityDeposit'] != equipment.securityDeposit) {
        throw const BookingException('The listing changed. Please open the booking again.');
      }
      if (newDates.any(
          ReservationDates.effective(listing, excluding: booking.id).contains)) {
        throw const BookingException('These dates were just reserved. Please choose other dates.');
      }

      transaction.update(
          equipmentRef, ReservationDates.change(listing, booking.id, newDates));
      transaction.update(bookingRef, {
        'startDate': startKey,
        'endDate': endKey,
        'startTimestamp': Timestamp.fromDate(start),
        'endTimestamp': Timestamp.fromDate(end),
        'rentalDays': price.rentalDays,
        'pickupLocation': draft.pickupLocation,
        'pricePerDay': price.pricePerDay,
        'totalAmount': price.rentalCost,
        'deliveryFee': price.deliveryFee,
        'serviceFee': price.serviceFee,
        'depositAmount': price.deposit,
        'totalPayable': price.totalPayable,
        'paymentMethod': paymentMethod.value,
        'paymentStatus': payment.paymentStatus,
        'transactionId': payment.transactionId,
        'cardLast4': payment.cardLast4,
        'updatedAt': now,
        'editCount': FieldValue.increment(1),
      });
      transaction.set(_slots.doc(booking.id), {
        'equipmentId': booking.equipmentId,
        'startDate': startKey,
        'endDate': endKey,
        'status': BookingStatus.pending,
        'updatedAt': now,
      }, SetOptions(merge: true));

      if (payment.paymentStatus == PaymentStatus.paid) {
        transaction.set(_paymentRecords.doc(), {
          'bookingId': booking.id,
          'bookingReference': booking.bookingReference,
          'playerId': playerId,
          'providerId': booking.providerId,
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
      }

      final changes = [
        if (datesChanged) 'new dates $period',
        if (paymentMethod != booking.paymentMethod) 'paying by ${paymentMethod.label}',
      ].join(', ');

      _addNotification(
        transaction,
        userId: playerId,
        bookingId: booking.id,
        type: 'booking',
        title: 'Booking updated',
        message: '${booking.bookingReference}: ${booking.equipmentName} - $changes.',
      );
      if (payment.paymentStatus == PaymentStatus.paid) {
        _addNotification(
          transaction,
          userId: playerId,
          bookingId: booking.id,
          type: 'payment',
          title: 'Payment confirmed',
          message: '${formatLkr(price.totalPayable)} paid for '
              '${booking.bookingReference} (${payment.transactionId}).',
        );
      }
      _addNotification(
        transaction,
        userId: booking.providerId,
        bookingId: booking.id,
        type: 'rental_request',
        title: 'Rental request updated',
        message: '${booking.playerName} changed the request for '
            '${booking.equipmentName}: $changes.',
      );

      if (_requirePlayerId() != playerId) {
        throw const BookingException('Your login changed. Please try again.');
      }
    });
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
    _requirePlayerId();
    await BookingLifecycleService(_db).transition(bookingId, 'cancelled', reason: reason);
  }

  /// Route status changes through the same rental/slot/reservation transaction.
  Future<void> syncSlotStatus(String bookingId, String status, {
    bool returnedWithoutDamage = false, bool depositRefunded = false,
  }) => BookingLifecycleService(_db).transition(bookingId, status,
    returnedWithoutDamage: returnedWithoutDamage, depositRefunded: depositRefunded);

  void _addNotification(
    Transaction batch, {
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
      'referenceId': bookingId,
      'type': type,
      'title': title,
      'message': message,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
