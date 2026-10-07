import 'package:flutter/material.dart';

import '../../models/booking.dart';
import '../../services/booking_service.dart';
import '../../utils/date_utils.dart';
import 'widgets/booking_widgets.dart';

/// Booking Details: status progress, rental + pickup info, payment
/// receipt and the Cancel Booking action.
class BookingDetailsScreen extends StatelessWidget {
  final String bookingId;

  /// Optional hook for the Messaging module ("Message Provider").
  final void Function(Booking booking)? onMessageProvider;

  const BookingDetailsScreen({
    super.key,
    required this.bookingId,
    this.onMessageProvider,
  });

  Future<void> _cancel(BuildContext context, Booking booking) async {
    final reasonController = TextEditingController();
    final paid = booking.paymentStatus == PaymentStatus.paid;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancel booking?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              paid
                  ? '${formatLkr(booking.totalPayable)} will be refunded to '
                      'your original payment method.'
                  : 'The provider will be notified.',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason (optional)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Keep booking'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Cancel booking',
              style: TextStyle(color: primaryRed),
            ),
          ),
        ],
      ),
    );

    final reason = reasonController.text;
    reasonController.dispose();
    if (confirmed != true || !context.mounted) return;

    try {
      await BookingService().cancelBooking(booking.id, reason: reason);
      if (!context.mounted) return;
      showMessage(context, 'Booking cancelled.');
    } on BookingException catch (error) {
      if (!context.mounted) return;
      showMessage(context, error.message, error: true);
    } catch (_) {
      if (!context.mounted) return;
      showMessage(context, 'Could not cancel the booking. Please try again.',
          error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Booking?>(
      stream: BookingService().watchBooking(bookingId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const BookingPage(
            title: 'Booking Details',
            body: Center(child: Text('Could not load this booking.')),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const BookingPage(
            title: 'Booking Details',
            body: Center(child: CircularProgressIndicator(color: primaryRed)),
          );
        }

        final booking = snapshot.data;
        if (booking == null) {
          return const BookingPage(
            title: 'Booking Details',
            body: Center(child: Text('Booking not found.')),
          );
        }

        final actions = <Widget>[
          if (onMessageProvider != null)
            SecondaryButton(
              label: 'Message Provider',
              icon: Icons.chat_bubble_outline,
              onPressed: () => onMessageProvider!(booking),
            ),
          if (booking.canCancel)
            SecondaryButton(
              label: 'Cancel Booking',
              icon: Icons.close,
              color: primaryRed,
              onPressed: () => _cancel(context, booking),
            ),
        ];

        return BookingPage(
          title: 'Booking Details',
          bottom: actions.isEmpty
              ? null
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var i = 0; i < actions.length; i++) ...[
                      if (i > 0) const SizedBox(height: 10),
                      actions[i],
                    ],
                  ],
                ),
          body: _DetailsBody(booking: booking),
        );
      },
    );
  }
}

class _DetailsBody extends StatelessWidget {
  final Booking booking;

  const _DetailsBody({required this.booking});

  @override
  Widget build(BuildContext context) {
    final paid = booking.paymentStatus == PaymentStatus.paid;
    final refunded = booking.paymentStatus == PaymentStatus.refunded;
    final refundDue = paid && booking.status == BookingStatus.rejected;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionCard(
            child: Row(
              children: [
                EquipmentThumb(category: booking.equipmentCategory),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.equipmentName,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        booking.bookingReference,
                        style: const TextStyle(
                          color: textGrey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                BookingStatusChip(status: booking.status),
              ],
            ),
          ),

          const SizedBox(height: 14),
          SectionCard(
            title: 'Status',
            child: _StatusTimeline(status: booking.status),
          ),

          const SizedBox(height: 14),
          SectionCard(
            title: 'Rental',
            child: Column(
              children: [
                InfoRow(label: 'Start date', value: AppDates.prettyKey(booking.startDate)),
                InfoRow(label: 'End date', value: AppDates.prettyKey(booking.endDate)),
                InfoRow(
                  label: 'Duration',
                  value: '${booking.rentalDays} day${booking.rentalDays == 1 ? '' : 's'}',
                ),
                InfoRow(label: 'Provider', value: booking.providerName),
              ],
            ),
          ),

          const SizedBox(height: 14),
          SectionCard(
            title: 'Pickup',
            child: Column(
              children: [
                InfoRow(label: 'Method', value: booking.pickupMethod.label),
                InfoRow(
                  label: booking.pickupMethod == PickupMethod.delivery
                      ? 'Deliver to'
                      : 'Location',
                  value: booking.pickupLocation.isEmpty
                      ? 'Shared by provider'
                      : booking.pickupLocation,
                ),
                if (booking.note.isNotEmpty)
                  InfoRow(label: 'Your note', value: booking.note),
              ],
            ),
          ),

          const SizedBox(height: 14),
          SectionCard(
            title: 'Payment',
            child: Column(
              children: [
                InfoRow(
                  label: 'Rental (${booking.rentalDays} x '
                      '${formatLkr(booking.pricePerDay)})',
                  value: formatLkr(booking.rentalCost),
                ),
                if (booking.deliveryFee > 0)
                  InfoRow(label: 'Delivery fee', value: formatLkr(booking.deliveryFee)),
                InfoRow(label: 'Service fee', value: formatLkr(booking.serviceFee)),
                InfoRow(
                  label: 'Refundable deposit',
                  value: formatLkr(booking.depositAmount),
                ),
                const Divider(height: 22, color: borderGrey),
                InfoRow(
                  label: 'Total',
                  value: formatLkr(booking.totalPayable),
                  emphasise: true,
                ),
                const SizedBox(height: 6),
                InfoRow(
                  label: 'Method',
                  value: booking.cardLast4.isNotEmpty
                      ? '${booking.paymentMethod.label} •••• ${booking.cardLast4}'
                      : booking.paymentMethod.label,
                ),
                InfoRow(
                  label: 'Payment status',
                  value: refunded
                      ? 'Refunded'
                      : refundDue
                          ? 'Refund pending'
                          : paid
                              ? 'Paid'
                              : 'Pay at pickup',
                  valueColor: refunded || refundDue
                      ? primaryRed
                      : paid
                          ? const Color(0xFF2E7D32)
                          : const Color(0xFFE08A00),
                ),
                if (booking.transactionId.isNotEmpty)
                  InfoRow(label: 'Transaction ID', value: booking.transactionId),
                if (booking.createdAt != null)
                  InfoRow(
                    label: 'Booked on',
                    value: AppDates.pretty(booking.createdAt!),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusTimeline extends StatelessWidget {
  final String status;

  const _StatusTimeline({required this.status});

  static const _steps = [
    (BookingStatus.pending, 'Request sent', 'Waiting for the provider'),
    (BookingStatus.accepted, 'Confirmed', 'Provider accepted your booking'),
    (BookingStatus.active, 'Picked up', 'Equipment is with you'),
    (BookingStatus.completed, 'Returned', 'Rental completed'),
  ];

  @override
  Widget build(BuildContext context) {
    if (status == BookingStatus.cancelled || status == BookingStatus.rejected) {
      return Row(
        children: [
          const Icon(Icons.cancel, color: primaryRed),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              status == BookingStatus.cancelled
                  ? 'You cancelled this booking.'
                  : 'The provider declined this request. Any payment '
                      'will be refunded.',
            ),
          ),
        ],
      );
    }

    final currentIndex = _steps.indexWhere((s) => s.$1 == status);

    return Column(
      children: [
        for (var i = 0; i < _steps.length; i++)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Icon(
                    i <= currentIndex
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    size: 22,
                    color: i <= currentIndex ? primaryRed : borderGrey,
                  ),
                  if (i < _steps.length - 1)
                    Container(
                      width: 2,
                      height: 24,
                      color: i < currentIndex ? primaryRed : borderGrey,
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _steps[i].$2,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: i <= currentIndex ? Colors.black : textGrey,
                      ),
                    ),
                    Text(
                      _steps[i].$3,
                      style: const TextStyle(color: textGrey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }
}
