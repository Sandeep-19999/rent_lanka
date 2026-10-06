import 'package:flutter/material.dart';

import '../../models/booking_preview.dart';
import 'booking_ui.dart';
import 'payment_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final String equipmentId;
  final String providerId;
  final String equipmentName;
  final double pricePerDay;
  final DateTimeRange rentalDates;
  final double? securityDeposit;
  final String receiveMethod;
  final String deliveryAddress;
  final double? deliveryFee;

  const CheckoutScreen({
    super.key,
    required this.equipmentId,
    required this.providerId,
    required this.equipmentName,
    required this.pricePerDay,
    required this.rentalDates,
    required this.securityDeposit,
    required this.receiveMethod,
    required this.deliveryAddress,
    this.deliveryFee,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _paymentMethod = 'card';

  Widget _paymentOption(String value, String label, IconData icon) {
    final selected = _paymentMethod == value;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: selected ? bookingRed : const Color(0xFFE4E4E8),
          ),
        ),
        tileColor: selected ? const Color(0xFFFFEEF1) : Colors.white,
        leading: Icon(icon, color: bookingRed),
        title: Text(label),
        trailing: Icon(
          selected
              ? Icons.radio_button_checked
              : Icons.radio_button_unchecked,
          color: selected ? bookingRed : Colors.grey,
        ),
        onTap: () => setState(() => _paymentMethod = value),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final booking = BookingPreview(
      equipmentId: widget.equipmentId,
      providerId: widget.providerId,
      equipmentName: widget.equipmentName,
      pricePerDay: widget.pricePerDay,
      rentalDates: widget.rentalDates,
      securityDeposit: widget.securityDeposit,
      receiveMethod: widget.receiveMethod,
      deliveryAddress: widget.deliveryAddress,
      deliveryFee: widget.deliveryFee,
      paymentMethod: _paymentMethod,
    );

    return bookingPage(
      'Checkout',
      [
        const Text(
          'Review checkout details',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 24),
        bookingInformation(booking),
        bookingPrices(booking),
        const Text(
          'Payment Method',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 16),
        _paymentOption('card', 'Card', Icons.credit_card_outlined),
        _paymentOption(
          'online_banking',
          'Online Banking',
          Icons.account_balance_outlined,
        ),
        const SizedBox(height: 18),
        bookingButton(
          'Continue to Payment',
          booking.valid
              ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => PaymentScreen(booking: booking),
                    ),
                  );
                }
              : null,
        ),
        if (!booking.valid)
          const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Text(
              'Some booking details are missing or invalid. '
              'Return to the summary and check your selections.',
              style: TextStyle(color: bookingRed),
            ),
          ),
        bookingButton(
          'Back to Booking Summary',
          () => Navigator.pop(context),
          outlined: true,
        ),
        bookingPreviewNote,
      ],
    );
  }
}