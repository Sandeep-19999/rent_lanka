
import 'package:cloud_firestore/cloud_firestore.dart';

class EquipmentModel {
  final String id;
  final String name;
  final String category;
  final String brand;
  final String condition;
  final String imageUrl;
  final bool isAvailable;
  final double pricePerDay;
  final String providerId;
  final String size;
  final String status;
  final List<String> unavailableDates;
  final DateTime? updatedAt;

  const EquipmentModel({
    required this.id,
    required this.name,
    required this.category,
    required this.brand,
    required this.condition,
    required this.imageUrl,
    required this.isAvailable,
    required this.pricePerDay,
    required this.providerId,
    required this.size,
    required this.status,
    required this.unavailableDates,
    this.updatedAt,
  });

  factory EquipmentModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? {};

    final rawPrice = data['pricePerDay'];

    return EquipmentModel(
      id: document.id,
      name: data['name']?.toString() ?? '',
      category: data['category']?.toString() ?? '',
      brand: data['brand']?.toString() ?? '',
      condition: data['condition']?.toString() ?? '',
      imageUrl: data['imageUrl']?.toString() ?? '',
      isAvailable: data['isAvailable'] == true,
      pricePerDay: rawPrice is num
          ? rawPrice.toDouble()
          : double.tryParse(rawPrice?.toString() ?? '') ?? 0,
      providerId: data['providerId']?.toString() ?? '',
      size: data['size']?.toString() ?? '',
      status: data['status']?.toString() ?? '',
      unavailableDates: data['unavailableDates'] is List
          ? (data['unavailableDates'] as List)
              .map((date) => date.toString())
              .toList()
          : <String>[],
      updatedAt: data['updatedAt'] is Timestamp
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }
}
