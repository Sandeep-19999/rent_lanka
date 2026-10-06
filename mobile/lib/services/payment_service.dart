import 'dart:math';

import '../models/booking.dart';

class CardDetails {
  final String holderName;
  final String number;
  final String expiry; // MM/YY
  final String cvv;

  const CardDetails({
    required this.holderName,
    required this.number,
    required this.expiry,
    required this.cvv,
  });

  String get digits => number.replaceAll(RegExp(r'\D'), '');
  String get last4 => digits.length >= 4 ? digits.substring(digits.length - 4) : digits;
}

class PaymentResult {
  final bool success;
  final String message;
  final String transactionId;
  final String cardLast4;
  final String paymentStatus;

  const PaymentResult({
    required this.success,
    required this.message,
    this.transactionId = '',
    this.cardLast4 = '',
    this.paymentStatus = '',
  });
}

/// Simulated payment gateway for the prototype.
///
/// No real money moves and card numbers / CVVs are never stored or sent
/// anywhere: only the last 4 digits and a generated transaction id are kept
/// on the booking. Swap [_chargeGateway] for a real provider (e.g. PayHere or
/// Stripe through a Cloud Function) when moving beyond the prototype.
///
/// Test cards: any Luhn-valid number succeeds (e.g. 4242 4242 4242 4242),
/// except 4000 0000 0000 0002 which is always declined.
class PaymentService {
  static const String declinedTestCard = '4000000000000002';

  static const List<String> supportedBanks = [
    'Bank of Ceylon',
    'Commercial Bank',
    'Hatton National Bank',
    "People's Bank",
    'Sampath Bank',
  ];

  // ---- Validation (used by the form fields and before charging) ----

  static String? validateHolderName(String? value) {
    if (value == null || value.trim().length < 3) {
      return 'Enter the name shown on the card';
    }
    return null;
  }

  static String? validateCardNumber(String? value) {
    final digits = (value ?? '').replaceAll(RegExp(r'\D'), '');
    if (digits.length < 13 || digits.length > 19) {
      return 'Enter a valid card number';
    }
    if (!_passesLuhn(digits)) {
      return 'Card number is not valid';
    }
    return null;
  }

  static String? validateExpiry(String? value, {DateTime? now}) {
    final match = RegExp(r'^(\d{2})\s*/\s*(\d{2})$').firstMatch(value?.trim() ?? '');
    if (match == null) return 'Use MM/YY';

    final month = int.parse(match.group(1)!);
    final year = 2000 + int.parse(match.group(2)!);
    if (month < 1 || month > 12) return 'Invalid month';

    final today = now ?? DateTime.now();
    // Cards are valid until the end of their expiry month.
    final firstDayAfterExpiry = DateTime(year, month + 1);
    if (!today.isBefore(firstDayAfterExpiry)) return 'Card has expired';
    return null;
  }

  static String? validateCvv(String? value) {
    if (!RegExp(r'^\d{3,4}$').hasMatch(value?.trim() ?? '')) {
      return 'Enter the 3 or 4 digit CVV';
    }
    return null;
  }

  static bool _passesLuhn(String digits) {
    var sum = 0;
    var doubleIt = false;
    for (var i = digits.length - 1; i >= 0; i--) {
      var n = int.parse(digits[i]);
      if (doubleIt) {
        n *= 2;
        if (n > 9) n -= 9;
      }
      sum += n;
      doubleIt = !doubleIt;
    }
    return sum % 10 == 0;
  }

  // ---- Processing ----

  Future<PaymentResult> process({
    required PaymentMethod method,
    required double amount,
    CardDetails? card,
    String? bank,
  }) async {
    if (amount <= 0) {
      return const PaymentResult(success: false, message: 'Invalid payment amount.');
    }

    switch (method) {
      case PaymentMethod.cashOnPickup:
        return const PaymentResult(
          success: true,
          message: 'Pay the provider in cash when you collect the equipment.',
          paymentStatus: PaymentStatus.payOnPickup,
        );

      case PaymentMethod.card:
        if (card == null) {
          return const PaymentResult(success: false, message: 'Card details are missing.');
        }
        final error = validateHolderName(card.holderName) ??
            validateCardNumber(card.number) ??
            validateExpiry(card.expiry) ??
            validateCvv(card.cvv);
        if (error != null) {
          return PaymentResult(success: false, message: error);
        }
        if (card.digits == declinedTestCard) {
          await _chargeGateway();
          return const PaymentResult(
            success: false,
            message: 'Your card was declined. Please try another card.',
          );
        }
        return PaymentResult(
          success: true,
          message: 'Payment successful.',
          transactionId: await _chargeGateway(),
          cardLast4: card.last4,
          paymentStatus: PaymentStatus.paid,
        );

      case PaymentMethod.onlineBanking:
        if (bank == null || !supportedBanks.contains(bank)) {
          return const PaymentResult(success: false, message: 'Please select your bank.');
        }
        return PaymentResult(
          success: true,
          message: 'Payment successful via $bank.',
          transactionId: await _chargeGateway(),
          paymentStatus: PaymentStatus.paid,
        );
    }
  }

  /// Stands in for the network call to a payment gateway.
  Future<String> _chargeGateway() async {
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random.secure();
    final code = List.generate(10, (_) => chars[random.nextInt(chars.length)]).join();
    return 'TXN-$code';
  }
}
