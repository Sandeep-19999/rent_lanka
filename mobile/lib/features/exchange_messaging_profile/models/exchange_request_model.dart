class ExchangeRequestModel {
  final String id;
  final String senderId;
  final String requestedProviderId;
  final String requestedEquipmentId;
  final String requestedEquipmentName;
  final String offeredEquipmentId;
  final String offeredEquipmentName;
  final String message;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ExchangeRequestModel({
    this.id = '',
    required this.senderId,
    required this.requestedProviderId,
    required this.requestedEquipmentId,
    required this.requestedEquipmentName,
    required this.offeredEquipmentId,
    required this.offeredEquipmentName,
    required this.message,
    this.status = 'pending',
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'requestedProviderId': requestedProviderId,
      'requestedEquipmentId': requestedEquipmentId,
      'requestedEquipmentName': requestedEquipmentName,
      'offeredEquipmentId': offeredEquipmentId,
      'offeredEquipmentName': offeredEquipmentName,
      'message': message,
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory ExchangeRequestModel.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    return ExchangeRequestModel(
      id: id,
      senderId: map['senderId']?.toString() ?? '',
      requestedProviderId:
          map['requestedProviderId']?.toString() ?? '',
      requestedEquipmentId:
          map['requestedEquipmentId']?.toString() ?? '',
      requestedEquipmentName:
          map['requestedEquipmentName']?.toString() ?? '',
      offeredEquipmentId:
          map['offeredEquipmentId']?.toString() ?? '',
      offeredEquipmentName:
          map['offeredEquipmentName']?.toString() ?? '',
      message: map['message']?.toString() ?? '',
      status: map['status']?.toString() ?? 'pending',
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as dynamic).toDate()
          : null,
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as dynamic).toDate()
          : null,
    );
  }
}