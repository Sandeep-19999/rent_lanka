
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:rent_lanka_mobile/features/user_discovery/services/favourite_service.dart';
import '../provider/public_provider_screen.dart';
import 'package:rent_lanka_mobile/features/exchange_messaging_profile/screens/exchange_request_screen.dart';
import 'package:rent_lanka_mobile/features/booking_payment/models/equipment_model.dart' as booking;
import 'package:rent_lanka_mobile/features/booking_payment/screens/booking/booking_screen.dart';

class EquipmentDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> equipment;

  const EquipmentDetailsScreen({
    super.key,
    required this.equipment,
  });

  @override
  State<EquipmentDetailsScreen> createState() =>
      _EquipmentDetailsScreenState();
}

class _EquipmentDetailsScreenState
    extends State<EquipmentDetailsScreen> {
  static const Color primaryRed = Color(0xFFED1C24);
  static const Color darkText = Color(0xFF171717);

  final FavouriteService _favouriteService = FavouriteService();

  bool _isSavingFavourite = false;

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

  String _price(Map<String, dynamic> data) {
    final rawPrice = data['pricePerDay'];

    if (rawPrice is num) {
      final formatted = rawPrice.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (match) => ',',
      );

      return 'Rs. $formatted/day';
    }

    return _text(
      data,
      'priceText',
      _text(data, 'price', 'Price unavailable'),
    );
  }

  bool _isAvailable(Map<String, dynamic> data) {
    if (data['isAvailable'] is bool) {
      return data['isAvailable'] as bool;
    }

    final status = _text(data, 'status').toLowerCase();

    return status == 'available';
  }

  IconData _equipmentIcon(Map<String, dynamic> data) {
    if (data['icon'] is IconData) {
      return data['icon'] as IconData;
    }

    switch (_text(data, 'category').toLowerCase()) {
      case 'cricket':
        return Icons.sports_cricket;
      case 'football':
        return Icons.sports_soccer;
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

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _requestExchange(Map<String, dynamic> equipment) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showMessage('Please log in to request an exchange.');
      return;
    }

    final equipmentId = _text(equipment, 'id');
    final equipmentName = _text(equipment, 'name');
    final providerId = _text(equipment, 'providerId');
    if (equipmentId.isEmpty || equipmentName.isEmpty || providerId.isEmpty) {
      _showMessage('Equipment information is incomplete. Please refresh the listing.');
      return;
    }
    if (providerId == user.uid) {
      _showMessage('You cannot request an exchange for your own equipment.');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ExchangeRequestScreen(
          requestedEquipmentId: equipmentId,
          requestedEquipmentName: equipmentName,
          requestedProviderId: providerId,
        ),
      ),
    );
  }

  void _bookEquipment(Map<String, dynamic> data) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showMessage('Please log in to book equipment.');
      return;
    }
    try {
      final equipment = booking.Equipment.fromDiscovery(data);
      if (equipment.providerId == user.uid) {
        _showMessage('You cannot book your own equipment.');
        return;
      }
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => BookingScreen(equipment: equipment)),
      );
    } on FormatException catch (error) {
      _showMessage(error.message);
    }
  }

  Future<void> _toggleFavourite(
    String equipmentId,
    bool currentlyFavourite,
  ) async {
    if (_isSavingFavourite) return;

    if (FirebaseAuth.instance.currentUser == null) {
      _showMessage('Please log in to save favourites.');
      return;
    }

    if (equipmentId.isEmpty) {
      _showMessage('Unable to save: equipment ID is missing.');
      return;
    }

    setState(() {
      _isSavingFavourite = true;
    });

    try {
      await _favouriteService.toggleFavourite(
        equipmentId,
        currentlyFavourite,
      );

      _showMessage(
        currentlyFavourite
            ? 'Removed from favourites'
            : 'Added to favourites',
      );
    } catch (error) {
      _showMessage(
        'Unable to update favourites. Check your connection and permissions.',
      );
      debugPrint('Favourite update failed: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isSavingFavourite = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final equipmentId = _text(widget.equipment, 'id');

    if (equipmentId.isEmpty) {
      return _buildPage(widget.equipment);
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('equipment')
          .doc(equipmentId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildPage(
            widget.equipment,
            notice: 'Unable to refresh equipment details.',
          );
        }

        if (snapshot.hasData && !snapshot.data!.exists) {
          return _buildPage(
            widget.equipment,
            notice: 'This equipment listing is no longer available.',
            listingUnavailable: true,
          );
        }

        final liveData = snapshot.data?.data();

        final equipment = <String, dynamic>{
          ...widget.equipment,
          if (liveData != null) ...liveData,
          'id': equipmentId,
        };

        return _buildPage(
          equipment,
          isRefreshing:
              snapshot.connectionState == ConnectionState.waiting,
        );
      },
    );
  }

  Widget _buildPage(
    Map<String, dynamic> equipment, {
    String? notice,
    bool isRefreshing = false,
    bool listingUnavailable = false,
  }) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              children: [
                if (isRefreshing)
                  const LinearProgressIndicator(
                    color: primaryRed,
                    minHeight: 2,
                  ),
                if (notice != null)
                  Container(
                    width: double.infinity,
                    color: const Color(0xFFFFF4E5),
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      notice,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildEquipmentImage(equipment),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            20,
                            18,
                            20,
                            24,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildNameAndPrice(equipment),
                              const SizedBox(height: 14),
                              _buildAvailability(equipment),
                              const SizedBox(height: 15),
                              _buildRating(equipment),
                              const SizedBox(height: 18),
                              _buildProviderCard(equipment),
                              const SizedBox(height: 22),
                              const Text(
                                'Description',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: darkText,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                _text(
                                  equipment,
                                  'description',
                                  'No description provided.',
                                ),
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF888888),
                                  height: 1.6,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                _buildBottomButtons(
                  equipment,
                  listingUnavailable: listingUnavailable,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEquipmentImage(
    Map<String, dynamic> equipment,
  ) {
    final imageUrl = _text(equipment, 'imageUrl');
    final equipmentId = _text(equipment, 'id');

    final hasImage = imageUrl.startsWith('https://') ||
        imageUrl.startsWith('http://');

    return Container(
      height: 340,
      width: double.infinity,
      color: const Color(0xFFFAFAFA),
      child: Stack(
        children: [
          Positioned.fill(
            child: hasImage
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (_, error, stackTrace) {
                      return _buildImagePlaceholder(equipment);
                    },
                  )
                : _buildImagePlaceholder(equipment),
          ),
          Positioned(
            top: 16,
            left: 14,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 21,
                color: darkText,
              ),
            ),
          ),
          Positioned(
            top: 16,
            right: 14,
            child: _buildFavouriteButton(equipmentId),
          ),
        ],
      ),
    );
  }

  Widget _buildFavouriteButton(String equipmentId) {
    if (equipmentId.isEmpty) {
      return const IconButton(
        onPressed: null,
        icon: Icon(Icons.favorite_border_rounded),
        tooltip: 'Equipment ID unavailable',
      );
    }

    if (FirebaseAuth.instance.currentUser == null) {
      return IconButton(
        tooltip: 'Log in to save favourites',
        onPressed: () {
          _showMessage('Please log in to save favourites.');
        },
        icon: const Icon(
          Icons.favorite_border_rounded,
          color: darkText,
          size: 24,
        ),
      );
    }

    return StreamBuilder<bool>(
      stream: _favouriteService.isFavourite(equipmentId),
      builder: (context, snapshot) {
        final isFavourite = snapshot.data ?? false;

        if (snapshot.hasError) {
          return IconButton(
            tooltip: 'Unable to load favourite status',
            onPressed: () {
              _showMessage(
                'Unable to load favourites. Check Firestore permissions.',
              );
            },
            icon: const Icon(
              Icons.favorite_border_rounded,
              color: Colors.grey,
              size: 24,
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            width: 48,
            height: 48,
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: primaryRed,
                ),
              ),
            ),
          );
        }

        return IconButton(
          tooltip: isFavourite
              ? 'Remove from favourites'
              : 'Add to favourites',
          onPressed: _isSavingFavourite
              ? null
              : () => _toggleFavourite(
                    equipmentId,
                    isFavourite,
                  ),
          icon: _isSavingFavourite
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: primaryRed,
                  ),
                )
              : Icon(
                  isFavourite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: isFavourite ? primaryRed : darkText,
                  size: 24,
                ),
        );
      },
    );
  }

  Widget _buildImagePlaceholder(
    Map<String, dynamic> equipment,
  ) {
    return Center(
      child: Icon(
        _equipmentIcon(equipment),
        size: 155,
        color: const Color(0xFF707070),
      ),
    );
  }

  Widget _buildNameAndPrice(
    Map<String, dynamic> equipment,
  ) {
    final name = _text(equipment, 'name', 'Equipment');
    final brand = _text(equipment, 'brand');
    final size = _text(equipment, 'size', 'Not specified');
    final condition = _text(
      equipment,
      'condition',
      'Not specified',
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                  color: darkText,
                ),
              ),
              if (brand.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  'Brand: $brand',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF777777),
                  ),
                ),
              ],
              const SizedBox(height: 5),
              Text(
                'Size: $size | $condition Condition',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF888888),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            _price(equipment),
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: primaryRed,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvailability(
    Map<String, dynamic> equipment,
  ) {
    final available = _isAvailable(equipment);

    return Row(
      children: [
        Icon(
          available
              ? Icons.check_circle_outline
              : Icons.cancel_outlined,
          size: 17,
          color: available ? Colors.green : primaryRed,
        ),
        const SizedBox(width: 6),
        Text(
          available ? 'Available' : 'Currently unavailable',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: available ? Colors.green : primaryRed,
          ),
        ),
      ],
    );
  }

  Widget _buildRating(Map<String, dynamic> equipment) {
    final id = _text(equipment, 'id');
    if (id.isEmpty) return _ratingRow(equipment);
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('reviews')
          .where('equipmentId', isEqualTo: id).snapshots(),
      builder: (context, snapshot) {
        final ratings = snapshot.data?.docs.map((doc) => doc.data()['rating'])
            .whereType<num>().where((value) => value >= 1 && value <= 5).toList() ?? [];
        return _ratingRow({ ...equipment,
          'rating': ratings.isEmpty ? 'N/A' :
              (ratings.fold<double>(0, (total, value) => total + value) / ratings.length).toStringAsFixed(1),
          'reviews': ratings.length.toString(),
        });
      },
    );
  }

  Widget _ratingRow(Map<String, dynamic> equipment) {
    final rating = _text(equipment, 'rating', 'N/A');

    return Row(
      children: [
        const Text(
          'Equipment rating',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: darkText,
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 9,
            vertical: 5,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF4E5),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.star_rounded,
                color: Color(0xFFFFA000),
                size: 16,
              ),
              const SizedBox(width: 3),
              Text(
                rating,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFFE99700),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProviderCard(
    Map<String, dynamic> equipment,
  ) {
    final providerId = _text(equipment, 'providerId');

    if (providerId.isEmpty) {
      return _providerTile(
        'Provider information unavailable',
      );
    }

    return StreamBuilder<
        DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(providerId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _providerTile('Equipment Provider', providerId: providerId);
        }

        final userData = snapshot.data?.data();

        if (userData == null) {
          return _providerTile('Equipment Provider', providerId: providerId);
        }

        String providerName = _text(userData, 'name');

        if (providerName.isEmpty) {
          providerName = _text(userData, 'fullName');
        }

        if (providerName.isEmpty) {
          providerName = _text(userData, 'displayName');
        }

        if (providerName.isEmpty) {
          providerName = 'Equipment Provider';
        }

        return _providerTile(providerName, providerId: providerId);
      },
    );
  }

  Widget _providerTile(String providerName, {String providerId = ''}) {
    return InkWell(
      onTap: providerId.isEmpty
          ? () => _showMessage('Provider information unavailable.')
          : () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => PublicProviderScreen(providerId: providerId),
                ),
              ),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFECECEC),
          ),
        ),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 23,
              backgroundColor: Color(0xFFFFE8D8),
              child: Icon(
                Icons.person_rounded,
                color: Color(0xFF8A5135),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    providerName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: darkText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Equipment provider',
                    style: TextStyle(
                      fontSize: 11,
                      color: primaryRed,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_rounded,
              color: Color(0xFF999999),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButtons(
    Map<String, dynamic> equipment, {
    bool listingUnavailable = false,
  }) {
    final available =
        _isAvailable(equipment) && !listingUnavailable;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFEEEEEE)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 52,
              child: OutlinedButton(
                onPressed: available
                    ? () => _requestExchange(equipment)
                    : null,
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryRed,
                  side: const BorderSide(color: primaryRed),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Request Exchange',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: available
                    ? () => _bookEquipment(equipment)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryRed,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Book Now',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
