import 'bank_account_model.dart';

/// Providers request a withdrawal; only an administrator can approve it.
class WithdrawalRequest {
  static Map<String, dynamic> toFirestore({
    required String providerId,
    required BankAccountModel bankAccount,
    required double amount,
    required Object requestedAt,
  }) {
    if (!amount.isFinite || amount <= 0) {
      throw ArgumentError('Please enter a valid withdrawal amount.');
    }
    if (providerId.isEmpty || bankAccount.providerId != providerId) {
      throw ArgumentError('The bank account must belong to the provider.');
    }
    if (bankAccount.id.isEmpty ||
        bankAccount.bankName.trim().isEmpty ||
        bankAccount.accountHolderName.trim().isEmpty ||
        bankAccount.branch.trim().isEmpty ||
        !RegExp(r'^\d{4}$').hasMatch(bankAccount.accountLast4)) {
      throw ArgumentError(
        'Please select a bank account with complete details.',
      );
    }
    return {
      'providerId': providerId,
      'bankAccountId': bankAccount.id,
      'bankName': bankAccount.bankName,
      'accountHolderName': bankAccount.accountHolderName,
      'accountLast4': bankAccount.accountLast4,
      'branch': bankAccount.branch,
      'amount': amount,
      'status': 'pending',
      'requestedAt': requestedAt,
    };
  }
}
