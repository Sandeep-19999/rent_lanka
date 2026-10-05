import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'availability_screen.dart';
import 'edit_listing_screen.dart';

class ListingDetailsScreen extends StatelessWidget {
  final String equipmentId;

  const ListingDetailsScreen({super.key, required this.equipmentId});

  static const Color primaryRed = Color(0xFFED1235);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('equipment')
                  .doc(equipmentId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text(
                      'Something went wrong.',
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: primaryRed),
                  );
                }

                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Center(child: Text('Equipment not found.'));
                }

                final data = snapshot.data!.data() as Map<String, dynamic>;

                final String name = data['name']?.toString() ?? 'Equipment';

                final String category = data['category']?.toString() ?? '';

                final String brand = data['brand']?.toString() ?? '';

                final String size = data['size']?.toString() ?? '';

                final String condition = data['condition']?.toString() ?? '';

                final String status = data['status']?.toString() ?? 'Available';

                final priceValue = data['pricePerDay'];

                final double price = priceValue is num
                    ? priceValue.toDouble()
                    : 0;

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
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
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      // Equipment image placeholder
                      Container(
                        width: double.infinity,
                        height: 190,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Icon(
                          _getCategoryIcon(category),
                          size: 80,
                          color: Colors.black54,
                        ),
                      ),

                      const SizedBox(height: 22),

                      // Name + Status
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEAF8EF),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              status,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF27944A),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'Rs. ${_formatPrice(price)}/day',
                        style: const TextStyle(
                          fontSize: 20,
                          color: primaryRed,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 25),

                      const Text(
                        'Equipment Details',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 12),

                      _detailCard(
                        icon: Icons.sports,
                        title: 'Category',
                        value: category.isEmpty ? 'Not specified' : category,
                      ),

                      const SizedBox(height: 10),

                      _detailCard(
                        icon: Icons.sell_outlined,
                        title: 'Brand',
                        value: brand.isEmpty ? 'Not specified' : brand,
                      ),

                      const SizedBox(height: 10),

                      _detailCard(
                        icon: Icons.straighten,
                        title: 'Size',
                        value: size.isEmpty ? 'Not specified' : size,
                      ),

                      const SizedBox(height: 10),

                      _detailCard(
                        icon: Icons.verified_outlined,
                        title: 'Condition',
                        value: condition.isEmpty ? 'Not specified' : condition,
                      ),

                      const SizedBox(height: 28),

                      const Text(
                        'Availability',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Availability
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  AvailabilityScreen(equipmentId: equipmentId),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFE0E0E0)),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.calendar_month_outlined,
                                color: primaryRed,
                              ),

                              SizedBox(width: 13),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Manage Availability',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    SizedBox(height: 3),
                                    Text(
                                      'Block or allow rental dates',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Icon(
                                Icons.arrow_forward_ios,
                                size: 15,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      // Edit
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    EditListingScreen(equipmentId: equipmentId),
                              ),
                            );
                          },
                          icon: const Icon(Icons.edit_outlined),
                          label: const Text('Edit Listing'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryRed,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Delete
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            _showDeleteDialog(context);
                          },
                          icon: const Icon(Icons.delete_outline),
                          label: const Text('Delete Listing'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: primaryRed,
                            side: const BorderSide(color: primaryRed),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E5E5)),
      ),
      child: Row(
        children: [
          Icon(icon, color: primaryRed, size: 22),

          const SizedBox(width: 14),

          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ),

          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete listing?'),
          content: const Text(
            'Are you sure you want to delete this equipment listing?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),

            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);

                try {
                  await FirebaseFirestore.instance
                      .collection('equipment')
                      .doc(equipmentId)
                      .delete();

                  if (!context.mounted) {
                    return;
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Listing deleted successfully'),
                    ),
                  );

                  Navigator.pop(context);
                } catch (error) {
                  if (!context.mounted) {
                    return;
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete listing: $error')),
                  );
                }
              },
              child: const Text('Delete', style: TextStyle(color: primaryRed)),
            ),
          ],
        );
      },
    );
  }

  static String _formatPrice(double price) {
    if (price == price.roundToDouble()) {
      return price.toInt().toString();
    }

    return price.toStringAsFixed(2);
  }

  static IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'cricket':
        return Icons.sports_cricket;

      case 'football':
        return Icons.sports_soccer;

      case 'tennis':
        return Icons.sports_tennis;

      case 'cycling':
        return Icons.pedal_bike;

      case 'volleyball':
        return Icons.sports_volleyball;

      case 'hockey':
        return Icons.sports_hockey;

      default:
        return Icons.sports;
    }
  }
}
