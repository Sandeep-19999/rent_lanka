
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:rent_lanka_mobile/features/user_discovery/models/equipment_model.dart';

class EquipmentService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  Stream<List<EquipmentModel>> getAvailableEquipment() {
    return _firestore
        .collection('equipment')
        .where('isAvailable', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => EquipmentModel.fromFirestore(doc))
          .where(
            (equipment) =>
                equipment.status.toLowerCase() == 'available',
          )
          .toList();
    });
  }

  Stream<List<EquipmentModel>> getEquipmentByCategory(
    String category,
  ) {
    return getAvailableEquipment().map((equipmentList) {
      return equipmentList
          .where(
            (equipment) =>
                equipment.category.toLowerCase() ==
                category.toLowerCase(),
          )
          .toList();
    });
  }

  Future<EquipmentModel?> getEquipmentById(String id) async {
    final document =
        await _firestore.collection('equipment').doc(id).get();

    if (!document.exists) {
      return null;
    }

    return EquipmentModel.fromFirestore(document);
  }
}

