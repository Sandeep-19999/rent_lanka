import 'package:cloud_firestore/cloud_firestore.dart';

class EquipmentModel {
  final String id;
  final String name;
  final String category;
  final String brand;
  final String size;
  final String condition;
  final double pricePerDay;
  final String providerId;
  final String status;
  final bool isAvailable;
  final String imageUrl;
  final List<String> unavailableDates;
  final DateTime? createdAt;

  const EquipmentModel({
    required this.id,
    required this.name,
    required this.category,
    required this.brand,
    required this.size,
    required this.condition,
    required this.pricePerDay,
    required this.providerId,
    required this.status,
    required this.isAvailable,
    required this.imageUrl,
    required this.unavailableDates,
    required this.createdAt,
  });

  factory EquipmentModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? {};

    final priceValue = data['pricePerDay'];

    final unavailableValue = data['unavailableDates'];

    return EquipmentModel(
      id: document.id,
      name: data['name']?.toString() ?? '',
      category: data['category']?.toString() ?? '',
      brand: data['brand']?.toString() ?? '',
      size: data['size']?.toString() ?? '',
      condition: data['condition']?.toString() ?? '',
      pricePerDay:
          priceValue is num ? priceValue.toDouble() : 0,
      providerId: data['providerId']?.toString() ?? '',
      status: data['status']?.toString() ?? 'Available',
      isAvailable: data['isAvailable'] != false,
      imageUrl: data['imageUrl']?.toString() ?? '',
      unavailableDates: unavailableValue is List
          ? unavailableValue
              .map((date) => date.toString())
              .toList()
          : <String>[],
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'category': category,
      'brand': brand,
      'size': size,
      'condition': condition,
      'pricePerDay': pricePerDay,
      'providerId': providerId,
      'status': status,
      'isAvailable': isAvailable,
      'imageUrl': imageUrl,
      'unavailableDates': unavailableDates,
    };
  }

  EquipmentModel copyWith({
    String? id,
    String? name,
    String? category,
    String? brand,
    String? size,
    String? condition,
    double? pricePerDay,
    String? providerId,
    String? status,
    bool? isAvailable,
    String? imageUrl,
    List<String>? unavailableDates,
    DateTime? createdAt,
  }) {
    return EquipmentModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      brand: brand ?? this.brand,
      size: size ?? this.size,
      condition: condition ?? this.condition,
      pricePerDay: pricePerDay ?? this.pricePerDay,
      providerId: providerId ?? this.providerId,
      status: status ?? this.status,
      isAvailable: isAvailable ?? this.isAvailable,
      imageUrl: imageUrl ?? this.imageUrl,
      unavailableDates:
          unavailableDates ?? this.unavailableDates,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}