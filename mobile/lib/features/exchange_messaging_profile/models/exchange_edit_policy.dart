import 'exchange_equipment_rules.dart';

class ExchangeEditPolicy {
  static bool canEdit(Map<String, dynamic> request, String userId) =>
      userId.isNotEmpty &&
      request['senderId'] == userId &&
      request['status']?.toString().toLowerCase() == 'pending' &&
      request['respondedAt'] == null;

  static Map<String, dynamic> patch({
    required Map<String, dynamic> request,
    required String userId,
    required String offeredEquipmentId,
    required String offeredEquipmentName,
    required String message,
    String? offeredEquipmentDetails,
    String offeredEquipmentImageUrl = '',
    String? offeredEquipmentImagePublicId,
    Map<String, dynamic>? equipment,
  }) {
    if (!canEdit(request, userId)) {
      throw Exception('Only your pending exchange requests can be edited.');
    }
    final Map<String, dynamic> offer;
    if (offeredEquipmentDetails != null) {
      offer = ExchangeEquipmentRules.inlineOfferData(
        title: offeredEquipmentName,
        details: offeredEquipmentDetails,
        imageUrl: offeredEquipmentImageUrl,
        imagePublicId: offeredEquipmentImagePublicId,
      );
      offer['offeredEquipmentImagePublicId'] = offeredEquipmentImagePublicId;
    } else {
      if (equipment == null ||
          !ExchangeEquipmentRules.canOffer(
            userId: userId,
            equipmentId: offeredEquipmentId,
            requestedEquipmentId:
                request['requestedEquipmentId']?.toString() ?? '',
            data: equipment,
          )) {
        throw Exception(
          'Your offered equipment is no longer available. Please select another item.',
        );
      }
      offer = {
        'offeredEquipmentId': offeredEquipmentId,
        'offeredEquipmentName': equipment['name'].toString().trim(),
        'offeredEquipmentSource': 'equipment',
        'offeredEquipmentDetails': '',
        'offeredEquipmentImageUrl': equipment['imageUrl'] ?? '',
        'offeredEquipmentImagePublicId': null,
      };
    }
    return {...offer, 'message': message.trim()};
  }
}
