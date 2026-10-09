// Test doubles only: production code uses the Firebase SDK implementations.
// ignore_for_file: subtype_of_sealed_class

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rent_lanka_mobile/features/exchange_messaging_profile/services/account_deletion_service.dart';

class TestUser extends Fake implements User {
  TestUser(this.events);
  final List<String> events;
  Object? authError;
  @override
  String get uid => 'player';
  @override
  String? get email => 'player@example.com';
  @override
  List<UserInfo> get providerData => [TestUserInfo()];
  @override
  Future<UserCredential> reauthenticateWithCredential(
    AuthCredential credential,
  ) async {
    events.add('reauthenticate');
    if (authError != null) throw authError!;
    return TestCredential();
  }

  @override
  Future<void> delete() async {
    events.add('delete-auth');
  }
}

class TestUserInfo extends Fake implements UserInfo {
  @override
  String get providerId => 'password';
}

class TestCredential extends Fake implements UserCredential {}

class TestAuth extends Fake implements FirebaseAuth {
  TestAuth(this.currentUser);
  @override
  User? currentUser;
}

class TestFirestore extends Fake implements FirebaseFirestore {
  TestFirestore(this.events);
  final List<String> events;
  final Map<String, int> counts = {};
  final List<int> batchSizes = [];
  bool failCommit = false;
  String role = 'player';
  @override
  CollectionReference<Map<String, dynamic>> collection(String path) =>
      TestCollection(this, path);
  @override
  WriteBatch batch() => TestBatch(this);
}

class TestCollection extends Fake
    implements CollectionReference<Map<String, dynamic>> {
  TestCollection(this.store, this.path, [this.pageSize = 400]);
  final TestFirestore store;
  @override
  final String path;
  final int pageSize;
  @override
  DocumentReference<Map<String, dynamic>> doc([String? id]) =>
      TestDocument(store, '$path/$id');
  @override
  Query<Map<String, dynamic>> where(
    Object field, {
    Object? isEqualTo,
    Object? isNotEqualTo,
    Object? isLessThan,
    Object? isLessThanOrEqualTo,
    Object? isGreaterThan,
    Object? isGreaterThanOrEqualTo,
    Object? arrayContains,
    Iterable<Object?>? arrayContainsAny,
    Iterable<Object?>? whereIn,
    Iterable<Object?>? whereNotIn,
    bool? isNull,
  }) {
    store.events.add('query:$path:$field:$isEqualTo');
    return this;
  }

  @override
  Query<Map<String, dynamic>> limit(int limit) =>
      TestCollection(store, path, limit);
  @override
  Future<QuerySnapshot<Map<String, dynamic>>> get([GetOptions? options]) async {
    store.events.add('read:$path');
    final count = store.counts[path] ?? 0;
    return TestQuerySnapshot(
      List.generate(
        count < pageSize ? count : pageSize,
        (index) => TestQueryDocument(TestDocument(store, '$path/$index')),
      ),
    );
  }
}

class TestDocument extends Fake
    implements DocumentReference<Map<String, dynamic>> {
  TestDocument(this.store, this.path);
  final TestFirestore store;
  @override
  final String path;
  @override
  CollectionReference<Map<String, dynamic>> collection(String name) =>
      TestCollection(store, '$path/$name');
  @override
  Future<DocumentSnapshot<Map<String, dynamic>>> get([
    GetOptions? options,
  ]) async {
    store.events.add('read-profile');
    return TestProfileSnapshot(store.role);
  }

  @override
  Future<void> delete() async {
    store.events.add('delete-profile');
  }
}

class TestProfileSnapshot extends Fake
    implements DocumentSnapshot<Map<String, dynamic>> {
  TestProfileSnapshot(this.role);
  final String role;
  @override
  Map<String, dynamic>? data() => {'role': role};
}

class TestQuerySnapshot extends Fake
    implements QuerySnapshot<Map<String, dynamic>> {
  TestQuerySnapshot(this.docs);
  @override
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs;
}

class TestQueryDocument extends Fake
    implements QueryDocumentSnapshot<Map<String, dynamic>> {
  TestQueryDocument(this.reference);
  @override
  final DocumentReference<Map<String, dynamic>> reference;
}

class TestBatch extends Fake implements WriteBatch {
  TestBatch(this.store);
  final TestFirestore store;
  final List<DocumentReference> deleted = [];
  @override
  void delete(DocumentReference document) {
    deleted.add(document);
  }

  @override
  Future<void> commit() async {
    if (store.failCommit) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'permission-denied',
      );
    }
    store.events.add('commit');
    store.batchSizes.add(deleted.length);
    for (final document in deleted) {
      final path = document.path.substring(0, document.path.lastIndexOf('/'));
      store.counts[path] = store.counts[path]! - 1;
    }
  }
}

void main() {
  late List<String> events;
  late TestUser user;
  late TestFirestore store;
  late AccountDeletionService service;
  setUp(() {
    events = [];
    user = TestUser(events);
    store = TestFirestore(events);
    service = AccountDeletionService(auth: TestAuth(user), firestore: store);
  });

  test(
    'identity verification failure leaves all user data untouched',
    () async {
      user.authError = FirebaseAuthException(code: 'invalid-credential');
      await expectLater(
        service.deleteAccount(password: 'wrong'),
        throwsA(isA<FirebaseAuthException>()),
      );
      expect(events, ['reauthenticate']);
    },
  );

  test(
    'cleans bounded pages and private data before profile and auth',
    () async {
      store.counts.addAll({
        'users/player/favourites': 401,
        'notifications': 2,
        'support_reports': 1,
        'reviews': 1,
      });
      await service.deleteAccount(password: 'correct');
      expect(events.first, 'reauthenticate');
      expect(events.sublist(events.length - 2), [
        'delete-profile',
        'delete-auth',
      ]);
      expect(store.batchSizes, [400, 1, 2, 1, 1]);
      expect(store.counts.values, everyElement(0));
      expect(events, contains('query:notifications:userId:player'));
      expect(events, contains('query:reviews:reviewerId:player'));
      final firstCommit = events.indexOf('commit');
      expect(events.indexOf('read:reviews'), lessThan(firstCommit));
    },
  );

  test(
    'Firestore failure retains profile and authentication for retry',
    () async {
      store.counts['users/player/favourites'] = 1;
      store.failCommit = true;
      await expectLater(
        service.deleteAccount(password: 'correct'),
        throwsA(isA<FirebaseException>()),
      );
      expect(events, isNot(contains('delete-profile')));
      expect(events, isNot(contains('delete-auth')));
    },
  );

  test('provider profile is never deleted by player flow', () async {
    store.role = 'provider';
    await expectLater(
      service.deleteAccount(password: 'correct'),
      throwsA(isA<FirebaseAuthException>()),
    );
    expect(events, ['reauthenticate', 'read-profile']);
  });
}
