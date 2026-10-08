import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/bank_account_model.dart';
import '../models/rental_request_model.dart';
import '../models/withdrawal_model.dart';

class WithdrawalService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  WithdrawalService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore =
            firestore ?? FirebaseFirestore.instance,
        _auth =
            auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>>
      get _bankAccountsCollection =>
          _firestore.collection('bank_accounts');

  CollectionReference<Map<String, dynamic>>
      get _withdrawalsCollection =>
          _firestore.collection('withdrawals');

  CollectionReference<Map<String, dynamic>>
      get _rentalRequestsCollection =>
          _firestore.collection('rental_requests');

  String get _providerId {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception(
        'No Firebase user is logged in.',
      );
    }

    return user.uid;
  }

  // =========================================================
  // ADD BANK ACCOUNT
  // =========================================================

  Future<String> addBankAccount({
    required String bankName,
    required String accountHolderName,
    required String accountNumber,
    required String branch,
  }) async {
    if (bankName.trim().isEmpty ||
        accountHolderName.trim().isEmpty ||
        accountNumber.trim().isEmpty ||
        branch.trim().isEmpty) {
      throw Exception(
        'Bank account information is incomplete.',
      );
    }

    try {
      final document =
          _bankAccountsCollection.doc();

      await document.set({
        'providerId': _providerId,
        'bankName': bankName.trim(),
        'accountHolderName':
            accountHolderName.trim(),
        'accountNumber':
            accountNumber.trim(),
        'branch': branch.trim(),
        'isDefault': true,
        'createdAt':
            FieldValue.serverTimestamp(),
      }).timeout(
        const Duration(seconds: 15),
      );

      return document.id;
    } on TimeoutException {
      throw Exception(
        'Firebase write timed out. Please try again.',
      );
    } on FirebaseException catch (error) {
      throw Exception(
        'Firebase error (${error.code}): '
        '${error.message ?? 'Unknown error'}',
      );
    }
  }

  // =========================================================
  // BANK ACCOUNTS
  // =========================================================

  Stream<List<BankAccountModel>>
      watchMyBankAccounts() {
    final user = _auth.currentUser;

    if (user == null) {
      return Stream.value(
        <BankAccountModel>[],
      );
    }

    return _bankAccountsCollection
        .where(
          'providerId',
          isEqualTo: user.uid,
        )
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                BankAccountModel.fromFirestore,
              )
              .toList(),
        );
  }

  Future<BankAccountModel?> getBankAccount(
    String accountId,
  ) async {
    final document =
        await _bankAccountsCollection
            .doc(accountId)
            .get();

    if (!document.exists) {
      return null;
    }

    return BankAccountModel.fromFirestore(
      document,
    );
  }

  Future<void> deleteBankAccount(
    String accountId,
  ) async {
    await _bankAccountsCollection
        .doc(accountId)
        .delete();
  }

  // =========================================================
  // COMPLETED RENTAL VALUE
  // =========================================================

  Stream<double> watchCompletedRentalTotal() {
    final user = _auth.currentUser;

    if (user == null) {
      return Stream.value(0);
    }

    return _rentalRequestsCollection
        .where(
          'providerId',
          isEqualTo: user.uid,
        )
        .snapshots()
        .map(
          (snapshot) {
            double total = 0;

            for (final document in snapshot.docs) {
              final request =
                  RentalRequestModel.fromFirestore(
                document,
              );

              if (request.status == 'completed') {
                total += request.totalAmount;
              }
            }

            return total;
          },
        );
  }

  // =========================================================
  // WITHDRAWALS
  // =========================================================

  Stream<List<WithdrawalModel>>
      watchMyWithdrawals() {
    final user = _auth.currentUser;

    if (user == null) {
      return Stream.value(
        <WithdrawalModel>[],
      );
    }

    return _withdrawalsCollection
        .where(
          'providerId',
          isEqualTo: user.uid,
        )
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                WithdrawalModel.fromFirestore,
              )
              .toList(),
        );
  }

  Stream<double> watchWithdrawalTotal() {
    return watchMyWithdrawals().map(
      (withdrawals) {
        double total = 0;

        for (final withdrawal in withdrawals) {
          if (withdrawal.status == 'rejected' ||
              withdrawal.status == 'cancelled') {
            continue;
          }

          total += withdrawal.amount;
        }

        return total;
      },
    );
  }

  // =========================================================
  // CURRENT AVAILABLE BALANCE
  // =========================================================

  Future<double> getAvailableBalance() async {
    final rentalSnapshot =
        await _rentalRequestsCollection
            .where(
              'providerId',
              isEqualTo: _providerId,
            )
            .get();

    final withdrawalSnapshot =
        await _withdrawalsCollection
            .where(
              'providerId',
              isEqualTo: _providerId,
            )
            .get();

    double completedRentalValue = 0;

    for (final document
        in rentalSnapshot.docs) {
      final request =
          RentalRequestModel.fromFirestore(
        document,
      );

      if (request.status == 'completed') {
        completedRentalValue +=
            request.totalAmount;
      }
    }

    double withdrawalTotal = 0;

    for (final document
        in withdrawalSnapshot.docs) {
      final withdrawal =
          WithdrawalModel.fromFirestore(
        document,
      );

      if (withdrawal.status == 'rejected' ||
          withdrawal.status == 'cancelled') {
        continue;
      }

      withdrawalTotal += withdrawal.amount;
    }

    final balance =
        completedRentalValue - withdrawalTotal;

    return balance < 0 ? 0 : balance;
  }

  // =========================================================
  // SUBMIT WITHDRAWAL
  // =========================================================

  Future<void> submitWithdrawal({
    required double amount,
    required String bankAccountId,
  }) async {
    if (amount <= 0) {
      throw Exception(
        'Please enter a valid withdrawal amount.',
      );
    }

    final latestAvailableBalance =
        await getAvailableBalance();

    if (latestAvailableBalance <= 0) {
      throw Exception(
        'You do not have any available balance to withdraw.',
      );
    }

    if (amount > latestAvailableBalance) {
      throw Exception(
        'Your available balance has changed. '
        'Current balance is Rs. '
        '${_formatPrice(latestAvailableBalance)}.',
      );
    }

    final bankAccount =
        await getBankAccount(
      bankAccountId,
    );

    if (bankAccount == null) {
      throw Exception(
        'Selected bank account could not be found.',
      );
    }

    if (bankAccount.providerId != _providerId) {
      throw Exception(
        'This bank account does not belong to the current provider.',
      );
    }

    await _withdrawalsCollection.add({
      'providerId': _providerId,
      'bankAccountId': bankAccount.id,
      'bankName': bankAccount.bankName,
      'accountHolderName':
          bankAccount.accountHolderName,
      'accountLast4':
          bankAccount.accountLast4,
      'branch': bankAccount.branch,
      'amount': amount,
      'status': 'pending',
      'requestedAt':
          FieldValue.serverTimestamp(),
    });
  }

  static String _formatPrice(
    double value,
  ) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(2);
  }
}