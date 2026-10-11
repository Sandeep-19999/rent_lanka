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
  final DateTime? approvedAt;
  final String approvalNote;

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
    this.approvedAt,
    this.approvalNote = '',
  });

  factory WithdrawalModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    return WithdrawalModel.fromMap(document.id, document.data() ?? {});
  }

  factory WithdrawalModel.fromMap(String id, Map<String, dynamic> data) {
    final amountValue = data['amount'];

    return WithdrawalModel(
      id: id,
      providerId: data['providerId']?.toString() ?? '',
      bankAccountId: data['bankAccountId']?.toString() ?? '',
      bankName: data['bankName']?.toString() ?? 'Bank',
      accountHolderName: data['accountHolderName']?.toString() ?? '',
      accountLast4: data['accountLast4']?.toString() ?? '',
      branch: data['branch']?.toString() ?? '',
      amount: amountValue is num ? amountValue.toDouble() : 0,
      status: data['status']?.toString().toLowerCase() ?? 'pending',
      requestedAt: data['requestedAt'] is Timestamp
          ? (data['requestedAt'] as Timestamp).toDate()
          : null,
      approvedAt: data['approvedAt'] is Timestamp
          ? (data['approvedAt'] as Timestamp).toDate()
          : null,
      approvalNote: data['approvalNote']?.toString() ?? '',
    );
  }

  String get statusDescription => switch (status) {
    'pending' => 'Awaiting admin approval. Your requested amount is reserved.',
    'approved' => 'Approved by admin. Awaiting bank payout.',
    'completed' => 'Bank payout marked completed.',
    'rejected' =>
      'Request rejected. The amount is available to withdraw again.',
    'cancelled' =>
      'Request cancelled. The amount is available to withdraw again.',
    _ => 'Contact support for the status of this request.',
  };
}
