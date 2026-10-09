/// Shared by the offer selector and submission validation.
class ExchangeEquipmentRules {
  static Map<String, dynamic> inlineOfferData({
    required String title,
    required String details,
    String imageUrl = '',
    String? imagePublicId,
  }) {
    if (title.trim().isEmpty || details.trim().isEmpty) {
      throw ArgumentError('Please enter your equipment title and details.');
    }
    if (title.trim().length > 120 || details.trim().length > 2000) {
      throw ArgumentError('Equipment title or details are too long.');
    }
    return {
      'offeredEquipmentId': '',
      'offeredEquipmentName': title.trim(),
      'offeredEquipmentSource': 'inline',
      'offeredEquipmentDetails': details.trim(),
      'offeredEquipmentImageUrl': imageUrl,
      'offeredEquipmentImagePublicId': ?imagePublicId,
    };
  }

  static bool available(Map<String, dynamic> data) {
    final status = data['status']?.toString().trim().toLowerCase() ?? '';
    return data['isAvailable'] == true &&
        (status.isEmpty || status == 'available' || status == 'active') &&
        data['isDeleted'] != true &&
        data['deletedAt'] == null &&
        (data['name']?.toString().trim().isNotEmpty ?? false);
  }

  static bool canOffer({
    required String userId,
    required String equipmentId,
    required String requestedEquipmentId,
    required Map<String, dynamic> data,
  }) {
    return userId.isNotEmpty &&
        equipmentId.isNotEmpty &&
        equipmentId != requestedEquipmentId &&
        data['providerId'] == userId &&
        available(data);
  }
}
