import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rent_lanka_mobile/features/provider/services/withdrawal_service.dart';

class TestUser extends Fake implements User {
  @override
  String get uid => 'provider';
}

class TestAuth extends Fake implements FirebaseAuth {
  @override
  User? currentUser = TestUser();
}

class BankSnapshot extends Fake implements DocumentSnapshot<Map<String, dynamic>> {
  final String? owner;
  BankSnapshot(this.owner);
  @override
  bool get exists => owner != null;
  @override
  Map<String, dynamic>? data() => owner == null ? null : {'providerId': owner};
}

class BankReference extends Fake implements DocumentReference<Map<String, dynamic>> {}

class BankCollection extends Fake implements CollectionReference<Map<String, dynamic>> {
  final reference = BankReference();
  @override
  DocumentReference<Map<String, dynamic>> doc([String? path]) => reference;
}

class BankTransaction extends Fake implements Transaction {
  final String? owner;
  final void Function()? beforeRead;
  bool deleted = false;
  BankTransaction(this.owner, this.beforeRead);
  @override
  Future<DocumentSnapshot<T>> get<T extends Object?>(DocumentReference<T> reference) async {
    beforeRead?.call();
    return BankSnapshot(owner) as DocumentSnapshot<T>;
  }
  @override
  Transaction delete(DocumentReference<Object?> reference) {
    deleted = true;
    return this;
  }
}

class BankStore extends Fake implements FirebaseFirestore {
  final collectionReference = BankCollection();
  final BankTransaction transaction;
  BankStore(String? owner, [void Function()? beforeRead])
      : transaction = BankTransaction(owner, beforeRead);
  @override
  CollectionReference<Map<String, dynamic>> collection(String path) {
    expect(path, 'bank_accounts');
    return collectionReference;
  }
  @override
  Future<T> runTransaction<T>(TransactionHandler<T> handler, {
    Duration timeout = const Duration(seconds: 30), int maxAttempts = 5,
  }) => handler(transaction);
}

void main() {
  test('deletes only the current provider bank account', () async {
    final store = BankStore('provider');
    await WithdrawalService(firestore: store, auth: TestAuth()).deleteBankAccount('bank');
    expect(store.transaction.deleted, isTrue);
  });
  test('rejects another provider account without deleting', () async {
    final store = BankStore('other');
    await expectLater(WithdrawalService(firestore: store, auth: TestAuth()).deleteBankAccount('bank'), throwsException);
    expect(store.transaction.deleted, isFalse);
  });
  test('rejects session changes during deletion', () async {
    final auth = TestAuth();
    final store = BankStore('provider', () => auth.currentUser = null);
    await expectLater(WithdrawalService(firestore: store, auth: auth).deleteBankAccount('bank'), throwsException);
    expect(store.transaction.deleted, isFalse);
  });
  test('already deleted bank account is a safe no-op', () async {
    final store = BankStore(null);
    await WithdrawalService(firestore: store, auth: TestAuth()).deleteBankAccount('bank');
    expect(store.transaction.deleted, isFalse);
  });
}
