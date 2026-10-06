import 'package:flutter/material.dart';

import 'player/browse_equipment_screen.dart';
import 'player/widgets/booking_widgets.dart';
import 'provider/provider_dashboard.dart';

/// TEMPORARY start screen for testing both sides of the app until
/// Splash / Login / Role Selection are built.
class DevLauncherScreen extends StatelessWidget {
  const DevLauncherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BookingPage(
      title: 'Rent Lanka',
      showBack: false,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Choose a side to test',
              style: TextStyle(color: textGrey),
            ),
            const SizedBox(height: 20),
            _RoleCard(
              icon: Icons.sports_cricket,
              title: 'Sports Player',
              subtitle: 'Browse, book and pay for equipment, view My Bookings',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BrowseEquipmentScreen()),
              ),
            ),
            const SizedBox(height: 14),
            _RoleCard(
              icon: Icons.storefront,
              title: 'Equipment Provider',
              subtitle: 'Listings, rental requests, pickup and return',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProviderDashboard()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderGrey),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: primaryRed.withValues(alpha: 0.1),
              child: Icon(icon, color: primaryRed),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: textGrey)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
