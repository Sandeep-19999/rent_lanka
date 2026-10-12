import 'package:flutter_test/flutter_test.dart';
import 'package:rent_lanka_mobile/features/booking_payment/models/booking_model.dart';
import 'package:rent_lanka_mobile/features/booking_payment/services/booking_service.dart';

Booking booking({
  String status = BookingStatus.pending,
  PaymentMethod method = PaymentMethod.cashOnPickup,
  String paymentStatus = PaymentStatus.payOnPickup,
}) {
  return Booking(
    id: 'b1',
    bookingReference: 'RL-B1',
    equipmentId: 'e1',
    equipmentName: 'Cricket Bat',
    equipmentCategory: 'Cricket',
    providerId: 'provider',
    providerName: 'Provider',
    playerId: 'player',
    playerName: 'Player',
    startDate: '2026-11-10',
    endDate: '2026-11-12',
    rentalDays: 3,
    pickupMethod: PickupMethod.ownerPickup,
    pickupLocation: '',
    deliveryAddress: '',
    note: '',
    pricePerDay: 1000,
    rentalCost: 3000,
    deliveryFee: 0,
    serviceFee: 150,
    depositAmount: 1000,
    totalPayable: 4150,
    paymentMethod: method,
    paymentStatus: paymentStatus,
    transactionId: '',
    cardLast4: '',
    status: status,
    createdAt: null,
  );
}

void main() {
  group('Booking.canEdit', () {
    test('pending cash on pickup booking can be edited', () {
      expect(booking().canEdit, isTrue);
    });

    test('accepted, rejected, active, completed or cancelled cannot be edited', () {
      for (final status in [
        BookingStatus.accepted,
        BookingStatus.rejected,
        BookingStatus.active,
        BookingStatus.completed,
        BookingStatus.cancelled,
      ]) {
        expect(booking(status: status).canEdit, isFalse, reason: status);
      }
    });

    test('card and online banking bookings cannot be edited', () {
      expect(
        booking(method: PaymentMethod.card, paymentStatus: PaymentStatus.paid).canEdit,
        isFalse,
      );
      expect(
        booking(method: PaymentMethod.onlineBanking, paymentStatus: PaymentStatus.paid)
            .canEdit,
        isFalse,
      );
    });

    test('cash booking that is already paid or refunded cannot be edited', () {
      expect(booking(paymentStatus: PaymentStatus.paid).canEdit, isFalse);
      expect(booking(paymentStatus: PaymentStatus.refunded).canEdit, isFalse);
    });
  });

  group('BookingService.blockingSlotDays', () {
    final slots = {
      'b1': {'startDate': '2026-11-10', 'endDate': '2026-11-12', 'status': 'pending'},
      'b2': {'startDate': '2026-11-20', 'endDate': '2026-11-21', 'status': 'accepted'},
      'b3': {'startDate': '2026-11-25', 'endDate': '2026-11-25', 'status': 'cancelled'},
    };

    test('only pending / accepted / active slots block days', () {
      expect(BookingService.blockingSlotDays(slots), {
        '2026-11-10', '2026-11-11', '2026-11-12', '2026-11-20', '2026-11-21',
      });
    });

    test('the booking being edited does not block itself', () {
      expect(
        BookingService.blockingSlotDays(slots, excludingBookingId: 'b1'),
        {'2026-11-20', '2026-11-21'},
      );
    });
  });

  group('BookingService.unavailableForEdit', () {
    final listing = {
      'manualUnavailableDates': ['2026-11-15'],
      'rentalReservations': {
        'b1': ['2026-11-10', '2026-11-11', '2026-11-12'],
        'b2': ['2026-11-20', '2026-11-21'],
      },
    };
    final slots = {
      'b1': {'startDate': '2026-11-10', 'endDate': '2026-11-12', 'status': 'pending'},
      'b2': {'startDate': '2026-11-20', 'endDate': '2026-11-21', 'status': 'accepted'},
    };

    final unavailable = BookingService.unavailableForEdit(
      listing: listing,
      slots: slots,
      bookingId: 'b1',
    );

    test('own current dates stay selectable', () {
      expect(unavailable.contains('2026-11-10'), isFalse);
      expect(unavailable.contains('2026-11-12'), isFalse);
    });

    test('provider-blocked and other bookings\' dates stay blocked', () {
      expect(unavailable, containsAll(['2026-11-15', '2026-11-20', '2026-11-21']));
    });

    test('moving onto another booking\'s dates is rejected', () {
      final error = BookingService.validateDates(
        start: DateTime(2026, 11, 19),
        end: DateTime(2026, 11, 21),
        unavailable: unavailable,
        today: DateTime(2026, 10, 12),
      );
      expect(error, contains('Not available'));
    });

    test('shifting within own dates is allowed', () {
      final error = BookingService.validateDates(
        start: DateTime(2026, 11, 11),
        end: DateTime(2026, 11, 13),
        unavailable: unavailable,
        today: DateTime(2026, 10, 12),
      );
      expect(error, isNull);
    });
  });
}
