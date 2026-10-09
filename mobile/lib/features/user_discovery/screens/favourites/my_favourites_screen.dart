import 'package:rent_lanka_mobile/features/provider/services/cloudinary_service.dart';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../services/favourite_service.dart';
import '../equipment/equipment_details_screen.dart';

class MyFavouritesScreen extends StatefulWidget {
  const MyFavouritesScreen({super.key});

  @override
  State<MyFavouritesScreen> createState() =>
      _MyFavouritesScreenState();
}

class _MyFavouritesScreenState extends State<MyFavouritesScreen> {
  static const Color primaryRed = Color(0xFFED1C24);
  static const Color darkText = Color(0xFF171717);

  final FavouriteService _favouriteService = FavouriteService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late final Stream<List<String>> _favouritesStream;
  final Set<String> _removingIds = {};

  @override
  void initState() {
    super.initState();
    _favouritesStream = _favouriteService.getFavouriteEquipmentIds();
  }

  Future<void> _removeFavourite(String equipmentId) async {
    if (_removingIds.contains(equipmentId)) return;

    setState(() {
      _removingIds.add(equipmentId);
    });

    try {
      await _favouriteService.removeFavourite(equipmentId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Removed from favourites'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to remove favourite. Please try again.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );

      debugPrint('Remove favourite error: $error');
    } finally {
      if (mounted) {
        setState(() {
          _removingIds.remove(equipmentId);
        });
      }
    }
  }

  String _text(
    Map<String, dynamic> data,
    String key, [
    String fallback = '',
  ]) {
    final value = data[key];

    if (value == null) return fallback;

    final result = value.toString().trim();
    return result.isEmpty ? fallback : result;
  }

  String _formatPrice(Map<String, dynamic> equipment) {
    final price = equipment['pricePerDay'];

    if (price is num) {
      final formatted = price.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (match) => ',',
      );

      return 'Rs. $formatted/day';
    }

    return 'Price unavailable';
  }

  bool _isAvailable(Map<String, dynamic> equipment) {
    if (equipment['isAvailable'] is bool) {
      return equipment['isAvailable'] as bool;
    }

    return _text(equipment, 'status').toLowerCase() == 'available';
  }

  IconData _categoryIcon(Map<String, dynamic> equipment) {
    switch (_text(equipment, 'category').toLowerCase()) {
      case 'football':
        return Icons.sports_soccer;
      case 'cricket':
        return Icons.sports_cricket;
      case 'volleyball':
        return Icons.sports_volleyball;
      case 'cycling':
        return Icons.pedal_bike;
      case 'swimming':
        return Icons.pool;
      case 'hockey':
        return Icons.sports_hockey;
      default:
        return Icons.sports;
    }
  }

  void _openEquipmentDetails(
    String equipmentId,
    Map<String, dynamic> equipment,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EquipmentDetailsScreen(
          equipment: {
            ...equipment,
            'id': equipmentId,
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF0F1),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        foregroundColor: darkText,
        title: const Text(
          'My Favourites',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 19,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 18),
            child: Icon(
              Icons.favorite_rounded,
              color: primaryRed,
            ),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: StreamBuilder<List<String>>(
            stream: _favouritesStream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return _buildMessage(
                  Icons.error_outline,
                  'Unable to load favourites',
                  'Check your internet connection and Firestore permissions.',
                );
              }

              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: primaryRed,
                  ),
                );
              }

              final equipmentIds = snapshot.data!;

              if (equipmentIds.isEmpty) {
                return _buildMessage(
                  Icons.favorite_border_rounded,
                  'No favourites yet',
                  'Tap the heart icon on equipment to save it here.',
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: equipmentIds.length,
                itemBuilder: (context, index) {
                  final equipmentId = equipmentIds[index];

                  return _buildFavouriteItem(equipmentId);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFavouriteItem(String equipmentId) {
    return StreamBuilder<
        DocumentSnapshot<Map<String, dynamic>>>(
      stream: _firestore
          .collection('equipment')
          .doc(equipmentId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildUnavailableCard(
            equipmentId,
            'Unable to load equipment',
          );
        }

        if (!snapshot.hasData) {
          return const Card(
            margin: EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: EdgeInsets.all(22),
              child: Center(
                child: CircularProgressIndicator(
                  color: primaryRed,
                  strokeWidth: 2,
                ),
              ),
            ),
          );
        }

        if (!snapshot.data!.exists) {
          return _buildUnavailableCard(
            equipmentId,
            'Equipment listing no longer exists',
          );
        }

        final equipment = snapshot.data!.data() ?? {};

        final name = _text(equipment, 'name', 'Equipment');
        final imageUrl = _text(equipment, 'imageUrl');
        final available = _isAvailable(equipment);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: const BorderSide(
              color: Color(0xFFEEEEEE),
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(15),
            onTap: () => _openEquipmentDetails(
              equipmentId,
              equipment,
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    width: 95,
                    height: 100,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F7F7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: imageUrl.startsWith('http://') ||
                            imageUrl.startsWith('https://')
                        ? Image.network(
                            equipmentThumbnailUrl(imageUrl),
                            fit: BoxFit.cover,
                            errorBuilder: (_, error, stackTrace) {
                              return Icon(
                                _categoryIcon(equipment),
                                size: 48,
                                color: Colors.grey,
                              );
                            },
                          )
                        : Icon(
                            _categoryIcon(equipment),
                            size: 48,
                            color: Colors.grey,
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: darkText,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _formatPrice(equipment),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: primaryRed,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              available
                                  ? Icons.check_circle_outline
                                  : Icons.cancel_outlined,
                              color: available
                                  ? Colors.green
                                  : primaryRed,
                              size: 15,
                            ),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                available
                                    ? 'Available'
                                    : 'Unavailable',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: available
                                      ? Colors.green
                                      : primaryRed,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Remove from favourites',
                    onPressed: _removingIds.contains(equipmentId)
                        ? null
                        : () => _removeFavourite(equipmentId),
                    icon: _removingIds.contains(equipmentId)
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: primaryRed,
                            ),
                          )
                        : const Icon(
                            Icons.favorite_rounded,
                            color: primaryRed,
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildUnavailableCard(
    String equipmentId,
    String message,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const Icon(
          Icons.inventory_2_outlined,
          color: Colors.grey,
        ),
        title: Text(message),
        subtitle: const Text('You can remove this favourite.'),
        trailing: IconButton(
          onPressed: _removingIds.contains(equipmentId)
              ? null
              : () => _removeFavourite(equipmentId),
          icon: const Icon(
            Icons.favorite_rounded,
            color: primaryRed,
          ),
        ),
      ),
    );
  }

  Widget _buildMessage(
    IconData icon,
    String title,
    String subtitle,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 64,
              color: const Color(0xFFBBBBBB),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: darkText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF888888),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
