import 'package:flutter_test/flutter_test.dart';
import 'package:rent_lanka_mobile/features/booking_payment/models/booking_model.dart';
import 'package:rent_lanka_mobile/features/booking_payment/services/booking_service.dart';
import 'package:rent_lanka_mobile/features/booking_payment/services/payment_service.dart';
import 'package:rent_lanka_mobile/features/booking_payment/utils/date_utils.dart';

void main() {
  group('AppDates', () {
    test('rental days are counted inclusively', () {
      expect(AppDates.rentalDays(DateTime(2026, 10, 6), DateTime(2026, 10, 6)), 1);
      expect(AppDates.rentalDays(DateTime(2026, 10, 6), DateTime(2026, 10, 8)), 3);
    });

    test('keys match the provider availability format', () {
      expect(AppDates.key(DateTime(2026, 3, 5)), '2026-03-05');
      expect(AppDates.parseKey('2026-03-05'), DateTime(2026, 3, 5));
    });

    test('ranges cross month boundaries', () {
      final days = AppDates.daysInRange(DateTime(2026, 1, 30), DateTime(2026, 2, 2));
      expect(days.map(AppDates.key), ['2026-01-30', '2026-01-31', '2026-02-01', '2026-02-02']);
    });
  });

  group('PriceBreakdown', () {
    test('pickup has no delivery fee', () {
      final price = PriceBreakdown.calculate(
        pricePerDay: 1000,
        rentalDays: 3,
        pickupMethod: PickupMethod.ownerPickup,
        deposit: 1000,
      );
      expect(price.rentalCost, 3000);
      expect(price.deliveryFee, 0);
      expect(price.serviceFee, 150);
      expect(price.totalPayable, 4150);
    });

    test('delivery adds the delivery fee', () {
      final price = PriceBreakdown.calculate(
        pricePerDay: 1000,
        rentalDays: 1,
        pickupMethod: PickupMethod.delivery,
        deposit: 0,
      );
      expect(price.deliveryFee, PriceBreakdown.deliveryFeeAmount);
      expect(price.totalPayable, 1000 + 500 + 50);
    });
  });

  group('BookingService.validateDates', () {
    final today = DateTime(2026, 10, 6);

    test('accepts a free range', () {
      expect(
        BookingService.validateDates(
          start: DateTime(2026, 10, 7),
          end: DateTime(2026, 10, 9),
          unavailable: {'2026-10-10'},
          today: today,
        ),
        isNull,
      );
    });

    test('rejects a range spanning a booked day', () {
      expect(
        BookingService.validateDates(
          start: DateTime(2026, 10, 7),
          end: DateTime(2026, 10, 12),
          unavailable: {'2026-10-10'},
          today: today,
        ),
        contains('Not available on 10 Oct 2026'),
      );
    });

    test('rejects past dates and over-long rentals', () {
      expect(
        BookingService.validateDates(
          start: DateTime(2026, 10, 5),
          end: DateTime(2026, 10, 6),
          unavailable: {},
          today: today,
        ),
        isNotNull,
      );
      expect(
        BookingService.validateDates(
          start: DateTime(2026, 10, 7),
          end: DateTime(2026, 11, 30),
          unavailable: {},
          today: today,
        ),
        contains('at most'),
      );
    });
  });

  group('PaymentService validation', () {
    test('card number uses the Luhn check', () {
      expect(PaymentService.validateCardNumber('4242 4242 4242 4242'), isNull);
      expect(PaymentService.validateCardNumber('4242 4242 4242 4241'), isNotNull);
      expect(PaymentService.validateCardNumber('1234'), isNotNull);
    });

    test('expiry is valid until the end of its month', () {
      final now = DateTime(2026, 10, 31);
      expect(PaymentService.validateExpiry('10/26', now: now), isNull);
      expect(PaymentService.validateExpiry('09/26', now: now), 'Card has expired');
      expect(PaymentService.validateExpiry('13/27', now: now), 'Invalid month');
      expect(PaymentService.validateExpiry('1027', now: now), 'Use MM/YY');
    });

    test('cvv must be 3 or 4 digits', () {
      expect(PaymentService.validateCvv('123'), isNull);
      expect(PaymentService.validateCvv('12'), isNotNull);
    });

    test('declined test card fails and cash needs no card', () async {
      final service = PaymentService();
      final declined = await service.process(
        method: PaymentMethod.card,
        amount: 100,
        card: const CardDetails(
          holderName: 'Test User',
          number: '4000 0000 0000 0002',
          expiry: '12/30',
          cvv: '123',
        ),
      );
      expect(declined.success, isFalse);

      final cash = await service.process(
        method: PaymentMethod.cashOnPickup,
        amount: 100,
      );
      expect(cash.success, isTrue);
      expect(cash.paymentStatus, PaymentStatus.payOnPickup);
    });

    test('successful card payment keeps only the last 4 digits', () async {
      final result = await PaymentService().process(
        method: PaymentMethod.card,
        amount: 100,
        card: const CardDetails(
          holderName: 'Test User',
          number: '4242 4242 4242 4242',
          expiry: '12/30',
          cvv: '123',
        ),
      );
      expect(result.success, isTrue);
      expect(result.cardLast4, '4242');
      expect(result.transactionId, startsWith('TXN-'));
    });
  });

  test('booking reference is short and uppercase', () {
    expect(Booking.referenceFor('ab12cd34ef'), 'RL-AB12CD');
  });
}
