import 'package:flutter/material.dart';
import 'add_equipment_screen.dart';
import 'my_listings_screen.dart';
import 'rental_requests_screen.dart';

class ProviderDashboard extends StatelessWidget {
  const ProviderDashboard({super.key});

  static const Color primaryRed = Color(0xFFE00122);
  static const Color backgroundColor = Color(0xFFF8F8FA);
  static const Color lightGrey = Color(0xFFF4F4F6);
  static const Color textGrey = Color(0xFF8A8A8A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 20),

                  _buildEarningsCard(),
                  const SizedBox(height: 24),

                  _buildQuickActions(context),
                  const SizedBox(height: 28),

                  const Text(
                    'Management',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 14),

                  _managementCard(
                    icon: Icons.inbox_outlined,
                    iconColor: primaryRed,
                    iconBackground: const Color(0xFFFFEEF1),
                    title: 'Rental Requests',
                    subtitle: '3 pending reviews',
                    showNotification: true,
                    onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const RentalRequestsScreen(),
    ),
  );
},
                  ),

                  const SizedBox(height: 14),

                  _managementCard(
                    icon: Icons.inventory_2_outlined,
                    iconColor: Colors.black,
                    iconBackground: lightGrey,
                    title: 'My Equipment',
                    subtitle: '12 items listed (8 Rented)',
                    onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const MyListingsScreen(),
    ),
  );
},
                  ),

                  const SizedBox(height: 28),

                  const Text(
                    'Recent Activity',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 14),

                  _buildRecentActivity(),
                  const SizedBox(height: 30),

                  const Text(
                    'Top Earning Items',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: _earningItemCard(
                          icon: Icons.sports_cricket,
                          itemName: 'SS Cricket Bat',
                          earned: 'Rs. 14,400',
                          rented: '12 times rented',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _earningItemCard(
                          icon: Icons.sports_tennis,
                          itemName: 'Yonex Ball',
                          earned: 'Rs. 9,600',
                          rented: '12 times rented',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),

      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const CircleAvatar(
          radius: 24,
          backgroundColor: Color(0xFFE5E5E5),
          child: Icon(
            Icons.person,
            color: Colors.black54,
            size: 28,
          ),
        ),

        const SizedBox(width: 12),

        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good morning,',
                style: TextStyle(
                  fontSize: 14,
                  color: textGrey,
                ),
              ),
              Text(
                'Provider',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),

        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFFE6E6E6),
            ),
          ),
          child: Stack(
            children: [
              const Center(
                child: Icon(
                  Icons.notifications_none_rounded,
                  size: 25,
                ),
              ),
              Positioned(
                top: 9,
                right: 10,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: primaryRed,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEarningsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE00122),
            Color(0xFFB7263B),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Total Earnings',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'All Time',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          const Text(
            'Rs. 34,500',
            style: TextStyle(
              fontSize: 42,
              height: 1,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            'Available to withdraw: Rs. 21,000',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _quickAction(
          icon: Icons.add,
          label: 'Add Item',
          iconColor: primaryRed,
          background: const Color(0xFFFFEEF1),
          onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const AddEquipmentScreen(),
    ),
  );
},
        ),
        _quickAction(
          icon: Icons.north_east,
          label: 'Withdraw',
          onTap: () {
            _showComingSoon(context, 'Withdraw');
          },
        ),
        _quickAction(
          icon: Icons.bar_chart_rounded,
          label: 'Insights',
          onTap: () {
            _showComingSoon(context, 'Insights');
          },
        ),
        _quickAction(
          icon: Icons.schedule,
          label: 'History',
          onTap: () {
            _showComingSoon(context, 'History');
          },
        ),
      ],
    );
  }

  Widget _quickAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color iconColor = Colors.black,
    Color background = lightGrey,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        width: 75,
        child: Column(
          children: [
            Container(
              width: 66,
              height: 66,
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                icon,
                size: 30,
                color: iconColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _managementCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBackground,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool showNotification = false,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 26,
                ),
              ),

              const SizedBox(width: 15),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: textGrey,
                      ),
                    ),
                  ],
                ),
              ),

              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: const BoxDecoration(
                      color: lightGrey,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.chevron_right,
                      size: 27,
                    ),
                  ),

                  if (showNotification)
                    Positioned(
                      top: -3,
                      right: -2,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: primaryRed,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          _activityRow(
            icon: Icons.check,
            iconBackground: const Color(0xFFE8F7EC),
            iconColor: const Color(0xFF3BB85A),
            title: 'Payment Received',
            subtitle: 'Yonex Racket • Today, 10:30 AM',
            trailing: '+ Rs. 800',
            trailingColor: const Color(0xFF3BB85A),
          ),

          const Divider(
            height: 1,
            indent: 58,
          ),

          _activityRow(
            icon: Icons.schedule,
            iconBackground: const Color(0xFFFFF2DF),
            iconColor: Colors.orange,
            title: 'Rented Out',
            subtitle: 'SS Cricket Bat • Yesterday',
            trailing: 'Ongoing',
            trailingColor: Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _activityRow({
    required IconData icon,
    required Color iconBackground,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String trailing,
    required Color trailingColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 15,
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: textGrey,
                  ),
                ),
              ],
            ),
          ),

          Text(
            trailing,
            style: TextStyle(
              color: trailingColor,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _earningItemCard({
    required IconData icon,
    required String itemName,
    required String earned,
    required String rented,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: SizedBox(
              height: 100,
              child: Icon(
                icon,
                size: 85,
                color: Colors.black87,
              ),
            ),
          ),

          const SizedBox(height: 10),

          Text(
            itemName,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            'Earned: $earned',
            style: const TextStyle(
              color: primaryRed,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            rented,
            style: const TextStyle(
              color: textGrey,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
  return Container(
    height: 75,
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(
        top: BorderSide(
          color: Color(0xFFE8E8E8),
        ),
      ),
    ),
    child: const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 420,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _BottomNavItem(
                icon: Icons.grid_view_rounded,
                label: 'Dashboard',
                active: true,
              ),
              _BottomNavItem(
                icon: Icons.hexagon_outlined,
                label: 'My Items',
              ),
              _BottomNavItem(
                icon: Icons.shopping_bag_outlined,
                label: 'Requests',
              ),
              _BottomNavItem(
                icon: Icons.chat_bubble_outline,
                label: 'Messages',
              ),
              _BottomNavItem(
                icon: Icons.person_outline,
                label: 'Profile',
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

  void _showComingSoon(BuildContext context, String page) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$page screen will be connected next.'),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;

  const _BottomNavItem({
    required this.icon,
    required this.label,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    const red = Color(0xFFE00122);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: active ? red : Colors.grey,
          size: 24,
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            color: active ? red : Colors.grey,
            fontWeight: active
                ? FontWeight.w700
                : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}