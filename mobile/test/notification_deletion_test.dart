// SDK doubles are used only in these isolated tests.
// ignore_for_file: subtype_of_sealed_class

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rent_lanka_mobile/features/exchange_messaging_profile/screens/notifications_screen.dart';
import 'package:rent_lanka_mobile/features/exchange_messaging_profile/services/notification_service.dart';

class NotificationDocument extends Fake
    implements QueryDocumentSnapshot<Map<String, dynamic>> {
  NotificationDocument(this.id, this.values, {this.exists = true});
  @override
  final String id;
  final Map<String, dynamic> values;
  @override
  final bool exists;
  @override
  Map<String, dynamic> data() => values;
}

class NotificationSnapshot extends Fake
    implements QuerySnapshot<Map<String, dynamic>> {
  NotificationSnapshot(this.docs);
  @override
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs;
}

class ScreenNotificationService extends Fake implements NotificationService {
  final controller =
      StreamController<QuerySnapshot<Map<String, dynamic>>>.broadcast();
  final documents = <NotificationDocument>[
    NotificationDocument('first', {
      'userId': 'player',
      'title': 'First update',
      'isRead': false,
    }),
    NotificationDocument('second', {
      'userId': 'player',
      'title': 'Second update',
      'isRead': true,
    }),
  ];
  final deleted = <String>[];
  int watches = 0;
  Object? failure;
  Completer<void>? pending;
  @override
  String get currentUserId => 'player';
  @override
  Stream<QuerySnapshot<Map<String, dynamic>>> watchMyNotifications() {
    watches++;
    return controller.stream;
  }

  void emit() => controller.add(NotificationSnapshot([...documents]));
  @override
  Future<void> deleteNotification(
    String notificationId, {
    String? expectedUserId,
  }) async {
    expect(expectedUserId, 'player');
    deleted.add(notificationId);
    if (pending != null) await pending!.future;
    if (failure != null) throw failure!;
    documents.removeWhere((document) => document.id == notificationId);
    emit();
  }
}

class AuthUser extends Fake implements User {
  AuthUser(this.uid);
  @override
  final String uid;
}

class NotificationAuth extends Fake implements FirebaseAuth {
  @override
  User? currentUser = AuthUser('player');
}

class NotificationFirestore extends Fake implements FirebaseFirestore {
  final owners = <String, String>{'first': 'player', 'second': 'other-user'};
  final deletes = <String>[];
  Object? commitFailure;
  VoidCallback? afterRead;
  int transactions = 0;
  @override
  CollectionReference<Map<String, dynamic>> collection(String path) {
    expect(path, 'notifications');
    return NotificationCollection();
  }

  @override
  Future<T> runTransaction<T>(
    Future<T> Function(Transaction) handler, {
    Duration timeout = const Duration(seconds: 30),
    int maxAttempts = 5,
  }) async {
    transactions++;
    final transaction = NotificationTransaction(this);
    final result = await handler(transaction);
    if (commitFailure != null) throw commitFailure!;
    for (final id in transaction.pendingDeletes) {
      owners.remove(id);
      deletes.add(id);
    }
    return result;
  }
}

class NotificationCollection extends Fake
    implements CollectionReference<Map<String, dynamic>> {
  @override
  DocumentReference<Map<String, dynamic>> doc([String? id]) =>
      NotificationReference(id!);
}

class NotificationReference extends Fake
    implements DocumentReference<Map<String, dynamic>> {
  NotificationReference(this.id);
  @override
  final String id;
}

class NotificationTransaction extends Fake implements Transaction {
  NotificationTransaction(this.store);
  final NotificationFirestore store;
  final pendingDeletes = <String>[];
  @override
  Future<DocumentSnapshot<T>> get<T>(DocumentReference<T> reference) async {
    final owner = store.owners[reference.id];
    store.afterRead?.call();
    return NotificationDocument(reference.id, {
      'userId': owner,
    }, exists: owner != null) as DocumentSnapshot<T>;
  }

  @override
  Transaction delete(DocumentReference reference) {
    pendingDeletes.add(reference.id);
    return this;
  }
}

void main() {
  group('service ownership and persistence', () {
    late NotificationAuth auth;
    late NotificationFirestore store;
    late NotificationService service;
    setUp(() {
      auth = NotificationAuth();
      store = NotificationFirestore();
      service = NotificationService(auth: auth, firestore: store);
    });
    test('deletes exactly the owned ID from the persistent store', () async {
      await service.deleteNotification('first', expectedUserId: 'player');
      expect(store.deletes, ['first']);
      expect(store.owners, {'second': 'other-user'});
    });
    test('rejects another user notification', () async {
      await expectLater(
        service.deleteNotification('second'),
        throwsA(isA<FirebaseException>()),
      );
      expect(store.deletes, isEmpty);
      expect(store.owners['second'], 'other-user');
    });
    test('signed-out user cannot initiate deletion', () async {
      auth.currentUser = null;
      await expectLater(
        service.deleteNotification('first'),
        throwsA(isA<FirebaseAuthException>()),
      );
      expect(store.transactions, 0);
    });
    test('account change while confirming cannot delete', () async {
      auth.currentUser = AuthUser('other-user');
      await expectLater(
        service.deleteNotification('second', expectedUserId: 'player'),
        throwsA(isA<FirebaseAuthException>()),
      );
      expect(store.transactions, 0);
    });
    test('account change during transaction cannot delete', () async {
      store.afterRead = () => auth.currentUser = AuthUser('other-user');
      await expectLater(
        service.deleteNotification('first'),
        throwsA(isA<FirebaseAuthException>()),
      );
      expect(store.deletes, isEmpty);
    });
    test('missing document cannot report successful deletion', () async {
      await expectLater(
        service.deleteNotification('missing'),
        throwsA(isA<FirebaseException>()),
      );
      expect(store.deletes, isEmpty);
    });
    test('failed commit keeps notification persisted', () async {
      store.commitFailure = FirebaseException(
        plugin: 'cloud_firestore',
        code: 'unavailable',
      );
      await expectLater(
        service.deleteNotification('first'),
        throwsA(isA<FirebaseException>()),
      );
      expect(store.owners['first'], 'player');
      expect(store.deletes, isEmpty);
    });
    test('invalid document IDs are rejected', () async {
      for (final id in ['', '  ', 'parent/child']) {
        await expectLater(service.deleteNotification(id), throwsArgumentError);
      }
      expect(store.transactions, 0);
    });
  });

  group('existing notifications screen', () {
    late ScreenNotificationService service;
    setUp(() => service = ScreenNotificationService());
    tearDown(() => service.controller.close());
    Future<void> open(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(home: NotificationsScreen(notificationService: service)),
      );
      service.emit();
      await tester.pumpAndSettle();
    }

    Future<void> confirm(WidgetTester tester, String id) async {
      await tester.tap(find.byKey(ValueKey('delete-notification-$id')));
      await tester.pumpAndSettle();
      expect(find.text('Delete Notification?'), findsOneWidget);
      expect(
        find.text('Are you sure you want to delete this notification?'),
        findsOneWidget,
      );
      await tester.tap(find.widgetWithText(TextButton, 'Delete'));
    }

    testWidgets('cancel leaves notification and unread count unchanged', (
      tester,
    ) async {
      await open(tester);
      await tester.tap(find.byKey(const ValueKey('delete-notification-first')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(service.deleted, isEmpty);
      expect(find.text('First update'), findsOneWidget);
      expect(find.text('1 unread notification'), findsOneWidget);
      expect(service.watches, 1);
    });
    testWidgets('success removes only selected card and updates unread count', (
      tester,
    ) async {
      await open(tester);
      await confirm(tester, 'first');
      await tester.pumpAndSettle();
      expect(service.deleted, ['first']);
      expect(find.text('First update'), findsNothing);
      expect(find.text('Second update'), findsOneWidget);
      expect(find.text('You are all caught up'), findsOneWidget);
      expect(find.text('Notification deleted.'), findsOneWidget);
      expect(service.watches, 1);
      expect(tester.takeException(), isNull);
    });
    testWidgets(
      'final deletion shows existing empty state and stays absent on reopen',
      (tester) async {
        service.documents.removeLast();
        await open(tester);
        await confirm(tester, 'first');
        await tester.pumpAndSettle();
        expect(find.text('No notifications yet'), findsOneWidget);
        await tester.pumpWidget(const SizedBox());
        await open(tester);
        expect(find.text('No notifications yet'), findsOneWidget);
        expect(find.text('First update'), findsNothing);
      },
    );
    testWidgets('failed delete keeps card, displays error and allows retry', (
      tester,
    ) async {
      service.failure = FirebaseException(
        plugin: 'cloud_firestore',
        code: 'permission-denied',
      );
      await open(tester);
      await confirm(tester, 'first');
      await tester.pumpAndSettle();
      expect(find.text('First update'), findsOneWidget);
      expect(find.text('1 unread notification'), findsOneWidget);
      expect(
        find.text('You do not have permission to delete this notification.'),
        findsOneWidget,
      );
      service.failure = null;
      await confirm(tester, 'first');
      await tester.pumpAndSettle();
      expect(find.text('First update'), findsNothing);
    });
    testWidgets('loading prevents duplicate delete and opening card', (
      tester,
    ) async {
      service.pending = Completer<void>();
      await open(tester);
      await confirm(tester, 'first');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(
        find.byKey(const ValueKey('delete-notification-first')),
        findsNothing,
      );
      await tester.tap(find.text('First update'));
      await tester.drag(
        find.byKey(const ValueKey('first')),
        const Offset(-500, 0),
      );
      await tester.pump(const Duration(milliseconds: 300));
      expect(service.deleted, ['first']);
      expect(find.byType(AlertDialog), findsNothing);
      service.pending!.complete();
      await tester.pumpAndSettle();
      expect(find.text('First update'), findsNothing);
      expect(tester.takeException(), isNull);
    });
    testWidgets('swipe uses confirmation and cancellation preserves card', (
      tester,
    ) async {
      await open(tester);
      await tester.drag(
        find.byKey(const ValueKey('first')),
        const Offset(-500, 0),
      );
      await tester.pumpAndSettle();
      expect(find.text('Delete Notification?'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(service.deleted, isEmpty);
      expect(find.text('First update'), findsOneWidget);
    });
    testWidgets(
      'successful swipe relies on stream without dismissible errors',
      (tester) async {
        await open(tester);
        await tester.drag(
          find.byKey(const ValueKey('first')),
          const Offset(-500, 0),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.widgetWithText(TextButton, 'Delete'));
        await tester.pumpAndSettle();
        expect(find.text('First update'), findsNothing);
        expect(find.text('Second update'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  });
}
