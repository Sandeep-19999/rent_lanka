import 'package:cloud_firestore/cloud_firestore.dart';

class RentalRequestModel {
  final String id;
  final String providerId;
  final String equipmentId;

  final String playerId;
  final String playerName;
  final String equipmentName;

  final String startDate;
  final String endDate;

  final String pickupLocation;

  final double totalAmount;

  final String status;

  final bool verifiedUser;

  final List<String> reservedDates;

  final bool handoverConfirmed;
  final bool returnedWithoutDamage;
  final bool depositRefunded;
  final bool returnConfirmed;

  const RentalRequestModel({
    required this.id,
    required this.providerId,
    required this.equipmentId,
    this.playerId = '',
    required this.playerName,
    required this.equipmentName,
    required this.startDate,
    required this.endDate,
    required this.pickupLocation,
    required this.totalAmount,
    required this.status,
    required this.verifiedUser,
    required this.reservedDates,
    required this.handoverConfirmed,
    required this.returnedWithoutDamage,
    required this.depositRefunded,
    required this.returnConfirmed,
  });

  factory RentalRequestModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    return RentalRequestModel.fromData(document.id, document.data() ?? {});
  }

  factory RentalRequestModel.fromData(String id, Map<String, dynamic> data) {

    final dynamic totalAmountValue = data['totalAmount'];
    final dynamic verifiedValue = data['verifiedUser'];
    final dynamic reservedDatesValue = data['reservedDates'];

    return RentalRequestModel(
      id: id,

      providerId:
          data['providerId']?.toString() ?? '',

      equipmentId:
          data['equipmentId']?.toString() ?? '',

      playerId: data['playerId']?.toString().trim() ?? '',

      playerName:
          data['playerName']?.toString() ?? 'Player',

      equipmentName:
          data['equipmentName']?.toString() ?? 'Equipment',

      startDate:
          data['startDate']?.toString() ?? '',

      endDate:
          data['endDate']?.toString() ?? '',

      pickupLocation:
          data['pickupLocation']?.toString() ??
              'Provider location',

      totalAmount: totalAmountValue is num
          ? totalAmountValue.toDouble()
          : 0,

      status:
          data['status']?.toString().toLowerCase() ??
              'pending',

      verifiedUser:
          verifiedValue == true ||
          verifiedValue
                  ?.toString()
                  .toLowerCase() ==
              'true',

      reservedDates: reservedDatesValue is List
          ? reservedDatesValue
              .map((date) => date.toString())
              .toList()
          : <String>[],

      handoverConfirmed:
          data['handoverConfirmed'] == true,

      returnedWithoutDamage:
          data['returnedWithoutDamage'] == true,

      depositRefunded:
          data['depositRefunded'] == true,

      returnConfirmed:
          data['returnConfirmed'] == true,
    );
  }
}