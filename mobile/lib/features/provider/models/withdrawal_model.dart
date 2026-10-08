import 'package:cloud_firestore/cloud_firestore.dart';

class WithdrawalModel {
  final String id;
  final String providerId;
  final String bankAccountId;
  final String bankName;
  final String accountHolderName;
  final String accountLast4;
  final String branch;
  final double amount;
  final String status;
  final DateTime? requestedAt;

  const WithdrawalModel({
    required this.id,
    required this.providerId,
    required this.bankAccountId,
    required this.bankName,
    required this.accountHolderName,
    required this.accountLast4,
    required this.branch,
    required this.amount,
    required this.status,
    required this.requestedAt,
  });

  factory WithdrawalModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? {};

    final amountValue = data['amount'];

    return WithdrawalModel(
      id: document.id,
      providerId:
          data['providerId']?.toString() ?? '',
      bankAccountId:
          data['bankAccountId']?.toString() ?? '',
      bankName:
          data['bankName']?.toString() ?? 'Bank',
      accountHolderName:
          data['accountHolderName']?.toString() ?? '',
      accountLast4:
          data['accountLast4']?.toString() ?? '',
      branch:
          data['branch']?.toString() ?? '',
      amount: amountValue is num
          ? amountValue.toDouble()
          : 0,
      status:
          data['status']?.toString().toLowerCase() ??
              'pending',
      requestedAt:
          data['requestedAt'] is Timestamp
              ? (data['requestedAt'] as Timestamp)
                  .toDate()
              : null,
    );
  }
}