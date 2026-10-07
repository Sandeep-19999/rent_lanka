import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Equipment listing as stored in the `equipment` collection.
///
/// Field names match what the provider screens (Add Equipment,
/// Edit Listing, Availability) already write.
class Equipment {
  final String id;
  final String name;
  final String category;
  final String brand;
  final String size;
  final String condition;
  final String description;
  final double pricePerDay;
  final double? securityDeposit;
  final String providerId;
  final String providerName;
  final String location;
  final String status;
  final bool isAvailable;
  final String imageUrl;

  /// Dates blocked by the provider, as `yyyy-MM-dd` keys.
  final List<String> unavailableDates;

  const Equipment({
    required this.id,
    required this.name,
    required this.category,
    required this.brand,
    required this.size,
    required this.condition,
    required this.description,
    required this.pricePerDay,
    required this.securityDeposit,
    required this.providerId,
    required this.providerName,
    required this.location,
    required this.status,
    required this.isAvailable,
    required this.imageUrl,
    required this.unavailableDates,
  });

  factory Equipment.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};

    final price = data['pricePerDay'];
    final deposit = data['securityDeposit'];
    final dates = data['unavailableDates'];

    return Equipment(
      id: doc.id,
      name: data['name']?.toString() ?? 'Equipment',
      category: data['category']?.toString() ?? '',
      brand: data['brand']?.toString() ?? '',
      size: data['size']?.toString() ?? '',
      condition: data['condition']?.toString() ?? '',
      description: data['description']?.toString() ?? '',
      pricePerDay: price is num ? price.toDouble() : 0,
      securityDeposit: deposit is num ? deposit.toDouble() : null,
      providerId: data['providerId']?.toString() ?? '',
      providerName: data['providerName']?.toString() ?? 'Equipment Provider',
      location: data['location']?.toString() ?? '',
      status: data['status']?.toString() ?? 'Available',
      isAvailable: data['isAvailable'] != false,
      imageUrl: data['imageUrl']?.toString() ?? '',
      unavailableDates:
          dates is List ? dates.map((d) => d.toString()).toList() : const [],
    );
  }

  /// Refundable deposit held during the rental. Providers can set
  /// `securityDeposit` on a listing; otherwise it defaults to one day's rent.
  double get depositAmount => securityDeposit ?? pricePerDay;

  bool get canBeBooked =>
      isAvailable && status.toLowerCase() == 'available' && pricePerDay > 0;

  IconData get categoryIcon => iconForCategory(category);

  static IconData iconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'cricket':
        return Icons.sports_cricket;
      case 'football':
        return Icons.sports_soccer;
      case 'tennis':
        return Icons.sports_tennis;
      case 'cycling':
        return Icons.pedal_bike;
      case 'volleyball':
        return Icons.sports_volleyball;
      case 'hockey':
        return Icons.sports_hockey;
      case 'swimming':
        return Icons.pool;
      default:
        return Icons.sports;
    }
  }
}
