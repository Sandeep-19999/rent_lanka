import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../booking_payment/services/booking_lifecycle_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../services/auth_service.dart';
import '../models/equipment_model.dart';

class EquipmentService {
  final FirebaseFirestore _firestore;

  EquipmentService({
    FirebaseFirestore? firestore,
  }) : _firestore =
            firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>>
      get _equipmentCollection =>
          _firestore.collection('equipment');

  Stream<List<EquipmentModel>> watchMyEquipment() {
    return _equipmentCollection
        .where(
          'providerId',
          isEqualTo: AuthService.providerId,
        )
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(EquipmentModel.fromFirestore)
              .toList(),
        );
  }

  Stream<EquipmentModel?> watchEquipment(
    String equipmentId,
  ) {
    return _equipmentCollection
        .doc(equipmentId)
        .snapshots()
        .map(
          (document) => document.exists
              ? EquipmentModel.fromFirestore(document)
              : null,
        );
  }

  Future<EquipmentModel?> getEquipment(
    String equipmentId,
  ) async {
    final document =
        await _equipmentCollection.doc(equipmentId).get();

    if (!document.exists) {
      return null;
    }

    return EquipmentModel.fromFirestore(document);
  }

  Future<String> addEquipment({
    required String name,
    required String category,
    required String brand,
    required String size,
    required String condition,
    required double pricePerDay,
    String imageUrl = '',
    Uint8List? imageBytes,
    String imageExtension = 'jpg',
    String description = '',
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Please log in to add equipment.');
    final profile = (await _firestore.collection('users').doc(user.uid).get()).data() ?? {};
    if (profile['role']?.toString().trim().toLowerCase() != 'provider') {
      throw Exception('Only provider accounts can publish equipment.');
    }
    final location = profile['location']?.toString().trim() ?? '';
    if (location.isEmpty) throw Exception('Please add your location in Edit Profile before publishing.');
    final savedName = profile['name']?.toString().trim() ?? '';
    final providerName = savedName.isNotEmpty ? savedName :
        user.displayName?.trim() ?? user.email?.split('@').first ?? '';
    if (providerName.isEmpty) throw Exception('Please add your name in Edit Profile before publishing.');
    final document = _equipmentCollection.doc();
    if (imageBytes != null) {
      final extension = ['jpg', 'jpeg', 'png', 'webp'].contains(imageExtension)
          ? imageExtension : 'jpg';
      final upload = FirebaseStorage.instance.ref()
          .child('equipment_photos/${user.uid}/${document.id}/photo.$extension');
      final result = await upload.putData(imageBytes, SettableMetadata(
        contentType: extension == 'png' ? 'image/png' :
            extension == 'webp' ? 'image/webp' : 'image/jpeg',
      ));
      imageUrl = await result.ref.getDownloadURL();
    }
    await document.set({
      'name': name.trim(),
      'category': category,
      'brand': brand.trim(),
      'size': size.trim(),
      'condition': condition,
      'pricePerDay': pricePerDay,
      'providerId': user.uid,
      'providerName': providerName,
      'location': location,
      'description': description.trim(),
      'status': 'Available',
      'isAvailable': true,
      'imageUrl': imageUrl,
      'unavailableDates': <String>[],
      'manualUnavailableDates': <String>[],
      'rentalReservations': <String, dynamic>{},
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return document.id;
  }

  Future<void> updateEquipment({
    required String equipmentId,
    required String name,
    required String category,
    required String brand,
    required String size,
    required String condition,
    required double pricePerDay,
  }) async {
    await _equipmentCollection.doc(equipmentId).update({
      'name': name.trim(),
      'category': category,
      'brand': brand.trim(),
      'size': size.trim(),
      'condition': condition,
      'pricePerDay': pricePerDay,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateAvailability({
    required String equipmentId,
    required bool isAvailable,
  }) async {
    await _equipmentCollection.doc(equipmentId).update({
      'isAvailable': isAvailable,
      'status':
          isAvailable ? 'Available' : 'Unavailable',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> saveUnavailableDates({
    required String equipmentId,
    required List<String> unavailableDates,
  }) async {
    final ref = _equipmentCollection.doc(equipmentId);
    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(ref);
      final data = doc.data() ?? {};
      transaction.update(ref, {
        ...ReservationDates.manualSelection(data, unavailableDates),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> deleteEquipment(
    String equipmentId,
  ) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('Please log in to delete a listing.');
    final slots = await _firestore.collection('booking_slots')
        .where('equipmentId', isEqualTo: equipmentId).get();
    if (slots.docs.any((slot) => ['pending', 'accepted', 'active'].contains(slot.data()['status']))) {
      throw Exception('A listing with pending or active rentals cannot be deleted.');
    }
    final reference = _equipmentCollection.doc(equipmentId);
    await _firestore.runTransaction((transaction) async {
      final data = (await transaction.get(reference)).data();
      if (data == null) return;
      if (data['providerId'] != uid) throw Exception('This listing does not belong to you.');
      if (ReservationDates.reservations(data).isNotEmpty) {
        throw Exception('A listing with reserved rentals cannot be deleted.');
      }
      transaction.delete(reference);
    });
  }
}