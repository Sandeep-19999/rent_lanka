import 'package:flutter/material.dart';

import '../../models/booking.dart';
import '../../services/booking_service.dart';
import '../../utils/date_utils.dart';
import 'booking_details_screen.dart';
import 'widgets/booking_widgets.dart';

/// My Bookings: the player's rentals grouped as Upcoming / Active / Past,
/// updated live as the provider accepts, hands over or completes them.
class MyBookingsScreen extends StatelessWidget {
  /// Hide the back arrow when shown as a bottom-navigation tab.
  final bool showBack;

  const MyBookingsScreen({super.key, this.showBack = true});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: BookingPage(
        title: 'My Bookings',
        showBack: showBack,
        body: StreamBuilder<List<Booking>>(
          stream: BookingService().watchMyBookings(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'Could not load your bookings. Check your connection '
                    'and try again.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              );
            }
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(color: primaryRed),
              );
            }

            final bookings = snapshot.data!;
            final upcoming = bookings.where((b) => b.isUpcoming).toList();
            final active = bookings.where((b) => b.isActive).toList();
            final past = bookings.where((b) => b.isPast).toList();

            return Column(
              children: [
                TabBar(
                  labelColor: primaryRed,
                  unselectedLabelColor: textGrey,
                  indicatorColor: primaryRed,
                  labelStyle: const TextStyle(fontWeight: FontWeight.w700),
                  tabs: [
                    Tab(text: 'Upcoming (${upcoming.length})'),
                    Tab(text: 'Active (${active.length})'),
                    Tab(text: 'Past (${past.length})'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _BookingList(
                        bookings: upcoming,
                        emptyText: 'No upcoming bookings.\n'
                            'Find equipment and book it to see it here.',
                      ),
                      _BookingList(
                        bookings: active,
                        emptyText: 'Nothing in use right now.',
                      ),
                      _BookingList(
                        bookings: past,
                        emptyText: 'Completed and cancelled bookings '
                            'will appear here.',
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _BookingList extends StatelessWidget {
  final List<Booking> bookings;
  final String emptyText;

  const _BookingList({required this.bookings, required this.emptyText});

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.event_note_outlined, size: 56, color: textGrey),
              const SizedBox(height: 12),
              Text(
                emptyText,
                textAlign: TextAlign.center,
                style: const TextStyle(color: textGrey, height: 1.4),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: bookings.length,
      separatorBuilder: (_, _) => const SizedBox(height: 14),
      itemBuilder: (context, index) => _BookingCard(booking: bookings[index]),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final Booking booking;

  const _BookingCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BookingDetailsScreen(bookingId: booking.id),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderGrey),
        ),
        child: Row(
          children: [
            EquipmentThumb(category: booking.equipmentCategory),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          booking.equipmentName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      BookingStatusChip(status: booking.status),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    AppDates.prettyRange(booking.startDate, booking.endDate),
                    style: const TextStyle(color: textGrey, fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        booking.bookingReference,
                        style: const TextStyle(
                          color: textGrey,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        formatLkr(booking.totalPayable),
                        style: const TextStyle(
                          color: primaryRed,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
