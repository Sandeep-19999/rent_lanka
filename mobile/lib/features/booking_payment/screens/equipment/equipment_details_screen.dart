import 'package:flutter/material.dart';

import '../../models/equipment_model.dart';
import '../../services/booking_service.dart';
import '../../utils/date_utils.dart';
import '../booking/booking_screen.dart';
import '../../widgets/booking_widgets.dart';

/// Equipment Details (EV03 / FR04, FR05): photos, condition, price,
/// brand, size, provider and availability, with the Book Now action.
class EquipmentDetailsScreen extends StatelessWidget {
  final String equipmentId;

  /// Optional hook for the Exchange Request flow (other module).
  final void Function(Equipment equipment)? onRequestExchange;

  const EquipmentDetailsScreen({
    super.key,
    required this.equipmentId,
    this.onRequestExchange,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Equipment?>(
      stream: BookingService().watchEquipment(equipmentId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const BookingPage(
            title: 'Equipment Details',
            body: Center(
              child: Text(
                'Could not load this equipment.',
                style: TextStyle(color: Colors.red),
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const BookingPage(
            title: 'Equipment Details',
            body: Center(child: CircularProgressIndicator(color: primaryRed)),
          );
        }

        final equipment = snapshot.data;
        if (equipment == null) {
          return const BookingPage(
            title: 'Equipment Details',
            body: Center(child: Text('This equipment is no longer listed.')),
          );
        }

        return BookingPage(
          title: 'Equipment Details',
          body: _DetailsBody(equipment: equipment),
          bottom: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PrimaryButton(
                label: equipment.canBeBooked ? 'Book Now' : 'Not available',
                icon: Icons.event_available,
                onPressed: equipment.canBeBooked
                    ? () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BookingScreen(equipment: equipment),
                          ),
                        )
                    : null,
              ),
              if (onRequestExchange != null) ...[
                const SizedBox(height: 10),
                SecondaryButton(
                  label: 'Request Exchange',
                  icon: Icons.swap_horiz,
                  onPressed: () => onRequestExchange!(equipment),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _DetailsBody extends StatelessWidget {
  final Equipment equipment;

  const _DetailsBody({required this.equipment});

  @override
  Widget build(BuildContext context) {
    final available = equipment.canBeBooked;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EquipmentThumb(
            category: equipment.category,
            imageUrl: equipment.imageUrl,
            size: double.infinity,
            iconSize: 80,
          ).withHeight(200),

          const SizedBox(height: 20),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  equipment.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              _Badge(
                label: available ? 'Available' : equipment.status,
                color: available ? const Color(0xFF2E7D32) : textGrey,
              ),
            ],
          ),

          const SizedBox(height: 6),

          if (equipment.category.isNotEmpty)
            Text(
              equipment.category,
              style: const TextStyle(color: textGrey, fontSize: 15),
            ),

          const SizedBox(height: 14),

          // Price and condition are the two most requested facts (76% each).
          Row(
            children: [
              Text(
                '${formatLkr(equipment.pricePerDay)} ',
                style: const TextStyle(
                  color: primaryRed,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Text('/ day', style: TextStyle(color: textGrey)),
              const Spacer(),
              if (equipment.condition.isNotEmpty)
                _Badge(
                  label: equipment.condition,
                  color: const Color(0xFF1E88E5),
                  icon: Icons.verified_outlined,
                ),
            ],
          ),

          const SizedBox(height: 20),

          SectionCard(
            title: 'Specifications',
            child: Column(
              children: [
                InfoRow(label: 'Condition', value: _orDash(equipment.condition)),
                InfoRow(label: 'Brand', value: _orDash(equipment.brand)),
                InfoRow(label: 'Size', value: _orDash(equipment.size)),
                InfoRow(label: 'Sport', value: _orDash(equipment.category)),
                InfoRow(
                  label: 'Refundable deposit',
                  value: formatLkr(equipment.depositAmount),
                ),
              ],
            ),
          ),

          if (equipment.description.isNotEmpty) ...[
            const SizedBox(height: 14),
            SectionCard(
              title: 'Description',
              child: Text(
                equipment.description,
                style: const TextStyle(height: 1.45, color: Colors.black87),
              ),
            ),
          ],

          const SizedBox(height: 14),

          SectionCard(
            title: 'Provider',
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 22,
                  backgroundColor: softGrey,
                  child: Icon(Icons.storefront, color: Colors.black54),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        equipment.providerName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        equipment.location.isNotEmpty
                            ? equipment.location
                            : 'Pickup location shared after booking',
                        style: const TextStyle(color: textGrey, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          _UnavailableDates(dates: equipment.unavailableDates),
        ],
      ),
    );
  }

  static String _orDash(String value) => value.isEmpty ? '-' : value;
}

class _UnavailableDates extends StatelessWidget {
  final List<String> dates;

  const _UnavailableDates({required this.dates});

  @override
  Widget build(BuildContext context) {
    final today = AppDates.dateOnly(DateTime.now());
    final upcoming = dates
        .map(AppDates.parseKey)
        .whereType<DateTime>()
        .where((d) => !d.isBefore(today))
        .toList()
      ..sort();

    return SectionCard(
      title: 'Availability',
      child: upcoming.isEmpty
          ? const Text(
              'No blocked dates set by the provider. '
              'You will see booked dates when you pick your rental period.',
              style: TextStyle(color: textGrey, height: 1.4),
            )
          : Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                const SizedBox(
                  width: double.infinity,
                  child: Text(
                    'Not available on:',
                    style: TextStyle(color: textGrey),
                  ),
                ),
                for (final date in upcoming.take(10))
                  Chip(
                    label: Text(AppDates.pretty(date)),
                    visualDensity: VisualDensity.compact,
                    backgroundColor: softGrey,
                    side: BorderSide.none,
                  ),
                if (upcoming.length > 10)
                  Chip(
                    label: Text('+${upcoming.length - 10} more'),
                    visualDensity: VisualDensity.compact,
                    side: BorderSide.none,
                  ),
              ],
            ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const _Badge({required this.label, required this.color, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

extension on Widget {
  Widget withHeight(double height) => SizedBox(height: height, child: this);
}
