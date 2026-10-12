// ignore_for_file: subtype_of_sealed_class
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rent_lanka_mobile/features/user_discovery/models/favourite_model.dart';
import 'package:rent_lanka_mobile/features/user_discovery/services/favourite_service.dart';
import 'package:rent_lanka_mobile/features/user_discovery/screens/favourites/my_favourites_screen.dart';

class FavouriteAuth extends Fake implements FirebaseAuth {}

class EquipmentSnapshot extends Fake
    implements DocumentSnapshot<Map<String, dynamic>> {
  EquipmentSnapshot(this.values);
  final Map<String, dynamic>? values;
  @override
  bool get exists => values != null;
  @override
  Map<String, dynamic>? data() => values;
}

class EquipmentStore extends Fake implements FirebaseFirestore {
  final controllers =
      <String, StreamController<DocumentSnapshot<Map<String, dynamic>>>>{};
  final watches = <String, int>{};
  @override
  CollectionReference<Map<String, dynamic>> collection(String path) {
    expect(path, 'equipment');
    return EquipmentCollection(this);
  }
}

class EquipmentCollection extends Fake
    implements CollectionReference<Map<String, dynamic>> {
  EquipmentCollection(this.store);
  final EquipmentStore store;
  @override
  DocumentReference<Map<String, dynamic>> doc([String? path]) =>
      EquipmentReference(store, path!);
}

class EquipmentReference extends Fake
    implements DocumentReference<Map<String, dynamic>> {
  EquipmentReference(this.store, this.id);
  final EquipmentStore store;
  @override
  final String id;
  @override
  Stream<DocumentSnapshot<Map<String, dynamic>>> snapshots({
    bool includeMetadataChanges = false,
    ListenSource source = ListenSource.defaultSource,
  }) {
    store.watches[id] = (store.watches[id] ?? 0) + 1;
    return (store.controllers[id] ??=
            StreamController<
              DocumentSnapshot<Map<String, dynamic>>
            >.broadcast())
        .stream;
  }
}

class LiveFavourites extends FavouriteService {
  LiveFavourites(EquipmentStore store)
    : super(firestore: store, auth: FavouriteAuth());
  final ids = StreamController<List<String>>();
  @override
  Stream<List<String>> getFavouriteEquipmentIds() => ids.stream;
}

class ScreenFavourites extends Fake implements FavouriteService {
  final rows = StreamController<List<FavouriteEquipment>>.broadcast();
  @override
  Stream<List<FavouriteEquipment>> watchFavouriteEquipment() => rows.stream;
  @override
  Future<void> removeFavourite(String id) async => rows.add([
    const FavouriteEquipment(
      'valid',
      equipment: {
        'name': 'Valid equipment',
        'pricePerDay': 100,
        'isAvailable': true,
      },
    ),
  ]);
}

void main() {
  test('newest first with ID ties, legacy timestamps last and no duplicate references', () {
    final recent = DateTime(2026, 10, 12);
    final older = DateTime(2026, 10, 1);
    final records = [
      FavouriteReference('old', older),
      FavouriteReference('z', recent),
      FavouriteReference('missing-time', null),
      FavouriteReference('a', recent),
      FavouriteReference('a', recent),
    ];
    expect(orderedFavouriteIds(records), ['a', 'z', 'old', 'missing-time']);
    expect(orderedFavouriteIds(records.reversed.toList()), [
      'a',
      'z',
      'old',
      'missing-time',
    ]);
  });
  test('new favourite pending server timestamp sorts first without changing schema', () {
    expect(
      orderedFavouriteIds([
        FavouriteReference('saved', DateTime(2026, 10, 12)),
        const FavouriteReference('new', null, pending: true),
        const FavouriteReference('legacy', null),
      ]),
      ['new', 'saved', 'legacy'],
    );
  });
  test('existing unavailable listings stay valid; missing/error rows follow in original order', () {
    final missing = const FavouriteEquipment('missing');
    final valid = const FavouriteEquipment(
      'valid',
      equipment: {'isAvailable': false},
    );
    final failed = FavouriteEquipment('error', error: StateError('offline'));
    expect(
      groupFavouriteEquipment([missing, valid, failed]).map((row) => row.id),
      ['valid', 'missing', 'error'],
    );
  });
  test('async snapshots retain order; deletions regroup; updates never duplicate listeners', () async {
    final store = EquipmentStore();
    final service = LiveFavourites(store);
    final emitted = <List<FavouriteEquipment>>[];
    final subscription = service.watchFavouriteEquipment().listen(emitted.add);
    Future<void> tick() => Future<void>.delayed(Duration.zero);
    service.ids.add(['new', 'missing', 'old', 'new']);
    await tick();
    store.controllers['old']!.add(EquipmentSnapshot({'name': 'Old'}));
    await tick();
    expect(emitted, isEmpty);
    store.controllers['missing']!.add(EquipmentSnapshot(null));
    await tick();
    expect(emitted, isEmpty);
    store.controllers['new']!.add(EquipmentSnapshot({'name': 'New'}));
    await tick();
    expect(emitted.last.map((row) => row.id), ['new', 'old', 'missing']);
    service.ids.add(['new', 'missing', 'old']);
    await tick();
    expect(store.watches, {'new': 1, 'missing': 1, 'old': 1});
    store.controllers['new']!.add(EquipmentSnapshot(null));
    await tick();
    expect(emitted.last.map((row) => row.id), ['old', 'new', 'missing']);
    service.ids.add(['missing', 'old']);
    await tick();
    expect(emitted.last.map((row) => row.id), ['old', 'missing']);
    service.ids.add(['latest', 'missing', 'old']);
    await tick();
    store.controllers['latest']!.add(EquipmentSnapshot({'name': 'Latest'}));
    await tick();
    expect(emitted.last.map((row) => row.id), ['latest', 'old', 'missing']);
    await subscription.cancel();
    expect(
      store.controllers.values.every((controller) => !controller.hasListener),
      true,
    );
    await service.ids.close();
    for (final controller in store.controllers.values) {
      await controller.close();
    }
  });
  testWidgets('missing card follows valid card and remove heart still works', (
    tester,
  ) async {
    final service = ScreenFavourites();
    await tester.pumpWidget(
      MaterialApp(home: MyFavouritesScreen(favouriteService: service)),
    );
    service.rows.add([
      const FavouriteEquipment(
        'valid',
        equipment: {
          'name': 'Valid equipment',
          'pricePerDay': 100,
          'isAvailable': true,
        },
      ),
      const FavouriteEquipment('missing'),
    ]);
    await tester.pumpAndSettle();
    expect(
      tester.getTopLeft(find.text('Valid equipment')).dy,
      lessThan(
        tester.getTopLeft(find.text('Equipment listing no longer exists')).dy,
      ),
    );
    final missing = find.ancestor(
      of: find.text('Equipment listing no longer exists'),
      matching: find.byType(ListTile),
    );
    await tester.tap(
      find.descendant(of: missing, matching: find.byType(IconButton)),
    );
    await tester.pumpAndSettle();
    expect(find.text('Equipment listing no longer exists'), findsNothing);
    expect(find.text('Valid equipment'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await tester.runAsync(() => service.rows.close());
  });
}
