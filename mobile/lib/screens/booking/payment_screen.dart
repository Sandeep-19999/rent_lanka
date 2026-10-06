import 'package:flutter/material.dart';

import '../../models/booking_preview.dart';
import 'booking_confirmation_screen.dart';
import 'booking_ui.dart';

class PaymentScreen extends StatelessWidget {
  final BookingPreview booking;

  const PaymentScreen({
    super.key,
    required this.booking,
  });

  @override
  Widget build(BuildContext context) {
    final card = booking.paymentMethod == 'card';

    return bookingPage(
      'Payment',
      [
        Icon(
          card
              ? Icons.credit_card_outlined
              : Icons.account_balance_outlined,
          size: 64,
          color: bookingRed,
        ),
        const SizedBox(height: 20),
        Text(
          card ? 'Card Payment' : 'Online Banking',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 24),
        bookingInformation(booking),
        bookingPrices(booking),
        bookingButton(
          'Continue',
          booking.valid
              ? () {
                  Navigator.pushReplacement<void, void>(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          BookingConfirmationScreen(booking: booking),
                    ),
                  );
                }
              : null,
        ),
        bookingButton(
          'Back to Checkout',
          () => Navigator.pop(context),
          outlined: true,
        ),
        bookingPreviewNote,
      ],
    );
  }
}