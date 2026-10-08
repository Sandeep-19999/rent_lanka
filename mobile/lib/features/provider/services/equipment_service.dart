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
  }) async {
    final document =
        await _equipmentCollection.add({
      'name': name.trim(),
      'category': category,
      'brand': brand.trim(),
      'size': size.trim(),
      'condition': condition,
      'pricePerDay': pricePerDay,
      'providerId': AuthService.providerId,
      'status': 'Available',
      'isAvailable': true,
      'imageUrl': imageUrl,
      'unavailableDates': <String>[],
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
    await _equipmentCollection.doc(equipmentId).update({
      'unavailableDates': unavailableDates,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteEquipment(
    String equipmentId,
  ) async {
    await _equipmentCollection
        .doc(equipmentId)
        .delete();
  }
}