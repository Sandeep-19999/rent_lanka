import 'package:flutter/material.dart';

import '../../models/booking_preview.dart';
import 'booking_details_screen.dart';
import 'booking_ui.dart';

class MyBookingsScreen extends StatefulWidget {
  final BookingPreview booking;

  const MyBookingsScreen({
    super.key,
    required this.booking,
  });

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.booking,
      builder: (context, _) {
        final booking = widget.booking;
        final showBooking = _filter == 'All' ||
            (_filter == 'Not submitted' && !booking.cancelled) ||
            (_filter == 'Cancelled' && booking.cancelled);

        return bookingPage(
          'My Bookings',
          [
            const Text(
              'Your equipment rentals',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                'All',
                'Not submitted',
                'Active',
                'Completed',
                'Cancelled',
              ].map((filter) {
                return ChoiceChip(
                  label: Text(filter),
                  selected: _filter == filter,
                  selectedColor: const Color(0xFFFFE8EC),
                  onSelected: (_) => setState(() => _filter = filter),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            if (showBooking)
              bookingCard(
                booking.equipmentName,
                [
                  bookingRow(
                    'Status',
                    booking.cancelled
                        ? 'Cancelled in preview'
                        : 'Not submitted',
                  ),
                  bookingRow(
                    'Rental Dates',
                    bookingDates(booking.rentalDates),
                  ),
                  bookingRow('Duration', '${booking.days} days'),
                  bookingRow(
                    'Receive Method',
                    booking.receiveMethod == 'pickup'
                        ? 'Pickup'
                        : 'Delivery',
                  ),
                  bookingRow(
                    'Payment Method',
                    booking.paymentMethod == 'card'
                        ? 'Card'
                        : 'Online Banking',
                  ),
                  bookingRow(
                    booking.finalAmountKnown ? 'Total' : 'Known Subtotal',
                    bookingMoney(booking.knownSubtotal),
                  ),
                  const SizedBox(height: 18),
                  bookingButton(
                    'View Details',
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) =>
                              BookingDetailsScreen(booking: booking),
                        ),
                      );
                    },
                    outlined: true,
                  ),
                ],
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 48),
                child: Column(
                  children: [
                    const Icon(
                      Icons.event_note_outlined,
                      size: 60,
                      color: Colors.black38,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No ${_filter.toLowerCase()} bookings',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
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