import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/transaction_record.dart';
import '../../booking_payment/utils/date_utils.dart';

class TransactionService {
  final FirebaseFirestore db;
  final FirebaseAuth auth;
  TransactionService({FirebaseFirestore? firestore, FirebaseAuth? firebaseAuth})
    : db = firestore ?? FirebaseFirestore.instance,
      auth = firebaseAuth ?? FirebaseAuth.instance;

  Stream<List<TransactionRecord>> watchMyTransactions() async* {
    final uid = auth.currentUser?.uid;
    if (uid == null) throw StateError('Please log in to view transactions.');
    yield* db
        .collection('payments')
        .where('playerId', isEqualTo: uid)
        .snapshots()
        .asyncMap((snapshot) async {
          final bookings = <String, Map<String, dynamic>>{};
          for (final payment in snapshot.docs) {
            final id = payment.data()['bookingId']?.toString() ?? '';
            if (id.isNotEmpty && !bookings.containsKey(id)) {
              final document = await db
                  .collection('rental_requests')
                  .doc(id)
                  .get();
              final data = document.data() ?? {};
              bookings[id] = data['playerId'] == uid ? data : {};
            }
          }
          if (auth.currentUser?.uid != uid) {
            throw StateError('Please log in again.');
          }
          final records = snapshot.docs.toList()
            ..sort((a, b) {
              DateTime time(Map<String, dynamic> data) =>
                  data['createdAt'] is Timestamp
                  ? (data['createdAt'] as Timestamp).toDate()
                  : DateTime(1970);
              return time(b.data()).compareTo(time(a.data()));
            });
          return records
              .map(
                (doc) => fromData(
                  doc.data(),
                  bookings[doc.data()['bookingId']] ?? {},
                ),
              )
              .toList();
        });
  }

  static TransactionRecord fromData(
    Map<String, dynamic> payment,
    Map<String, dynamic> booking,
  ) {
    final refund = payment['type'] == 'refund';
    final timestamp = payment['createdAt'];
    final reference =
        payment['bookingReference']?.toString() ??
        booking['bookingReference']?.toString() ??
        payment['bookingId']?.toString() ??
        '';
    final transactionId = payment['transactionId']?.toString() ?? '';
    final method = payment['method']?.toString() ?? '';
    final methodName = switch (method) {
      'card' => 'Card',
      'online_banking' => 'Online Banking',
      'cash' => 'Cash on Pickup',
      _ => method,
    };
    final last4 = payment['cardLast4']?.toString() ?? '';
    return TransactionRecord(
      reference: reference,
      type: refund ? 'Refund' : 'Payment',
      date: timestamp is Timestamp
          ? AppDates.pretty(timestamp.toDate())
          : 'Pending',
      status: payment['status']?.toString() ?? '',
      amount: formatLkr((payment['amount'] as num?)?.toDouble() ?? 0),
      isRefund: refund,
      equipmentName: booking['equipmentName']?.toString() ?? '',
      providerName: booking['providerName']?.toString() ?? '',
      paymentMethod: last4.isEmpty ? methodName : '$methodName ending $last4',
      description: transactionId.isEmpty
          ? reference
          : '$reference • $transactionId',
    );
  }
}
