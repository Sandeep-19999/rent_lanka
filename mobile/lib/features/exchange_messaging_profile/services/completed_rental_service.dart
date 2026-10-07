import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/review_equipment_option.dart';

class CompletedRentalService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CompletedRentalService({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  String get currentPlayerId {
    final user = _auth.currentUser;

    if (user != null) {
      return user.uid;
    }

    // Temporary preview/testing fallback.
    // Firebase rental_requests currently use demo_player.
    return 'demo_player';
  }

  Stream<List<ReviewEquipmentOption>> watchCompletedRentals() {
    return _firestore
        .collection('rental_requests')
        .where('playerId', isEqualTo: currentPlayerId)
        .snapshots()
        .map((snapshot) {
          final completedRentals = snapshot.docs
              .where((document) {
                final data = document.data();

                final String status =
                    data['status']?.toString().toLowerCase() ?? '';

                return status == 'completed';
              })
              .map((document) {
                final data = document.data();

                return ReviewEquipmentOption(
                  equipmentId: data['equipmentId']?.toString() ?? '',
                  providerId: data['providerId']?.toString() ?? '',
                  bookingId: document.id,
                  equipmentName:
                      data['equipmentName']?.toString() ?? 'Equipment',
                  rentedDate: _buildRentalDate(data),
                );
              })
              .where(
                (item) =>
                    item.equipmentId.isNotEmpty && item.providerId.isNotEmpty,
              )
              .toList();

          return completedRentals;
        });
  }

  String _buildRentalDate(Map<String, dynamic> data) {
    final String endDate = data['endDate']?.toString().trim() ?? '';

    if (endDate.isNotEmpty) {
      return _formatDateString(endDate);
    }

    final String startDate = data['startDate']?.toString().trim() ?? '';

    if (startDate.isNotEmpty && startDate != 'startDate') {
      return _formatDateString(startDate);
    }

    return 'Completed rental';
  }

  String _formatDateString(String value) {
    try {
      final DateTime date = DateTime.parse(value);

      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];

      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (_) {
      return value;
    }
  }
}
