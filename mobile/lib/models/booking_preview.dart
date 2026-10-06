import 'package:flutter/material.dart';

class BookingPreview extends ChangeNotifier {
  final String equipmentId;
  final String providerId;
  final String equipmentName;
  final double pricePerDay;
  final double? securityDeposit;

  DateTimeRange rentalDates;
  String receiveMethod;
  String deliveryAddress;
  String paymentMethod;

  // This quote applies to the original delivery address.
  final double? quotedDeliveryFee;
  final String quotedDeliveryAddress;

  String? cancellationReason;

  BookingPreview({
    required this.equipmentId,
    required this.providerId,
    required this.equipmentName,
    required this.pricePerDay,
    required this.securityDeposit,
    required this.rentalDates,
    required this.receiveMethod,
    required this.deliveryAddress,
    required this.paymentMethod,
    double? deliveryFee,
  })  : quotedDeliveryFee =
            receiveMethod == 'delivery' ? deliveryFee : null,
        quotedDeliveryAddress =
            receiveMethod == 'delivery' ? deliveryAddress.trim() : '';

  bool get cancelled => cancellationReason != null;

  int get days {
    final start = rentalDates.start;
    final end = rentalDates.end;

    return DateTime.utc(end.year, end.month, end.day)
            .difference(DateTime.utc(start.year, start.month, start.day))
            .inDays +
        1;
  }

  double get rentalFee => pricePerDay * days;

  double? get deliveryFee {
    if (receiveMethod == 'pickup') return 0;

    if (deliveryAddress.trim() == quotedDeliveryAddress) {
      return quotedDeliveryFee;
    }

    return null;
  }

  bool get finalAmountKnown =>
      securityDeposit != null && deliveryFee != null;

  double get knownSubtotal =>
      rentalFee + (securityDeposit ?? 0) + (deliveryFee ?? 0);

  bool get valid {
    bool validCharge(double? amount) =>
        amount == null || (amount.isFinite && amount >= 0);

    return equipmentId.trim().isNotEmpty &&
        providerId.trim().isNotEmpty &&
        equipmentName.trim().isNotEmpty &&
        pricePerDay.isFinite &&
        pricePerDay > 0 &&
        days > 0 &&
        validCharge(securityDeposit) &&
        validCharge(deliveryFee) &&
        knownSubtotal.isFinite &&
        knownSubtotal > 0 &&
        (receiveMethod == 'pickup' || receiveMethod == 'delivery') &&
        (receiveMethod != 'delivery' ||
            deliveryAddress.trim().isNotEmpty) &&
        (paymentMethod == 'card' || paymentMethod == 'online_banking');
  }

  void update({
    required DateTimeRange dates,
    required String method,
    required String address,
    required String payment,
  }) {
    if (cancelled) return;

    rentalDates = dates;
    receiveMethod = method;
    deliveryAddress = method == 'delivery' ? address.trim() : '';
    paymentMethod = payment;

    notifyListeners();
  }

  void cancel(String reason) {
    if (cancelled || reason.trim().isEmpty) return;

    cancellationReason = reason.trim();
    notifyListeners();
  }
}