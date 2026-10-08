import 'package:flutter_test/flutter_test.dart';
import 'package:rent_lanka_mobile/features/booking_payment/models/equipment_model.dart';

void main() {
  Map<String, dynamic> listing() => {
    'id': 'equipment-17',
    'providerId': 'provider-8',
    'name': 'Cricket bat',
    'category': 'Cricket',
    'brand': 'Selected brand',
    'size': 'Adult',
    'condition': 'Good',
    'description': 'Selected description',
    'pricePerDay': 1200,
    'securityDeposit': 2500,
    'providerName': 'Listing owner',
    'location': 'Colombo',
    'status': 'Available',
    'isAvailable': true,
    'imageUrl': 'https://example.com/bat.png',
    'unavailableDates': ['2026-10-20'],
  };

  test('discovery listing preserves booking and provider data', () {
    final equipment = Equipment.fromDiscovery(listing());
    expect(equipment.id, 'equipment-17');
    expect(equipment.providerId, 'provider-8');
    expect(equipment.name, 'Cricket bat');
    expect(equipment.category, 'Cricket');
    expect(equipment.pricePerDay, 1200);
    expect(equipment.depositAmount, 2500);
    expect(equipment.providerName, 'Listing owner');
    expect(equipment.location, 'Colombo');
    expect(equipment.description, 'Selected description');
    expect(equipment.unavailableDates, ['2026-10-20']);
    expect(equipment.canBeBooked, isTrue);
  });

  test('missing required data never becomes a preview booking', () {
    for (final key in ['id', 'providerId', 'name', 'category',
      'pricePerDay', 'isAvailable', 'status']) {
      final data = listing()..remove(key);
      expect(() => Equipment.fromDiscovery(data), throwsFormatException,
        reason: key);
    }
    expect(() => Equipment.fromDiscovery(listing()..['pricePerDay'] = double.nan),
      throwsFormatException);
  });

  test('unavailable listings cannot enter booking', () {
    expect(() => Equipment.fromDiscovery(listing()..['isAvailable'] = false),
      throwsFormatException);
    expect(() => Equipment.fromDiscovery(listing()..['status'] = 'Unavailable'),
      throwsFormatException);
  });

  test('existing default deposit remains one day of actual rent', () {
    final equipment = Equipment.fromDiscovery(listing()..remove('securityDeposit'));
    expect(equipment.depositAmount, equipment.pricePerDay);
  });
}
