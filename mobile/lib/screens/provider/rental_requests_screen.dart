import 'package:flutter/material.dart';

class RentalRequestsScreen extends StatelessWidget {
  const RentalRequestsScreen({super.key});

  static const Color primaryRed = Color(0xFFED1235);
  static const Color textGrey = Color(0xFF8A8A8A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

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

                      const Text(
                        'Rental Requests',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Request Card
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFFDDDDDD),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Top section
                        Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              const CircleAvatar(
                                radius: 20,
                                backgroundColor: Color(0xFFEAEAEA),
                                child: Icon(
                                  Icons.person,
                                  color: Colors.black54,
                                ),
                              ),

                              const SizedBox(width: 12),

                              const Expanded(
                                child: Text(
                                  'Pushpa V.',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),

                              const Text(
                                '2 hours ago',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: textGrey,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Divider(
                          height: 1,
                          color: Color(0xFFE5E5E5),
                        ),

                        // Details
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            14,
                            14,
                            14,
                            12,
                          ),
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              'Requested: ',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: textGrey,
                                              ),
                                            ),
                                            Text(
                                              'SS Cricket Bat',
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                          ],
                                        ),

                                        SizedBox(height: 10),

                                        Row(
                                          children: [
                                            SizedBox(
                                              width: 78,
                                              child: Text(
                                                'Dates:',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: textGrey,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              '12 Sep - 18 Sep',
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(width: 10),

                                  const Text(
                                    'Rs. 8,400',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      color: primaryRed,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 20),

                              Row(
                                children: [
                                  Expanded(
                                    child: SizedBox(
                                      height: 48,
                                      child: OutlinedButton(
                                        onPressed: () {
                                          _showRejectDialog(context);
                                        },
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.black,
                                          side: const BorderSide(
                                            color: Color(0xFFDADADA),
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: const Text(
                                          'Reject',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 14),

                                  Expanded(
                                    child: SizedBox(
                                      height: 48,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Rental request accepted',
                                              ),
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: primaryRed,
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: const Text(
                                          'Accept',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
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
                ],
              ),
            ),
          ),
        ),
      ),

      bottomNavigationBar: _buildBottomNavigation(context),
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
              ),

              const _BottomNavItem(
                icon: Icons.shopping_bag_outlined,
                label: 'Requests',
                active: true,
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

  void _showRejectDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reject request?'),
          content: const Text(
            'Are you sure you want to reject this rental request?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),

            TextButton(
              onPressed: () {
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Rental request rejected'),
                  ),
                );
              },
              child: const Text(
                'Reject',
                style: TextStyle(
                  color: primaryRed,
                ),
              ),
            ),
          ],
        );
      },
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