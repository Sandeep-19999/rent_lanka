import 'package:flutter_test/flutter_test.dart';
import 'package:rent_lanka_mobile/features/exchange_messaging_profile/models/exchange_equipment_rules.dart';
import 'package:rent_lanka_mobile/features/exchange_messaging_profile/models/exchange_request_model.dart';

void main() {
  test('player can enter an offer without an equipment listing', () {
    final offer = ExchangeEquipmentRules.inlineOfferData(title: ' Cricket Bat ',
        details: ' SS bat, size M, good condition ', imageUrl: 'https://res.cloudinary.com/gg8wheuw/image/upload/bat.jpg', imagePublicId: 'bat');
    expect(offer['offeredEquipmentName'], 'Cricket Bat');
    expect(offer['offeredEquipmentDetails'], 'SS bat, size M, good condition');
    expect(offer['offeredEquipmentId'], '');
    expect(offer['offeredEquipmentSource'], 'inline');
    expect(offer['offeredEquipmentImagePublicId'], 'bat');
  });
  test('inline offer requires title and details, photo remains optional', () {
    expect(() => ExchangeEquipmentRules.inlineOfferData(title: '', details: 'Good'), throwsArgumentError);
    expect(() => ExchangeEquipmentRules.inlineOfferData(title: 'Bat', details: ' '), throwsArgumentError);
    final offer = ExchangeEquipmentRules.inlineOfferData(title: 'Bat', details: 'Good');
    expect(offer['offeredEquipmentImageUrl'], '');
  });

  const owned = <String, dynamic>{
    'providerId': 'player',
    'name': 'Cricket Bat',
    'isAvailable': true,
    'status': 'Available',
  };
  bool eligible(
    Map<String, dynamic> data, {
    String id = 'bat',
    String uid = 'player',
  }) => ExchangeEquipmentRules.canOffer(
    userId: uid,
    equipmentId: id,
    requestedEquipmentId: 'wanted',
    data: data,
  );

  test('only authenticated current owner equipment is offered, without role restriction', () {
    expect(eligible(owned), isTrue);
    expect(eligible({...owned, 'role': 'player'}), isTrue);
    expect(eligible({...owned, 'providerId': 'other'}), isFalse);
    expect(eligible(owned, uid: ''), isFalse);
  });
  test('unavailable, inactive, deleted and requested equipment excluded', () {
    expect(eligible({...owned, 'isAvailable': false}), isFalse);
    expect(eligible({...owned, 'isAvailable': null}), isFalse);
    for (final status in ['Unavailable', 'inactive', 'deleted', 'rented']) {
      expect(eligible({...owned, 'status': status}), isFalse);
    }
    expect(eligible({...owned, 'isDeleted': true}), isFalse);
    expect(eligible({...owned, 'deletedAt': 'timestamp'}), isFalse);
    expect(eligible(owned, id: 'wanted'), isFalse);
  });
  test(
    'active and legacy blank statuses accepted only with explicit availability',
    () {
      expect(eligible({...owned, 'status': 'active'}), isTrue);
      expect(eligible({...owned, 'status': ''}), isTrue);
    },
  );
  test('empty list and no selection yield no valid offer', () {
    final options = <Map<String, dynamic>>[].where(eligible).toList();
    expect(options, isEmpty);
    expect(eligible(owned, id: ''), isFalse);
  });
  test(
    'existing exchange schema retains selected offered identity and names',
    () {
      final request = ExchangeRequestModel(
        senderId: 'player',
        requestedProviderId: 'owner',
        requestedEquipmentId: 'wanted',
        requestedEquipmentName: 'Football',
        offeredEquipmentId: 'bat',
        offeredEquipmentName: owned['name'] as String,
        message: 'Offer',
      );
      final data = request.toMap();
      final saved = ExchangeRequestModel.fromMap('exchange', data);
      expect(saved.offeredEquipmentId, 'bat');
      expect(saved.offeredEquipmentName, 'Cricket Bat');
      expect(saved.senderId, 'player');
      expect(saved.requestedEquipmentId, 'wanted');
      expect(saved.status, 'pending');
    },
  );
}
