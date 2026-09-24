import 'package:flutter/material.dart';

class ListingDetailsScreen extends StatelessWidget {
  const ListingDetailsScreen({super.key});

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
                        'Listing Details',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // Equipment card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: const Color(0xFFDADADA),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7F7F8),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.sports_cricket,
                            size: 48,
                            color: Color(0xFF333333),
                          ),
                        ),

                        const SizedBox(width: 18),

                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Cricket Bat',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Rs. 1,200/day • Good condition',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: textGrey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Availability',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Manage availability
                  InkWell(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Availability screen will be connected next.',
                          ),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 18,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFDADADA),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Manage availability',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            size: 28,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Edit listing
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Edit listing will be added later.',
                            ),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black,
                        side: const BorderSide(
                          color: Color(0xFFDADADA),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Edit listing',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Delete listing
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: () {
                        _showDeleteDialog(context);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: primaryRed,
                        backgroundColor: const Color(0xFFFFF4F5),
                        side: const BorderSide(
                          color: primaryRed,
                          width: 1.4,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Delete listing',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete listing?'),
          content: const Text(
            'Are you sure you want to delete this equipment listing?',
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
                    content: Text('Listing deleted'),
                  ),
                );
              },
              child: const Text(
                'Delete',
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