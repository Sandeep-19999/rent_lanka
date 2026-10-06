import 'package:flutter/material.dart';

import '../../models/booking.dart';
import '../../services/booking_service.dart';
import '../../utils/date_utils.dart';
import 'payment_screen.dart';
import 'widgets/booking_widgets.dart';

/// Booking Summary: clear cost breakdown and total before payment.
class BookingSummaryScreen extends StatelessWidget {
  final BookingDraft draft;

  const BookingSummaryScreen({super.key, required this.draft});

  @override
  Widget build(BuildContext context) {
    final equipment = draft.equipment;
    final price = draft.price;
    final days = price.rentalDays;

    return BookingPage(
      title: 'Booking Summary',
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InfoRow(
            label: 'Total due',
            value: formatLkr(price.totalPayable),
            emphasise: true,
          ),
          const SizedBox(height: 10),
          PrimaryButton(
            label: 'Proceed to Payment',
            icon: Icons.lock_outline,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => PaymentScreen(draft: draft)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BookingSteps(current: 1),
            const SizedBox(height: 20),

            SectionCard(
              child: Row(
                children: [
                  EquipmentThumb(
                    category: equipment.category,
                    imageUrl: equipment.imageUrl,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          equipment.name,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          [equipment.condition, equipment.brand]
                              .where((s) => s.isNotEmpty)
                              .join(' - '),
                          style: const TextStyle(color: textGrey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            SectionCard(
              title: 'Rental details',
              child: Column(
                children: [
                  InfoRow(
                    label: 'Start date',
                    value: AppDates.pretty(draft.startDate),
                  ),
                  InfoRow(
                    label: 'End date',
                    value: AppDates.pretty(draft.endDate),
                  ),
                  InfoRow(
                    label: 'Duration',
                    value: '$days day${days == 1 ? '' : 's'}',
                  ),
                  InfoRow(label: 'Collection', value: draft.pickupMethod.label),
                  InfoRow(
                    label: draft.pickupMethod == PickupMethod.delivery
                        ? 'Deliver to'
                        : 'Pickup at',
                    value: draft.pickupLocation,
                  ),
                  if (draft.note.trim().isNotEmpty)
                    InfoRow(label: 'Note', value: draft.note.trim()),
                ],
              ),
            ),

            const SizedBox(height: 14),

            SectionCard(
              title: 'Cost breakdown',
              child: Column(
                children: [
                  InfoRow(
                    label: '${formatLkr(price.pricePerDay)} x $days '
                        'day${days == 1 ? '' : 's'}',
                    value: formatLkr(price.rentalCost),
                  ),
                  if (price.deliveryFee > 0)
                    InfoRow(
                      label: 'Delivery fee',
                      value: formatLkr(price.deliveryFee),
                    ),
                  InfoRow(
                    label: 'Service fee '
                        '(${(PriceBreakdown.serviceFeeRate * 100).round()}%)',
                    value: formatLkr(price.serviceFee),
                  ),
                  InfoRow(
                    label: 'Refundable deposit',
                    value: formatLkr(price.deposit),
                  ),
                  const Divider(height: 22, color: borderGrey),
                  InfoRow(
                    label: 'Total',
                    value: formatLkr(price.totalPayable),
                    emphasise: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            const _Notice(
              icon: Icons.info_outline,
              text: 'The deposit is returned after the equipment is handed '
                  'back in good condition. The provider will confirm your '
                  'request - you can cancel for a full refund until then.',
            ),
          ],
        ),
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  final IconData icon;
  final String text;

  const _Notice({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: softGrey,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.black54),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.black54, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
