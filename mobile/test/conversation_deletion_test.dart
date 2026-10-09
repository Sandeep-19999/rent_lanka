// Firebase SDK doubles only; production uses the real SDK.
// ignore_for_file: subtype_of_sealed_class

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rent_lanka_mobile/features/exchange_messaging_profile/screens/messages_screen.dart';
import 'package:rent_lanka_mobile/features/exchange_messaging_profile/screens/chat_screen.dart';
import 'package:rent_lanka_mobile/features/exchange_messaging_profile/services/chat_service.dart';

class ChatDocument extends Fake
    implements QueryDocumentSnapshot<Map<String, dynamic>> {
  ChatDocument(
    this.id,
    this.values, {
    this.exists = true,
    this.pending = false,
  });
  @override
  final String id;
  final Map<String, dynamic> values;
  @override
  final bool exists;
  final bool pending;
  @override
  Map<String, dynamic> data() => values;
  @override
  SnapshotMetadata get metadata => ChatMetadata(pending);
}

class ChatMetadata extends Fake implements SnapshotMetadata {
  ChatMetadata(this.hasPendingWrites);
  @override
  final bool hasPendingWrites;
}

class ChatSnapshot extends Fake implements QuerySnapshot<Map<String, dynamic>> {
  ChatSnapshot(this.docs);
  @override
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs;
}

class ChatUser extends Fake implements User {
  ChatUser(this.uid);
  @override
  final String uid;
}

class ChatAuth extends Fake implements FirebaseAuth {
  @override
  User? currentUser = ChatUser('player');
}

class ChatFirestore extends Fake implements FirebaseFirestore {
  final records = <String, Map<String, dynamic>>{
    'chats/one': {
      'participants': ['player', 'provider'],
      'lastMessageAt': Timestamp(100, 0),
    },
    'chats/two': {
      'participants': ['provider', 'someone-else'],
    },
    'chats/one/messages/message': {
      'text': 'Shared message',
      'senderId': 'provider',
    },
  };
  final writes = <String>[];
  Object? commitError;
  VoidCallback? afterRead;
  int transactions = 0;
  @override
  CollectionReference<Map<String, dynamic>> collection(String path) =>
      ChatCollection(path);
  @override
  Future<T> runTransaction<T>(
    Future<T> Function(Transaction) handler, {
    Duration timeout = const Duration(seconds: 30),
    int maxAttempts = 5,
  }) async {
    transactions++;
    final transaction = ChatTransaction(this);
    final result = await handler(transaction);
    if (commitError != null) throw commitError!;
    for (final entry in transaction.pending.entries) {
      expect(entry.value['hiddenAt'], isA<FieldValue>());
      records[entry.key] = {'hiddenAt': Timestamp(200, 0)};
      writes.add(entry.key);
    }
    return result;
  }
}

class ChatCollection extends Fake
    implements CollectionReference<Map<String, dynamic>> {
  ChatCollection(this.path);
  @override
  final String path;
  @override
  DocumentReference<Map<String, dynamic>> doc([String? id]) =>
      ChatReference('$path/$id');
}

class ChatReference extends Fake
    implements DocumentReference<Map<String, dynamic>> {
  ChatReference(this.path);
  @override
  final String path;
  @override
  CollectionReference<Map<String, dynamic>> collection(String name) =>
      ChatCollection('$path/$name');
}

class ChatTransaction extends Fake implements Transaction {
  ChatTransaction(this.store);
  final ChatFirestore store;
  final pending = <String, Map<String, dynamic>>{};
  @override
  Future<DocumentSnapshot<T>> get<T>(DocumentReference<T> reference) async {
    final data = store.records[reference.path];
    store.afterRead?.call();
    return ChatDocument(reference.path, data ?? {}, exists: data != null)
        as DocumentSnapshot<T>;
  }

  @override
  Transaction set<T>(
    DocumentReference<T> reference,
    T data, [
    SetOptions? options,
  ]) {
    pending[reference.path] = data as Map<String, dynamic>;
    return this;
  }
}

class ScreenChatService extends Fake implements ChatService {
  final chats =
      StreamController<QuerySnapshot<Map<String, dynamic>>>.broadcast();
  final markers =
      StreamController<QuerySnapshot<Map<String, dynamic>>>.broadcast();
  final documents = <ChatDocument>[
    ChatDocument('one', {
      'participants': ['player', 'alice'],
      'participantNames': {'alice': 'Alice'},
      'lastMessage': 'Hello',
      'lastMessageAt': Timestamp(100, 0),
      'unreadCounts': {'player': 1},
    }),
    ChatDocument('two', {
      'participants': ['player', 'bob'],
      'participantNames': {'bob': 'Bob'},
      'lastMessage': 'Bat available',
      'lastMessageAt': Timestamp(90, 0),
    }),
  ];
  final hidden = <ChatDocument>[];
  final calls = <String>[];
  Object? failure;
  Completer<void>? pending;
  int watches = 0;
  final readCalls = <String>[];
  @override
  Future<void> markChatAsRead(String chatId) async {
    readCalls.add(chatId);
  }

  @override
  String get currentUserId => 'player';
  @override
  Stream<QuerySnapshot<Map<String, dynamic>>> watchMyChats() {
    watches++;
    return chats.stream;
  }

  @override
  Stream<QuerySnapshot<Map<String, dynamic>>> watchMyHiddenConversations() =>
      markers.stream;
  void emit() {
    chats.add(ChatSnapshot([...documents]));
    markers.add(ChatSnapshot([...hidden]));
  }

  @override
  Future<void> deleteConversation(
    String chatId, {
    String? expectedUserId,
  }) async {
    expect(expectedUserId, 'player');
    calls.add(chatId);
    if (pending != null) await pending!.future;
    if (failure != null) throw failure!;
    hidden.removeWhere((document) => document.id == chatId);
    hidden.add(ChatDocument(chatId, {'hiddenAt': Timestamp(200, 0)}));
    emit();
  }
}

class RouteObserverForTest extends NavigatorObserver {
  Route<dynamic>? lastPushed;
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    lastPushed = route;
  }
}

void main() {
  group('Firebase-backed private deletion', () {
    late ChatAuth auth;
    late ChatFirestore store;
    late ChatService service;
    setUp(() {
      auth = ChatAuth();
      store = ChatFirestore();
      service = ChatService(auth: auth, firestore: store);
    });
    test('writes only current user marker and leaves chat/messages/other user intact', () async {
      final original = Map<String, Map<String, dynamic>>.from(store.records);
      await service.deleteConversation('one', expectedUserId: 'player');
      expect(store.writes, ['users/player/hidden_conversations/one']);
      for (final entry in original.entries) {
        expect(store.records[entry.key], entry.value);
      }
      expect(
        store.records.containsKey('users/provider/hidden_conversations/one'),
        false,
      );
      final reopenedService = ChatService(auth: auth, firestore: store);
      expect(reopenedService.currentUserId, 'player');
      expect(
        ChatService.isConversationHidden(
          store.records['chats/one']!,
          store.records['users/player/hidden_conversations/one'],
        ),
        true,
      );
      expect(
        ChatService.isConversationHidden(
          store.records['chats/one']!,
          store.records['users/provider/hidden_conversations/one'],
        ),
        false,
      );
    });
    test('nonparticipant cannot hide a conversation', () async {
      await expectLater(
        service.deleteConversation('two'),
        throwsA(isA<FirebaseException>()),
      );
      expect(store.writes, isEmpty);
    });
    test('signed-out user cannot delete', () async {
      auth.currentUser = null;
      await expectLater(
        service.deleteConversation('one'),
        throwsA(isA<FirebaseAuthException>()),
      );
      expect(store.transactions, 0);
    });
    test('account change after confirmation prevents writes', () async {
      auth.currentUser = ChatUser('provider');
      await expectLater(
        service.deleteConversation('one', expectedUserId: 'player'),
        throwsA(isA<FirebaseAuthException>()),
      );
      expect(store.transactions, 0);
    });
    test('account change during transaction prevents writes', () async {
      store.afterRead = () => auth.currentUser = ChatUser('provider');
      await expectLater(
        service.deleteConversation('one'),
        throwsA(isA<FirebaseAuthException>()),
      );
      expect(store.writes, isEmpty);
    });
    test('failed commit preserves visibility and shared documents', () async {
      store.commitError = FirebaseException(
        plugin: 'cloud_firestore',
        code: 'permission-denied',
      );
      await expectLater(
        service.deleteConversation('one'),
        throwsA(isA<FirebaseException>()),
      );
      expect(store.writes, isEmpty);
      expect(store.records.containsKey('chats/one/messages/message'), true);
    });
    test('missing chat cannot create marker', () async {
      await expectLater(
        service.deleteConversation('missing'),
        throwsA(isA<FirebaseException>()),
      );
      expect(store.writes, isEmpty);
    });
    test('invalid IDs cannot create document paths', () async {
      for (final id in ['', '  ', 'one/messages']) {
        await expectLater(service.deleteConversation(id), throwsArgumentError);
      }
      expect(store.transactions, 0);
    });
    test('only a newer message restores visibility', () {
      final hidden = {'hiddenAt': Timestamp(200, 0)};
      expect(
        ChatService.isConversationHidden({
          'lastMessageAt': Timestamp(199, 0),
        }, hidden),
        true,
      );
      expect(
        ChatService.isConversationHidden({
          'lastMessageAt': Timestamp(200, 0),
        }, hidden),
        true,
      );
      expect(
        ChatService.isConversationHidden({
          'lastMessageAt': Timestamp(200, 1),
        }, hidden),
        false,
      );
      expect(
        ChatService.isConversationHidden({
          'updatedAt': Timestamp(300, 0),
        }, hidden),
        true,
      );
      expect(ChatService.isConversationHidden({}, null), false);
    });
  });

  group('existing Messages screen', () {
    late ScreenChatService service;
    setUp(() => service = ScreenChatService());
    tearDown(() async {
      await service.chats.close();
      await service.markers.close();
    });
    Future<void> open(
      WidgetTester tester, {
      NavigatorObserver? observer,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          navigatorObservers: [?observer],
          home: MessagesScreen(
            chatService: service,
            bottomNavigationBar: const SizedBox.shrink(),
          ),
        ),
      );
      service.markers.add(ChatSnapshot([...service.hidden]));
      await tester.pump();
      service.chats.add(ChatSnapshot([...service.documents]));
      await tester.pumpAndSettle();
    }

    Future<void> showConfirmation(WidgetTester tester, String id) async {
      await tester.longPress(find.byKey(ValueKey('conversation-$id')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete Conversation'));
      await tester.pumpAndSettle();
      expect(find.text('Delete Conversation?'), findsOneWidget);
      expect(
        find.text(
          'Are you sure you want to delete this conversation from your messages?',
        ),
        findsOneWidget,
      );
    }

    testWidgets(
      'normal tap still opens existing ChatScreen with correct chat',
      (tester) async {
        final observer = RouteObserverForTest();
        await open(tester, observer: observer);
        await tester.tap(find.text('Bob'));
        await tester.idle();
        final route = observer.lastPushed! as MaterialPageRoute;
        final screen = route.builder(
          tester.element(find.byType(MessagesScreen)),
        ) as ChatScreen;
        expect(screen.chatId, 'two');
        expect(screen.chatName, 'Bob');
        expect(screen.otherUserId, 'bob');
        expect(service.readCalls, ['two']);
        expect(service.calls, isEmpty);
        // The existing chat's Firebase-backed build is outside this isolated
        // navigation test; remove the host before building the pushed route.
        await tester.pumpWidget(const SizedBox());
        expect(tester.takeException(), isNull);
      },
    );
    testWidgets('cancel makes no changes', (tester) async {
      await open(tester);
      await showConfirmation(tester, 'one');
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(service.calls, isEmpty);
      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);
      expect(service.watches, 1);
    });
    testWidgets(
      'confirmed delete removes only selected chat and search still works',
      (tester) async {
        await open(tester);
        await showConfirmation(tester, 'one');
        await tester.tap(find.widgetWithText(TextButton, 'Delete'));
        await tester.pumpAndSettle();
        expect(service.calls, ['one']);
        expect(find.text('Alice'), findsNothing);
        expect(find.text('Bob'), findsOneWidget);
        expect(find.text('Conversation deleted.'), findsOneWidget);
        await tester.enterText(find.byType(TextField), 'bat');
        await tester.pumpAndSettle();
        expect(find.text('Bob'), findsOneWidget);
        await tester.enterText(find.byType(TextField), 'alice');
        await tester.pumpAndSettle();
        expect(find.text('No conversations found'), findsOneWidget);
        await tester.tap(find.byIcon(Icons.close_rounded));
        await tester.pumpAndSettle();
        expect(find.text('Bob'), findsOneWidget);
        expect(service.watches, 1);
      },
    );
    testWidgets('deleting final chat persists through screen recreation', (
      tester,
    ) async {
      service.documents.removeLast();
      await open(tester);
      await showConfirmation(tester, 'one');
      await tester.tap(find.widgetWithText(TextButton, 'Delete'));
      await tester.pumpAndSettle();
      expect(find.text('No conversations yet'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await open(tester);
      expect(find.text('No conversations yet'), findsOneWidget);
      expect(find.text('Alice'), findsNothing);
    });
    testWidgets('failure leaves card visible and permits retry', (
      tester,
    ) async {
      service.failure = FirebaseException(
        plugin: 'cloud_firestore',
        code: 'unavailable',
      );
      await open(tester);
      await showConfirmation(tester, 'one');
      await tester.tap(find.widgetWithText(TextButton, 'Delete'));
      await tester.pumpAndSettle();
      expect(find.text('Alice'), findsOneWidget);
      expect(
        find.text(
          'Unable to delete conversation. Check your connection and try again.',
        ),
        findsOneWidget,
      );
      service.failure = null;
      await showConfirmation(tester, 'one');
      await tester.tap(find.widgetWithText(TextButton, 'Delete'));
      await tester.pumpAndSettle();
      expect(find.text('Alice'), findsNothing);
    });
    testWidgets('loading blocks duplicate actions and tap navigation', (
      tester,
    ) async {
      service.pending = Completer<void>();
      await open(tester);
      await showConfirmation(tester, 'one');
      await tester.tap(find.widgetWithText(TextButton, 'Delete'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.longPress(find.byKey(const ValueKey('conversation-one')));
      await tester.tap(find.text('Alice'));
      await tester.pump();
      expect(service.calls, ['one']);
      expect(find.text('Delete Conversation'), findsNothing);
      service.pending!.complete();
      await tester.pumpAndSettle();
      expect(find.text('Alice'), findsNothing);
      expect(tester.takeException(), isNull);
    });
    testWidgets('new message restores chat but metadata changes do not', (
      tester,
    ) async {
      service.hidden.add(ChatDocument('one', {'hiddenAt': Timestamp(200, 0)}));
      await open(tester);
      expect(find.text('Alice'), findsNothing);
      service.documents.first.values['updatedAt'] = Timestamp(300, 0);
      service.emit();
      await tester.pumpAndSettle();
      expect(find.text('Alice'), findsNothing);
      service.documents.first.values['lastMessageAt'] = Timestamp(301, 0);
      service.emit();
      await tester.pumpAndSettle();
      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);
    });
    testWidgets('pending visibility write does not prematurely remove card', (
      tester,
    ) async {
      service.hidden.add(
        ChatDocument('one', {'hiddenAt': Timestamp(200, 0)}, pending: true),
      );
      await open(tester);
      expect(find.text('Alice'), findsOneWidget);
      service.hidden[0] = ChatDocument('one', {'hiddenAt': Timestamp(200, 0)});
      service.emit();
      await tester.pumpAndSettle();
      expect(find.text('Alice'), findsNothing);
    });
  });
}
