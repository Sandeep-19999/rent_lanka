import 'dart:async';

import '../models/favourite_model.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavouriteService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FavouriteService({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  DocumentReference<Map<String, dynamic>> _favouriteRef(String equipmentId) {
    final userId = currentUserId;

    if (userId == null) {
      throw StateError('Please log in to use favourites.');
    }

    if (equipmentId.trim().isEmpty) {
      throw StateError('Equipment ID is missing.');
    }

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('favourites')
        .doc(equipmentId);
  }

  Stream<bool> isFavourite(String equipmentId) {
    if (currentUserId == null || equipmentId.trim().isEmpty) {
      return Stream.value(false);
    }

    return _favouriteRef(equipmentId)
        .snapshots()
        .map((snapshot) => snapshot.exists);
  }

  Future<void> addFavourite(String equipmentId) async {
    await _favouriteRef(equipmentId).set({
      'equipmentId': equipmentId,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeFavourite(String equipmentId) async {
    await _favouriteRef(equipmentId).delete();
  }

  Future<void> toggleFavourite(
    String equipmentId,
    bool currentlyFavourite,
  ) async {
    if (currentlyFavourite) {
      await removeFavourite(equipmentId);
    } else {
      await addFavourite(equipmentId);
    }
  }

  Stream<List<String>> getFavouriteEquipmentIds() {
    final userId = currentUserId;

    if (userId == null) {
      return Stream.value(<String>[]);
    }

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('favourites')
        .snapshots()
        .map(
          (snapshot) => orderedFavouriteIds(
            snapshot.docs.map((document) {
              final created = document.data()['createdAt'];
              return FavouriteReference(
                document.id,
                created is Timestamp ? created.toDate() : null,
                pending: document.metadata.hasPendingWrites,
              );
            }).toList(),
          ),
        );
  }

  /// Resolve one live equipment listener per unique favourite, preserving the
  /// reference order regardless of which initial snapshot arrives first.
  Stream<List<FavouriteEquipment>> watchFavouriteEquipment() {
    late StreamController<List<FavouriteEquipment>> controller;
    StreamSubscription<List<String>>? favourites;
    final listeners =
        <String, StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>>{};
    final resolved = <String, FavouriteEquipment>{};
    final generations = <String, Object>{};
    var ids = <String>[];
    var active = true;
    void emit() {
      if (!active || ids.any((id) => !resolved.containsKey(id))) return;
      controller.add(
        groupFavouriteEquipment(ids.map((id) => resolved[id]!).toList()),
      );
    }

    controller = StreamController<List<FavouriteEquipment>>(
      onListen: () {
        favourites = getFavouriteEquipmentIds().listen((next) {
          if (!active) return;
          ids = next.toSet().toList();
          for (final id in listeners.keys.toList()) {
            if (!ids.contains(id)) {
              listeners.remove(id)?.cancel();
              resolved.remove(id);
              generations.remove(id);
            }
          }
          for (final id in ids) {
            if (listeners.containsKey(id)) continue;
            final generation = Object();
            generations[id] = generation;
            listeners[id] = _firestore
                .collection('equipment')
                .doc(id)
                .snapshots()
                .listen(
                  (snapshot) {
                    if (!active || generations[id] != generation) return;
                    resolved[id] = FavouriteEquipment(
                      id,
                      equipment: snapshot.exists ? snapshot.data() ?? {} : null,
                    );
                    emit();
                  },
                  onError: (Object error) {
                    if (!active || generations[id] != generation) return;
                    resolved[id] = FavouriteEquipment(id, error: error);
                    emit();
                  },
                );
          }
          emit();
        }, onError: controller.addError);
      },
      onCancel: () async {
        active = false;
        await favourites?.cancel();
        await Future.wait(
          listeners.values.map((listener) => listener.cancel()),
        );
      },
    );
    return controller.stream;
  }
}
