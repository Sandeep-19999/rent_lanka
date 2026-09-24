import 'package:flutter/material.dart';
import 'add_equipment_screen.dart';
import 'listing_details_screen.dart';

class MyListingsScreen extends StatelessWidget {
  const MyListingsScreen({super.key});

  static const Color primaryRed = Color(0xFFED1235);
  static const Color backgroundColor = Color(0xFFF8F8FA);
  static const Color textGrey = Color(0xFF8A8A8A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          size: 22,
                        ),
                      ),

                      const SizedBox(width: 14),

                      const Expanded(
                        child: Text(
                          'My Equipment',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      ),

                      SizedBox(
                        height: 38,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const AddEquipmentScreen(),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.add,
                            size: 17,
                          ),
                          label: const Text(
                            'Add New',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryRed,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 26),

                  // Equipment list
                  Expanded(
                    child: ListView(
                      children: [
                        _equipmentCard(
                          context: context,
                          icon: Icons.sports_cricket,
                          name: 'SS Cricket Bat',
                          price: 'Rs. 1,200 / day',
                          status: 'Available',
                          statusColor: const Color(0xFF3EAF5B),
                          statusBackground: const Color(0xFFE8F7EC),
                        ),

                        const SizedBox(height: 14),

                        _equipmentCard(
                          context: context,
                          icon: Icons.sports_tennis,
                          name: 'Yonex Racket',
                          price: 'Rs. 800 / day',
                          status: 'Rented',
                          statusColor: Colors.orange,
                          statusBackground: const Color(0xFFFFF1DE),
                        ),

                        const SizedBox(height: 14),

                        _equipmentCard(
                          context: context,
                          icon: Icons.sports_cricket_outlined,
                          name: 'Cricket Gloves',
                          price: 'Rs. 900 / day',
                          status: 'Excellent',
                          statusColor: const Color(0xFF555555),
                          statusBackground: const Color(0xFFF0F0F2),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      bottomNavigationBar: _buildBottomNavigation(context),
    );
  }

  Widget _equipmentCard({
    required BuildContext context,
    required IconData icon,
    required String name,
    required String price,
    required String status,
    required Color statusColor,
    required Color statusBackground,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const ListingDetailsScreen(),
    ),
  );
},
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFE5E5E5),
            ),
          ),
          child: Row(
            children: [
              // Equipment image placeholder
              Container(
                width: 82,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F7F8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 48,
                  color: const Color(0xFF555555),
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      price,
                      style: const TextStyle(
                        fontSize: 14,
                        color: textGrey,
                      ),
                    ),

                    const SizedBox(height: 7),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusBackground,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.chevron_right,
                color: Color(0xFFAAAAAA),
                size: 25,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigation(BuildContext context) {
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
      child: Center(
        child: SizedBox(
          width: 420,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _BottomNavItem(
                icon: Icons.grid_view_rounded,
                label: 'Dashboard',
                onTap: () {
                  Navigator.pop(context);
                },
              ),

              const _BottomNavItem(
                icon: Icons.hexagon_outlined,
                label: 'My Items',
                active: true,
              ),

              const _BottomNavItem(
                icon: Icons.shopping_bag_outlined,
                label: 'Requests',
              ),

              const _BottomNavItem(
                icon: Icons.chat_bubble_outline,
                label: 'Messages',
              ),

              const _BottomNavItem(
                icon: Icons.person_outline,
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback? onTap;

  const _BottomNavItem({
    required this.icon,
    required this.label,
    this.active = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const red = Color(0xFFED1235);

    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: 65,
        height: 65,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24,
              color: active ? red : Colors.grey,
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                color: active ? red : Colors.grey,
                fontWeight:
                    active ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}