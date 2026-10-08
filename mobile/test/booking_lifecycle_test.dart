import 'package:flutter_test/flutter_test.dart';
import 'package:rent_lanka_mobile/features/booking_payment/services/booking_lifecycle_service.dart';

void main() {
  test('pending reservation blocks competitors but not its own acceptance', () {
    final original = {
      'unavailableDates': ['2026-10-01'],
    };
    final reserved = ReservationDates.change(original, 'request-a', [
      '2026-10-02',
    ]);
    expect(ReservationDates.effective(reserved), {'2026-10-01', '2026-10-02'});
    expect(ReservationDates.effective(reserved, excluding: 'request-a'), {
      '2026-10-01',
    });
  });
  test('cancellation, rejection and completion release only owned dates', () {
    for (final status in ['cancelled', 'rejected', 'completed']) {
      final data = {
        'manualUnavailableDates': ['2026-10-02'],
        'rentalReservations': {
          'request-a': ['2026-10-02', '2026-10-03'],
          'request-b': ['2026-10-04'],
        },
      };
      final released = ReservationDates.change(data, 'request-a', null);
      expect(ReservationDates.effective(released), {
        '2026-10-02',
        '2026-10-04',
      }, reason: status);
      expect(
        ReservationDates.reservations(released).containsKey('request-a'),
        isFalse,
      );
    }
  });
  test('legacy unavailable dates are preserved conservatively', () {
    final data = {
      'unavailableDates': ['2026-10-01'],
    };
    expect(
      ReservationDates.effective(ReservationDates.change(data, 'legacy', null)),
      {'2026-10-01'},
    );
  });
  test('repeated release is idempotent', () {
    final data = {
      'manualUnavailableDates': <String>[],
      'rentalReservations': {
        'a': ['2026-10-01'],
      },
    };
    final first = ReservationDates.change(data, 'a', null);
    final second = ReservationDates.change(first, 'a', null);
    expect(second['unavailableDates'], first['unavailableDates']);
    expect(second['rentalReservations'], first['rentalReservations']);
  });
  test('manual availability edits cannot erase rental reservations', () {
    final data = {
      'manualUnavailableDates': ['2026-10-02'],
      'rentalReservations': {
        'request': ['2026-10-02', '2026-10-03'],
      },
    };
    final selected = ReservationDates.manualSelection(data, [
      '2026-10-02',
      '2026-10-03',
      '2026-10-05',
    ]);
    expect(selected['manualUnavailableDates'], ['2026-10-02', '2026-10-05']);
    expect(selected['unavailableDates'], [
      '2026-10-02',
      '2026-10-03',
      '2026-10-05',
    ]);
    expect(() => ReservationDates.manualSelection(data, []), throwsStateError);
  });

  test(
    'lifecycle transitions cannot reopen completed or cancelled requests',
    () {
      for (final pair in [
        ['pending', 'accepted'],
        ['pending', 'rejected'],
        ['pending', 'cancelled'],
        ['accepted', 'active'],
        ['accepted', 'cancelled'],
        ['active', 'completed'],
      ]) {
        expect(ReservationDates.canTransition(pair[0], pair[1]), isTrue);
      }
      for (final pair in [
        ['completed', 'accepted'],
        ['cancelled', 'active'],
        ['active', 'cancelled'],
        ['pending', 'completed'],
        ['accepted', 'rejected'],
      ]) {
        expect(ReservationDates.canTransition(pair[0], pair[1]), isFalse);
      }
    },
  );
}
