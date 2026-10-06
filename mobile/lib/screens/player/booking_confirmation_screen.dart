import 'package:flutter/material.dart';

import '../../models/booking.dart';
import '../../services/booking_service.dart';
import '../../utils/date_utils.dart';
import 'booking_details_screen.dart';
import 'my_bookings_screen.dart';
import 'widgets/booking_widgets.dart';

/// Booking Confirmation (FR12 / FR13): clear success state with the
/// booking reference and payment receipt.
class BookingConfirmationScreen extends StatelessWidget {
  final String bookingId;

  const BookingConfirmationScreen({super.key, required this.bookingId});

  void _backToHome(BuildContext context) {
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Back goes home rather than into the finished payment flow.
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _backToHome(context);
      },
      child: StreamBuilder<Booking?>(
        stream: BookingService().watchBooking(bookingId),
        builder: (context, snapshot) {
          final booking = snapshot.data;

          return BookingPage(
            title: 'Booking Confirmation',
            showBack: false,
            bottom: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                PrimaryButton(
                  label: 'View My Bookings',
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const MyBookingsScreen()),
                  ),
                ),
                const SizedBox(height: 10),
                SecondaryButton(
                  label: 'Back to Home',
                  icon: Icons.home_outlined,
                  onPressed: () => _backToHome(context),
                ),
              ],
            ),
            body: booking == null
                ? Center(
                    child: snapshot.hasError
                        ? const Text('Could not load booking.')
                        : const CircularProgressIndicator(color: primaryRed),
                  )
                : _ConfirmationBody(booking: booking),
          );
        },
      ),
    );
  }
}

class _ConfirmationBody extends StatelessWidget {
  final Booking booking;

  const _ConfirmationBody({required this.booking});

  @override
  Widget build(BuildContext context) {
    final paid = booking.paymentStatus == PaymentStatus.paid;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        children: [
          const BookingSteps(current: 3),
          const SizedBox(height: 28),

          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32).withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              color: Color(0xFF2E7D32),
              size: 64,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Booking request sent!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            paid
                ? 'Your payment was successful. The provider will confirm '
                    'your booking shortly.'
                : 'The provider will confirm your booking shortly. '
                    'Pay in cash at pickup.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: textGrey, height: 1.4),
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: softGrey,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Booking ref: ${booking.bookingReference}',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ),

          const SizedBox(height: 22),

          SectionCard(
            child: Column(
              children: [
                Row(
                  children: [
                    EquipmentThumb(category: booking.equipmentCategory),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        booking.equipmentName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    BookingStatusChip(status: booking.status),
                  ],
                ),
                const Divider(height: 24, color: borderGrey),
                InfoRow(
                  label: 'Dates',
                  value: AppDates.prettyRange(booking.startDate, booking.endDate),
                ),
                InfoRow(label: 'Collection', value: booking.pickupMethod.label),
                InfoRow(label: 'Payment', value: booking.paymentMethod.label),
                if (booking.transactionId.isNotEmpty)
                  InfoRow(label: 'Transaction', value: booking.transactionId),
                InfoRow(
                  label: paid ? 'Amount paid' : 'Amount due at pickup',
                  value: formatLkr(booking.totalPayable),
                  emphasise: true,
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BookingDetailsScreen(bookingId: booking.id),
              ),
            ),
            icon: const Icon(Icons.receipt_long, color: primaryRed),
            label: const Text(
              'View booking details',
              style: TextStyle(color: primaryRed, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
