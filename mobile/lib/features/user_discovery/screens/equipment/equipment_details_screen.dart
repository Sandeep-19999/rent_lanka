
import 'package:flutter/material.dart';

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

  bool _isFavourite = false;

  String get _name =>
      widget.equipment['name']?.toString() ?? 'Equipment';

  String get _price =>
      widget.equipment['priceText']?.toString() ??
      widget.equipment['price']?.toString() ??
      'Price unavailable';

  String get _condition =>
      widget.equipment['condition']?.toString() ?? 'Good';

  String get _size =>
      widget.equipment['size']?.toString() ?? 'Standard';

  String get _rating =>
      widget.equipment['rating']?.toString() ?? '4.8';

  String get _owner =>
      widget.equipment['owner']?.toString() ??
      'Kamal Sports Gear';

  String get _description =>
      widget.equipment['description']?.toString() ??
      'Well-maintained sports equipment suitable for '
          'training and recreational activities. '
          'Contact the equipment owner for more details.';

  IconData get _equipmentIcon =>
      widget.equipment['icon'] is IconData
          ? widget.equipment['icon'] as IconData
          : Icons.sports_cricket;

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$feature will be connected during module integration.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        _buildEquipmentImage(),
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(
                            20,
                            18,
                            20,
                            24,
                          ),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              _buildNameAndPrice(),
                              const SizedBox(height: 15),
                              _buildRating(),
                              const SizedBox(height: 18),
                              _buildProviderCard(),
                              const SizedBox(height: 22),
                              const Text(
                                'Description',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight:
                                      FontWeight.w800,
                                  color: darkText,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                _description,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color:
                                      Color(0xFF888888),
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
                _buildBottomButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEquipmentImage() {
    return Container(
      height: 340,
      width: double.infinity,
      color: const Color(0xFFFAFAFA),
      child: Stack(
        children: [
          Center(
            child: Icon(
              _equipmentIcon,
              size: 155,
              color: const Color(0xFF707070),
            ),
          ),
          Positioned(
            top: 16,
            left: 14,
            child: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
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
            child: IconButton(
              onPressed: () {
                setState(() {
                  _isFavourite = !_isFavourite;
                });
              },
              icon: Icon(
                _isFavourite
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                color: _isFavourite
                    ? primaryRed
                    : darkText,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameAndPrice() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                _name,
                style: const TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                  color: darkText,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Size: $_size | $_condition Condition',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF888888),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Text(
          _price,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: primaryRed,
          ),
        ),
      ],
    );
  }

  Widget _buildRating() {
    return Row(
      children: [
        const Text(
          'Rate this equipment',
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
                _rating,
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

  Widget _buildProviderCard() {
    return InkWell(
      onTap: () {
        _showComingSoon('Provider profile');
      },
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
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    _owner,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: darkText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Row(
                    children: [
                      Icon(
                        Icons.verified_rounded,
                        size: 13,
                        color: primaryRed,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Owner profile',
                        style: TextStyle(
                          fontSize: 11,
                          color: primaryRed,
                        ),
                      ),
                    ],
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

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        18,
        14,
        18,
        18,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Color(0xFFEEEEEE),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 52,
              child: OutlinedButton(
                onPressed: () {
                  _showComingSoon('Exchange request');
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryRed,
                  side: const BorderSide(
                    color: primaryRed,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(10),
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
                onPressed: () {
                  _showComingSoon('Equipment booking');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryRed,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Book Equipment',
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
