import 'package:cloud_firestore/cloud_firestore.dart';

class BankAccountModel {
  final String id;
  final String providerId;
  final String bankName;
  final String accountHolderName;
  final String accountNumber;
  final String branch;
  final bool isDefault;
  final DateTime? createdAt;

  const BankAccountModel({
    required this.id,
    required this.providerId,
    required this.bankName,
    required this.accountHolderName,
    required this.accountNumber,
    required this.branch,
    required this.isDefault,
    required this.createdAt,
  });

  factory BankAccountModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? {};

    return BankAccountModel(
      id: document.id,
      providerId:
          data['providerId']?.toString() ?? '',
      bankName:
          data['bankName']?.toString() ?? '',
      accountHolderName:
          data['accountHolderName']?.toString() ?? '',
      accountNumber:
          data['accountNumber']?.toString() ?? '',
      branch:
          data['branch']?.toString() ?? '',
      isDefault:
          data['isDefault'] == true,
      createdAt:
          data['createdAt'] is Timestamp
              ? (data['createdAt'] as Timestamp)
                  .toDate()
              : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'providerId': providerId,
      'bankName': bankName,
      'accountHolderName': accountHolderName,
      'accountNumber': accountNumber,
      'branch': branch,
      'isDefault': isDefault,
    };
  }

  String get accountLast4 {
    if (accountNumber.length <= 4) {
      return accountNumber;
    }

    return accountNumber.substring(
      accountNumber.length - 4,
    );
  }

  String get maskedAccountNumber {
    if (accountNumber.length <= 4) {
      return accountNumber;
    }

    return '•••• ${accountLast4}';
  }
}