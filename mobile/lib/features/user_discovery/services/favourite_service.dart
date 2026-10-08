
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavouriteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  DocumentReference<Map<String, dynamic>> _favouriteRef(
    String equipmentId,
  ) {
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
          (snapshot) => snapshot.docs
              .map((document) => document.id)
              .toList(),
        );
  }
}
