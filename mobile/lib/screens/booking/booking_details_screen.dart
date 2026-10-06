import 'package:flutter/material.dart';

import '../../models/booking_preview.dart';
import 'booking_ui.dart';
import 'cancel_booking_screen.dart';
import 'edit_booking_screen.dart';

class BookingDetailsScreen extends StatelessWidget {
  final BookingPreview booking;

  const BookingDetailsScreen({
    super.key,
    required this.booking,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: booking,
      builder: (context, _) {
        return bookingPage(
          'Booking Details',
          [
            bookingInformation(booking),
            bookingCard(
              'Booking Information',
              [
                bookingRow(
                  'Status',
                  booking.cancelled
                      ? 'Cancelled in preview'
                      : 'Not submitted',
                ),
                bookingRow('Reservation', 'Not reserved'),
                bookingRow(
                  'Payment Method',
                  booking.paymentMethod == 'card'
                      ? 'Card'
                      : 'Online Banking',
                ),
                bookingRow('Payment Status', 'Not charged'),
                if (booking.cancelled)
                  bookingRow(
                    'Cancellation Reason',
                    booking.cancellationReason!,
                  ),
              ],
            ),
            bookingPrices(booking),
            if (!booking.cancelled) ...[
              bookingButton(
                'Edit Booking',
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => EditBookingScreen(
                        booking: booking,
                      ),
                    ),
                  );
                },
              ),
              bookingButton(
                'Cancel Booking',
                () async {
                  final reason = await Navigator.push<String>(
                    context,
                    MaterialPageRoute<String>(
                      builder: (_) => CancelBookingScreen(
                        equipmentName: booking.equipmentName,
                      ),
                    ),
                  );

                  if (reason != null) {
                    booking.cancel(reason);
                  }
                },
                outlined: true,
              ),
            ],
            bookingButton(
              'Back to My Bookings',
              () => Navigator.pop(context),
              outlined: true,
            ),
            bookingPreviewNote,
          ],
        );
      },
    );
  }
}