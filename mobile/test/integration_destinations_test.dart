import 'package:flutter_test/flutter_test.dart';
import 'package:rent_lanka_mobile/navigation/notification_destination.dart';
import 'package:rent_lanka_mobile/features/exchange_messaging_profile/services/review_service.dart';
import 'package:rent_lanka_mobile/features/exchange_messaging_profile/services/transaction_service.dart';

void main() {
  test(
    'notifications deep link to existing role-appropriate feature destinations',
    () {
      expect(
        notificationDestination('rental_request', 'request'),
        NotificationDestination.providerRequest,
      );
      expect(
        notificationDestination('booking', 'request'),
        NotificationDestination.booking,
      );
      expect(
        notificationDestination('payment', 'request'),
        NotificationDestination.booking,
      );
      expect(
        notificationDestination('payment', ''),
        NotificationDestination.transactions,
      );
      expect(
        notificationDestination('booking', ''),
        NotificationDestination.myBookings,
      );
      expect(
        notificationDestination('message', 'chat'),
        NotificationDestination.chat,
      );
      expect(
        notificationDestination('exchange', 'exchange'),
        NotificationDestination.exchange,
      );
      expect(
        notificationDestination('review', 'request'),
        NotificationDestination.review,
      );
    },
  );
  test('legacy booking notification IDs remain readable', () {
    expect(notificationReference({'bookingId': 'booking'}), 'booking');
    expect(
      notificationReference({'referenceId': '', 'bookingId': 'booking'}),
      'booking',
    );
    expect(
      notificationReference({'referenceId': 'chat', 'bookingId': 'booking'}),
      'chat',
    );
  });
  test('review eligibility requires completed rental ownership', () {
    expect(
      ReviewService.canReview({
        'playerId': 'player',
        'status': 'completed',
      }, 'player'),
      isTrue,
    );
    expect(
      ReviewService.canReview({
        'playerId': 'another',
        'status': 'completed',
      }, 'player'),
      isFalse,
    );
    for (final status in [
      'pending',
      'accepted',
      'active',
      'cancelled',
      'rejected',
    ]) {
      expect(
        ReviewService.canReview({
          'playerId': 'player',
          'status': status,
        }, 'player'),
        isFalse,
      );
    }
    expect(ReviewService.canReview({}, ''), isFalse);
  });
  test(
    'real refund and payment records retain equipment, provider and references',
    () {
      final record = TransactionService.fromData(
        {
          'type': 'refund',
          'amount': 2000,
          'status': 'refunded',
          'method': 'card',
          'cardLast4': '4242',
          'bookingReference': 'RL-17',
          'transactionId': 'TXN-17',
        },
        {'equipmentName': 'fan', 'providerName': 'Listing owner'},
      );
      expect(record.isRefund, isTrue);
      expect(record.equipmentName, 'fan');
      expect(record.providerName, 'Listing owner');
      expect(record.status, 'refunded');
      expect(record.reference, 'RL-17');
      expect(record.description, contains('TXN-17'));
      expect(record.paymentMethod, 'Card ending 4242');
    },
  );
}
