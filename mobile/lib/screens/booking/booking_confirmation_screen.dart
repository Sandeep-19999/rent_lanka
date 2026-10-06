import 'package:flutter/material.dart';

import '../../models/booking_preview.dart';
import 'booking_ui.dart';
import 'my_bookings_screen.dart';

class BookingConfirmationScreen extends StatelessWidget {
  final BookingPreview booking;

  const BookingConfirmationScreen({
    super.key,
    required this.booking,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: booking,
      builder: (context, _) {
        return bookingPage(
          'Booking Overview',
          [
            const Icon(
              Icons.fact_check_outlined,
              size: 68,
              color: bookingRed,
            ),
            const SizedBox(height: 20),
            const Text(
              'Booking Review Complete',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 24),
            bookingInformation(booking),
            bookingCard(
              'Booking Status',
              [
                bookingRow(
                  'Status',
                  booking.cancelled
                      ? 'Cancelled in preview'
                      : 'Not submitted',
                ),
                bookingRow('Payment Status', 'Not charged'),
                bookingRow(
                  'Payment Method',
                  booking.paymentMethod == 'card'
                      ? 'Card'
                      : 'Online Banking',
                ),
              ],
            ),
            bookingPrices(booking),
            bookingButton(
              'View Booking Preview',
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => MyBookingsScreen(booking: booking),
                  ),
                );
              },
            ),
            bookingButton(
              'Back to Checkout',
              () => Navigator.pop(context),
              outlined: true,
            ),
            bookingButton(
              'Back to Equipment',
              () => Navigator.popUntil(context, (route) => route.isFirst),
              outlined: true,
            ),
            bookingPreviewNote,
          ],
        );
      },
    );
  }
}