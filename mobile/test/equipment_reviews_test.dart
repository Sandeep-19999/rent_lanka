// Controlled Firebase SDK doubles; no demo data is written to the application.
// ignore_for_file: subtype_of_sealed_class

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rent_lanka_mobile/features/exchange_messaging_profile/models/review_equipment_option.dart';
import 'package:rent_lanka_mobile/features/exchange_messaging_profile/models/review_model.dart';
import 'package:rent_lanka_mobile/features/exchange_messaging_profile/screens/rate_review_screen.dart';
import 'package:rent_lanka_mobile/features/exchange_messaging_profile/services/completed_rental_service.dart';
import 'package:rent_lanka_mobile/features/exchange_messaging_profile/services/review_service.dart';
import 'package:rent_lanka_mobile/features/user_discovery/widgets/equipment_rating.dart';

class ReviewDocument extends Fake
    implements QueryDocumentSnapshot<Map<String, dynamic>> {
  ReviewDocument(this.id, this.values, {this.exists = true});
  @override
  final String id;
  final Map<String, dynamic> values;
  @override
  final bool exists;
  @override
  Map<String, dynamic> data() => values;
}

class ReviewSnapshot extends Fake
    implements QuerySnapshot<Map<String, dynamic>> {
  ReviewSnapshot(this.docs);
  @override
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs;
}

class ReviewUser extends Fake implements User {
  @override
  String get uid => 'player';
}

class ReviewAuth extends Fake implements FirebaseAuth {
  @override
  User? currentUser = ReviewUser();
}

class ReviewStore extends Fake implements FirebaseFirestore {
  final changes = StreamController<void>.broadcast();
  final queryIds = <String>[];
  final ownerQueryIds = <String>[];
  Object? readError;
  int clock = 200;
  final records = <String, Map<String, dynamic>>{
    'reviews/alice_rental': {
      'reviewerId': 'alice',
      'equipmentId': 'bat',
      'providerId': 'provider',
      'bookingId': 'rental',
      'rating': 5,
      'comment': 'Excellent bat',
      'createdAt': Timestamp.fromDate(DateTime(2026, 10, 9, 12)),
    },
    'reviews/bob_rental': {
      'reviewerId': 'bob',
      'equipmentId': 'bat',
      'providerId': 'provider',
      'bookingId': 'rental',
      'rating': 3,
      'comment': 'Good grip',
    },
    'reviews/other_equipment': {
      'reviewerId': 'other',
      'equipmentId': 'ball',
      'rating': 1,
      'comment': 'Only for another equipment',
    },
    'users/alice': {'name': 'Alice'},
    'users/bob': {'name': 'Bob'},
    'users/player': {'name': 'Player'},
    'rental_requests/own-rental': {
      'playerId': 'player',
      'providerId': 'provider',
      'equipmentId': 'bat',
      'status': 'completed',
    },
  };
  @override
  CollectionReference<Map<String, dynamic>> collection(String path) =>
      ReviewCollection(this, path);
  void emit() => changes.add(null);
  Map<String, dynamic> resolve(Map<String, dynamic> data) => {
    for (final entry in data.entries)
      entry.key: entry.value is FieldValue
          ? Timestamp(clock++, 0)
          : entry.value,
  };
  @override
  Future<T> runTransaction<T>(
    Future<T> Function(Transaction) handler, {
    Duration timeout = const Duration(seconds: 30),
    int maxAttempts = 5,
  }) async {
    final transaction = ReviewTransaction(this);
    final result = await handler(transaction);
    for (final entry in transaction.pending.entries) {
      records[entry.key] = {...?records[entry.key], ...resolve(entry.value)};
    }
    for (final path in transaction.deleted) {
      records.remove(path);
    }
    emit();
    return result;
  }
}

class ReviewCollection extends Fake
    implements CollectionReference<Map<String, dynamic>> {
  ReviewCollection(
    this.store,
    this.path, [
    this.equipmentId,
    this.filterField = 'equipmentId',
  ]);
  final ReviewStore store;
  @override
  final String path;
  final String? equipmentId;
  final String filterField;
  @override
  DocumentReference<Map<String, dynamic>> doc([String? id]) =>
      ReviewReference(store, '$path/$id');
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
    expect(path, 'reviews');
    expect(['equipmentId', 'reviewerId'], contains(field));
    if (field == 'equipmentId') {
      store.queryIds.add(isEqualTo as String);
    } else {
      store.ownerQueryIds.add(isEqualTo as String);
    }
    return ReviewCollection(store, path, isEqualTo, field as String);
  }

  @override
  Stream<QuerySnapshot<Map<String, dynamic>>> snapshots({
    bool includeMetadataChanges = false,
    ListenSource source = ListenSource.defaultSource,
  }) => Stream.multi((controller) {
    void emit() {
      if (store.readError != null) {
        controller.addError(store.readError!);
        return;
      }
      controller.add(
        ReviewSnapshot([
          for (final entry in store.records.entries)
            if (entry.key.startsWith('$path/') &&
                entry.value[filterField] == equipmentId)
              ReviewDocument(entry.key.split('/').last, Map.from(entry.value)),
        ]),
      );
    }

    final subscription = store.changes.stream.listen((_) => emit());
    controller.onCancel = subscription.cancel;
    emit();
  });
}

class ReviewReference extends Fake
    implements DocumentReference<Map<String, dynamic>> {
  ReviewReference(this.store, this.path);
  final ReviewStore store;
  @override
  final String path;
  @override
  Future<DocumentSnapshot<Map<String, dynamic>>> get([
    GetOptions? options,
  ]) async {
    final data = store.records[path];
    return ReviewDocument(
      path.split('/').last,
      data ?? {},
      exists: data != null,
    );
  }

  @override
  Future<void> delete() async {
    store.records.remove(path);
    store.emit();
  }
}

class ReviewTransaction extends Fake implements Transaction {
  ReviewTransaction(this.store);
  final ReviewStore store;
  final pending = <String, Map<String, dynamic>>{};
  final deleted = <String>{};
  @override
  Transaction delete(DocumentReference<Object?> reference) {
    deleted.add(reference.path);
    return this;
  }

  @override
  Future<DocumentSnapshot<T>> get<T>(DocumentReference<T> reference) async =>
      await (reference as ReviewReference).get() as DocumentSnapshot<T>;
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

class ReviewRentals extends Fake implements CompletedRentalService {
  ReviewRentals([this.extra = const []]);
  final List<ReviewEquipmentOption> extra;
  @override
  Stream<List<ReviewEquipmentOption>> watchCompletedRentals() => Stream.value([
    const ReviewEquipmentOption(
      equipmentId: 'bat',
      providerId: 'provider',
      bookingId: 'own-rental',
      equipmentName: 'Cricket Bat',
      rentedDate: '9 Oct 2026',
    ),
    const ReviewEquipmentOption(
      equipmentId: 'ball',
      providerId: 'provider',
      bookingId: 'other-rental',
      equipmentName: 'Unrelated Ball',
      rentedDate: '8 Oct 2026',
    ),
    ...extra,
  ]);
}

void main() {
  late ReviewStore store;
  late ReviewAuth auth;
  late ReviewService service;
  setUp(() {
    store = ReviewStore();
    auth = ReviewAuth();
    service = ReviewService(firestore: store, auth: auth);
  });
  tearDown(() => store.changes.close());

  Future<void> openReviews(
    WidgetTester tester, {
    String equipmentId = 'bat',
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: RateReviewScreen(
          equipmentId: equipmentId,
          equipmentName: 'Cricket Bat',
          reviewService: service,
          completedRentalService: ReviewRentals(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tapVisible(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  test(
    'query scopes reviews to actual equipment ID and averages stored stars',
    () async {
      final reviews = await service.watchEquipmentReviews('bat').first;
      expect(store.queryIds, ['bat']);
      expect(reviews.map((review) => review.equipmentId), everyElement('bat'));
      expect(reviews.length, 2);
      expect(ReviewService.averageRating(reviews), 4);
      expect(ReviewService.averageRating([]), isNull);
    },
  );
  test('reviewer names use existing user profiles', () async {
    expect(await service.getReviewerName('alice'), 'Alice');
    expect(await service.getReviewerName('deleted-user'), 'Rent Lanka User');
  });
  test(
    'CRUD stream updates aggregate and retains other equipment reviews',
    () async {
      final updates = <List<ReviewModel>>[];
      final subscription = service
          .watchEquipmentReviews('bat')
          .listen(updates.add);
      await Future<void>.delayed(Duration.zero);
      await service.saveReview(
        providerId: 'provider',
        equipmentId: 'bat',
        bookingId: 'own-rental',
        rating: 5,
        comment: 'My review',
      );
      await Future<void>.delayed(Duration.zero);
      expect(updates.last.length, 3);
      expect(ReviewService.averageRating(updates.last), closeTo(13 / 3, 0.001));
      await service.saveReview(
        providerId: 'provider',
        equipmentId: 'bat',
        bookingId: 'own-rental',
        rating: 1,
        comment: 'Updated review',
      );
      await Future<void>.delayed(Duration.zero);
      expect(ReviewService.averageRating(updates.last), 3);
      await service.deleteReview('own-rental');
      await Future<void>.delayed(Duration.zero);
      expect(updates.last.length, 2);
      expect(ReviewService.averageRating(updates.last), 4);
      expect(store.records.containsKey('reviews/other_equipment'), true);
      await subscription.cancel();
    },
  );
  testWidgets(
    'rating tap opens existing page for selected equipment and Back returns',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EquipmentRating(
              equipmentId: 'bat',
              equipmentName: 'Cricket Bat',
              reviewService: service,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('4.0'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('equipment-rating')));
      await tester.pumpAndSettle();
      expect(find.byType(RateReviewScreen), findsOneWidget);
      expect(
        tester
            .widget<RateReviewScreen>(find.byType(RateReviewScreen))
            .equipmentId,
        'bat',
      );
      expect(find.text('Ratings & Reviews'), findsOneWidget);
      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);
      expect(find.text('Excellent bat'), findsOneWidget);
      expect(find.text('Good grip'), findsOneWidget);
      expect(find.text('9/10/2026'), findsOneWidget);
      expect(find.text('Only for another equipment'), findsNothing);
      expect(find.text('4.0 / 5'), findsOneWidget);
      expect(find.text('2 reviews'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
      await tester.pumpAndSettle();
      expect(find.byType(RateReviewScreen), findsNothing);
      expect(find.text('Equipment rating'), findsOneWidget);
      expect(find.text('4.0'), findsOneWidget);
    },
  );
  testWidgets('badge and review page reflect live edits and deletion', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EquipmentRating(
            equipmentId: 'bat',
            equipmentName: 'Cricket Bat',
            reviewService: service,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('equipment-rating')));
    await tester.pumpAndSettle();
    store.records['reviews/alice_rental']!['rating'] = 1;
    store.emit();
    await tester.pumpAndSettle();
    expect(find.text('2.0 / 5'), findsOneWidget);
    store.records.remove('reviews/bob_rental');
    store.emit();
    await tester.pumpAndSettle();
    expect(find.text('1.0 / 5'), findsOneWidget);
    expect(find.text('1 review'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pumpAndSettle();
    expect(find.text('1.0'), findsOneWidget);
  });
  testWidgets(
    'empty equipment shows honest empty state and no hardcoded rating',
    (tester) async {
      await openReviews(tester, equipmentId: 'empty-equipment');
      expect(find.text('No reviews yet for this equipment.'), findsOneWidget);
      expect(find.text('0 reviews'), findsOneWidget);
      expect(find.text('No ratings yet'), findsOneWidget);
      expect(find.text('Excellent bat'), findsNothing);
    },
  );
  testWidgets('loading and Firebase error are visible', (tester) async {
    store.readError = FirebaseException(
      plugin: 'cloud_firestore',
      code: 'permission-denied',
    );
    await tester.pumpWidget(
      MaterialApp(
        home: RateReviewScreen(equipmentId: 'bat', reviewService: service),
      ),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pumpAndSettle();
    expect(
      find.text('Unable to load ratings and reviews. Please try again.'),
      findsOneWidget,
    );
    expect(find.text('No reviews yet for this equipment.'), findsNothing);
  });
  testWidgets(
    'existing editor still adds, edits and deletes the selected equipment review',
    (tester) async {
      await openReviews(tester);
      await tapVisible(tester, find.text('Write or manage your review'));
      expect(find.text('Rate & Review'), findsOneWidget);
      expect(find.text('Cricket Bat'), findsOneWidget);
      expect(find.text('Unrelated Ball'), findsNothing);
      await tapVisible(tester, find.byIcon(Icons.star_border_rounded).last);
      await tester.enterText(
        find.byType(TextField),
        'My completed rental review',
      );
      await tapVisible(tester, find.text('Submit Review'));
      expect(store.records['reviews/player_own-rental']?['rating'], 5);
      expect(find.text('Review submitted successfully.'), findsOneWidget);
      await tapVisible(tester, find.byIcon(Icons.star_rounded).first);
      await tester.enterText(find.byType(TextField), 'My edited review');
      await tapVisible(tester, find.text('Update Review'));
      expect(store.records['reviews/player_own-rental']?['rating'], 1);
      expect(
        store.records['reviews/player_own-rental']?['comment'],
        'My edited review',
      );
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
      await tester.pumpAndSettle();
      expect(find.text('3.0 / 5'), findsOneWidget);
      expect(find.text('3 reviews'), findsOneWidget);
      await tapVisible(tester, find.text('Write or manage your review'));
      expect(find.text('Update Review'), findsOneWidget);
      await tapVisible(tester, find.text('Delete Review'));
      await tester.tap(find.widgetWithText(TextButton, 'Delete'));
      await tester.pumpAndSettle();
      expect(store.records.containsKey('reviews/player_own-rental'), false);
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
      await tester.pumpAndSettle();
      expect(find.text('4.0 / 5'), findsOneWidget);
      expect(find.text('2 reviews'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('reusing rating widget switches to the new equipment query', (
    tester,
  ) async {
    Widget host(String id) => MaterialApp(
      home: Scaffold(
        body: EquipmentRating(
          equipmentId: id,
          equipmentName: 'Selected equipment',
          reviewService: service,
        ),
      ),
    );
    await tester.pumpWidget(host('bat'));
    await tester.pumpAndSettle();
    expect(find.text('4.0'), findsOneWidget);
    await tester.pumpWidget(host('ball'));
    await tester.pumpAndSettle();
    expect(find.text('1.0'), findsOneWidget);
    expect(find.text('4.0'), findsNothing);
    expect(store.queryIds, ['bat', 'ball']);
  });
  testWidgets(
    'booking review stays on its item without a completed-item selector',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: RateReviewScreen(
            initialBookingId: 'own-rental',
            reviewService: service,
            completedRentalService: ReviewRentals(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Cricket Bat'), findsOneWidget);
      expect(find.text('Unrelated Ball'), findsNothing);
      expect(find.text('Booking: own-rental'), findsOneWidget);
      expect(find.byIcon(Icons.keyboard_arrow_down_rounded), findsNothing);
      await tester.tap(find.text('Cricket Bat'));
      await tester.pumpAndSettle();
      expect(find.text('Select completed rental'), findsNothing);
    },
  );
  testWidgets(
    'missing requested booking never falls back to another completed item',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: RateReviewScreen(
            initialBookingId: 'missing',
            reviewService: service,
            completedRentalService: ReviewRentals(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Submit Review'), findsNothing);
      expect(find.text('Cricket Bat'), findsNothing);
      expect(find.text('Unrelated Ball'), findsNothing);
    },
  );
  testWidgets(
    'generic review entry directs the user to bookings without silently selecting an item',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: RateReviewScreen(
            reviewService: service,
            completedRentalService: ReviewRentals(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('My Bookings'), findsOneWidget);
      expect(find.text('Submit Review'), findsNothing);
      expect(find.text('Cricket Bat'), findsNothing);
    },
  );
  testWidgets('equipment editor reviews only the item used to open it', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: RateReviewScreen(
          equipmentId: 'bat',
          showEditor: true,
          reviewService: service,
          completedRentalService: ReviewRentals(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Cricket Bat'), findsOneWidget);
    expect(find.text('Unrelated Ball'), findsNothing);
    expect(find.text('Submit Review'), findsOneWidget);
    expect(find.byIcon(Icons.keyboard_arrow_down_rounded), findsNothing);
  });
  testWidgets(
    'submitted reviews reopen their exact booking for edit and delete from My Reviews',
    (tester) async {
      store.records['equipment/bat'] = {'name': 'Cricket Bat'};
      store.records['rental_requests/history'] = {
        'playerId': 'player',
        'providerId': 'provider',
        'equipmentId': 'bat',
        'status': 'completed',
      };
      await service.saveReview(
        providerId: 'provider',
        equipmentId: 'bat',
        bookingId: 'own-rental',
        rating: 4,
        comment: 'Keep my other review',
      );
      await service.saveReview(
        providerId: 'provider',
        equipmentId: 'bat',
        bookingId: 'history',
        rating: 2,
        comment: 'My earlier review',
      );
      final rentals = ReviewRentals([
        const ReviewEquipmentOption(
          equipmentId: 'bat',
          providerId: 'provider',
          bookingId: 'history',
          equipmentName: 'Cricket Bat',
          rentedDate: '1 Oct 2026',
        ),
      ]);
      await tester.pumpWidget(
        MaterialApp(
          home: RateReviewScreen(
            reviewService: service,
            completedRentalService: rentals,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(store.ownerQueryIds, ['player']);
      expect(find.text('My earlier review'), findsOneWidget);
      expect(find.text('Excellent bat'), findsNothing);
      final historyCard = find.byKey(
        const ValueKey('equipment-review-player_history'),
      );
      await tapVisible(
        tester,
        find.descendant(
          of: historyCard,
          matching: find.widgetWithText(TextButton, 'Edit'),
        ),
      );
      expect(find.text('Booking: history'), findsOneWidget);
      expect(find.text('My earlier review'), findsOneWidget);
      await tester.enterText(
        find.byType(TextField),
        'My updated earlier review',
      );
      await tapVisible(tester, find.text('Update Review'));
      expect(
        store.records['reviews/player_history']?['comment'],
        'My updated earlier review',
      );
      expect(
        store.records['reviews/player_own-rental']?['comment'],
        'Keep my other review',
      );
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
      await tester.pumpAndSettle();
      expect(find.text('My updated earlier review'), findsOneWidget);
      await tapVisible(
        tester,
        find.descendant(
          of: historyCard,
          matching: find.widgetWithText(TextButton, 'Delete'),
        ),
      );
      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('Keep Review'),
        ),
      );
      await tester.pumpAndSettle();
      expect(store.records.containsKey('reviews/player_history'), isTrue);
      await tapVisible(
        tester,
        find.descendant(
          of: historyCard,
          matching: find.widgetWithText(TextButton, 'Delete'),
        ),
      );
      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('Delete'),
        ),
      );
      await tester.pumpAndSettle();
      expect(store.records.containsKey('reviews/player_history'), isFalse);
      expect(find.text('My updated earlier review'), findsNothing);
      expect(store.records.containsKey('reviews/player_own-rental'), isTrue);
      expect(store.records.containsKey('reviews/alice_rental'), isTrue);
    },
  );
  testWidgets(
    'equipment review cards expose edit/delete only for the current owner',
    (tester) async {
      await service.saveReview(
        providerId: 'provider',
        equipmentId: 'bat',
        bookingId: 'own-rental',
        rating: 4,
        comment: 'My review',
      );
      await tester.pumpWidget(
        MaterialApp(
          home: RateReviewScreen(
            equipmentId: 'bat',
            reviewService: service,
            completedRentalService: ReviewRentals(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.widgetWithText(TextButton, 'Edit'), findsOneWidget);
      expect(find.widgetWithText(TextButton, 'Delete'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('equipment-review-alice_rental')),
          matching: find.widgetWithText(TextButton, 'Edit'),
        ),
        findsNothing,
      );
    },
  );
  test(
    'delete rejects an inconsistent review owner before mutating the record',
    () async {
      store.records['reviews/player_own-rental'] = {
        'reviewerId': 'other',
        'bookingId': 'own-rental',
        'equipmentId': 'bat',
        'comment': 'Other review',
      };
      await expectLater(service.deleteReview('own-rental'), throwsStateError);
      expect(
        store.records['reviews/player_own-rental']?['comment'],
        'Other review',
      );
    },
  );
  testWidgets('legacy review entry still opens the existing editor', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: RateReviewScreen(
          initialBookingId: 'own-rental',
          reviewService: service,
          completedRentalService: ReviewRentals(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Rate & Review'), findsOneWidget);
    expect(find.text('Submit Review'), findsOneWidget);
    expect(find.text('Ratings & Reviews'), findsNothing);
  });
}
