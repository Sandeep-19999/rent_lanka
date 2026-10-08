import 'package:cloud_firestore/cloud_firestore.dart';

/// How the player collects the equipment (Pickup / Delivery screen).
enum PickupMethod {
  ownerPickup('owner_pickup', 'Pickup from owner'),
  shopPickup('shop_pickup', 'Pickup from shop'),
  delivery('delivery', 'Home delivery');

  final String value;
  final String label;

  const PickupMethod(this.value, this.label);

  static PickupMethod fromValue(String? value) => PickupMethod.values
      .firstWhere((m) => m.value == value, orElse: () => ownerPickup);
}

enum PaymentMethod {
  card('card', 'Credit / Debit Card'),
  onlineBanking('online_banking', 'Online Banking'),
  cashOnPickup('cash', 'Cash on Pickup');

  final String value;
  final String label;

  const PaymentMethod(this.value, this.label);

  static PaymentMethod fromValue(String? value) => PaymentMethod.values
      .firstWhere((m) => m.value == value, orElse: () => card);
}

/// Booking status values. `pending`, `accepted`, `rejected`, `active` and
/// `completed` are shared with the provider screens; `cancelled` is set when
/// the player cancels.
class BookingStatus {
  static const pending = 'pending';
  static const accepted = 'accepted';
  static const rejected = 'rejected';
  static const active = 'active';
  static const completed = 'completed';
  static const cancelled = 'cancelled';

  /// Statuses that still hold the equipment for the booked dates.
  static const blocking = [pending, accepted, active];

  static const upcoming = [pending, accepted];
  static const past = [completed, rejected, cancelled];
}

class PaymentStatus {
  static const paid = 'paid';
  static const payOnPickup = 'pay_on_pickup';
  static const refunded = 'refunded';
}

/// Cost breakdown shown on Booking Summary and saved with the booking.
class PriceBreakdown {
  static const double deliveryFeeAmount = 500;
  static const double serviceFeeRate = 0.05;

  final double pricePerDay;
  final int rentalDays;
  final double rentalCost;
  final double deliveryFee;
  final double serviceFee;
  final double deposit;

  const PriceBreakdown({
    required this.pricePerDay,
    required this.rentalDays,
    required this.rentalCost,
    required this.deliveryFee,
    required this.serviceFee,
    required this.deposit,
  });

  factory PriceBreakdown.calculate({
    required double pricePerDay,
    required int rentalDays,
    required PickupMethod pickupMethod,
    required double deposit,
  }) {
    final rentalCost = pricePerDay * rentalDays;
    return PriceBreakdown(
      pricePerDay: pricePerDay,
      rentalDays: rentalDays,
      rentalCost: rentalCost,
      deliveryFee:
          pickupMethod == PickupMethod.delivery ? deliveryFeeAmount : 0,
      serviceFee: _roundCents(rentalCost * serviceFeeRate),
      deposit: deposit,
    );
  }

  double get totalPayable => rentalCost + deliveryFee + serviceFee + deposit;

  static double _roundCents(double value) => (value * 100).round() / 100;
}

/// A rental booking, stored in the `rental_requests` collection so it shows
/// up in the provider's Rental Requests and Dashboard screens.
class Booking {
  final String id;
  final String bookingReference;
  final String equipmentId;
  final String equipmentName;
  final String equipmentCategory;
  final String providerId;
  final String providerName;
  final String playerId;
  final String playerName;
  final String startDate;
  final String endDate;
  final int rentalDays;
  final PickupMethod pickupMethod;
  final String pickupLocation;
  final String deliveryAddress;
  final String note;
  final double pricePerDay;
  final double rentalCost;
  final double deliveryFee;
  final double serviceFee;
  final double depositAmount;
  final double totalPayable;
  final PaymentMethod paymentMethod;
  final String paymentStatus;
  final String transactionId;
  final String cardLast4;
  final String status;
  final DateTime? createdAt;

  const Booking({
    required this.id,
    required this.bookingReference,
    required this.equipmentId,
    required this.equipmentName,
    required this.equipmentCategory,
    required this.providerId,
    required this.providerName,
    required this.playerId,
    required this.playerName,
    required this.startDate,
    required this.endDate,
    required this.rentalDays,
    required this.pickupMethod,
    required this.pickupLocation,
    required this.deliveryAddress,
    required this.note,
    required this.pricePerDay,
    required this.rentalCost,
    required this.deliveryFee,
    required this.serviceFee,
    required this.depositAmount,
    required this.totalPayable,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.transactionId,
    required this.cardLast4,
    required this.status,
    required this.createdAt,
  });

  factory Booking.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};

    double number(String field) {
      final value = data[field];
      return value is num ? value.toDouble() : 0;
    }

    final created = data['createdAt'];
    final days = data['rentalDays'];

    return Booking(
      id: doc.id,
      bookingReference:
          data['bookingReference']?.toString() ?? referenceFor(doc.id),
      equipmentId: data['equipmentId']?.toString() ?? '',
      equipmentName: data['equipmentName']?.toString() ?? 'Equipment',
      equipmentCategory: data['equipmentCategory']?.toString() ?? '',
      providerId: data['providerId']?.toString() ?? '',
      providerName: data['providerName']?.toString() ?? 'Equipment Provider',
      playerId: data['playerId']?.toString() ?? '',
      playerName: data['playerName']?.toString() ?? 'Player',
      startDate: data['startDate']?.toString() ?? '',
      endDate: data['endDate']?.toString() ?? '',
      rentalDays: days is num ? days.toInt() : 1,
      pickupMethod: PickupMethod.fromValue(data['pickupMethod']?.toString()),
      pickupLocation: data['pickupLocation']?.toString() ?? '',
      deliveryAddress: data['deliveryAddress']?.toString() ?? '',
      note: data['note']?.toString() ?? '',
      pricePerDay: number('pricePerDay'),
      // `totalAmount` is the rental value the provider dashboard reads.
      rentalCost: number('totalAmount'),
      deliveryFee: number('deliveryFee'),
      serviceFee: number('serviceFee'),
      depositAmount: number('depositAmount'),
      totalPayable: number('totalPayable'),
      paymentMethod: PaymentMethod.fromValue(data['paymentMethod']?.toString()),
      paymentStatus: data['paymentStatus']?.toString() ?? PaymentStatus.paid,
      transactionId: data['transactionId']?.toString() ?? '',
      cardLast4: data['cardLast4']?.toString() ?? '',
      status: data['status']?.toString().toLowerCase() ?? BookingStatus.pending,
      createdAt: created is Timestamp ? created.toDate() : null,
    );
  }

  /// Short, human-friendly reference shown to the player, e.g. `RL-7F3K9A`.
  static String referenceFor(String docId) {
    final cleaned = docId.replaceAll(RegExp(r'[^A-Za-z0-9]'), '');
    final short = cleaned.length > 6 ? cleaned.substring(0, 6) : cleaned;
    return 'RL-${short.toUpperCase()}';
  }

  bool get canCancel => BookingStatus.upcoming.contains(status);

  bool get isUpcoming => BookingStatus.upcoming.contains(status);
  bool get isActive => status == BookingStatus.active;
  bool get isPast => BookingStatus.past.contains(status);
}
