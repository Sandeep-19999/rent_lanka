import 'package:flutter/material.dart';

import '../../models/equipment.dart';
import '../../services/booking_service.dart';
import '../../utils/date_utils.dart';
import 'equipment_details_screen.dart';
import 'my_bookings_screen.dart';
import 'widgets/booking_widgets.dart';

/// TEMPORARY: simple list of bookable equipment so the booking flow can be
/// tested before the Home / Search / Filter screens are connected.
/// Those screens should open `EquipmentDetailsScreen(equipmentId: ...)`.
class BrowseEquipmentScreen extends StatelessWidget {
  const BrowseEquipmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BookingPage(
      title: 'Equipment',
      bottom: SecondaryButton(
        label: 'My Bookings',
        icon: Icons.event_note_outlined,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MyBookingsScreen()),
        ),
      ),
      body: StreamBuilder<List<Equipment>>(
        stream: BookingService().watchBookableEquipment(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Failed to load equipment:\n${snapshot.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: primaryRed),
            );
          }

          final items = snapshot.data!;
          if (items.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'No equipment listed yet.\n'
                  'Add some from the Provider side first.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: textGrey),
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                contentPadding: const EdgeInsets.all(10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                  side: const BorderSide(color: borderGrey),
                ),
                leading: EquipmentThumb(
                  category: item.category,
                  imageUrl: item.imageUrl,
                  size: 56,
                ),
                title: Text(
                  item.name,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: Text(
                  [item.category, item.condition]
                      .where((s) => s.isNotEmpty)
                      .join(' - '),
                ),
                trailing: Text(
                  '${formatLkr(item.pricePerDay)}\n/ day',
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: primaryRed,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EquipmentDetailsScreen(equipmentId: item.id),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
