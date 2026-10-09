import 'package:rent_lanka_mobile/features/provider/services/cloudinary_service.dart';

import 'package:flutter/material.dart';

import 'package:rent_lanka_mobile/features/user_discovery/models/equipment_model.dart';
import 'package:rent_lanka_mobile/features/user_discovery/services/equipment_service.dart';
import 'package:rent_lanka_mobile/features/user_discovery/screens/equipment/equipment_details_screen.dart';
import 'package:rent_lanka_mobile/features/user_discovery/widgets/search_filter_sheet.dart';

class CategoryEquipmentScreen extends StatefulWidget {
  final String category;

  const CategoryEquipmentScreen({
    super.key,
    required this.category,
  });

  @override
  State<CategoryEquipmentScreen> createState() =>
      _CategoryEquipmentScreenState();
}

class _CategoryEquipmentScreenState
    extends State<CategoryEquipmentScreen> {
  static const Color primaryRed = Color(0xFFED1C24);
  static const Color darkText = Color(0xFF171717);

  final TextEditingController _searchController =
      TextEditingController();

  final EquipmentService _equipmentService = EquipmentService();

  late Stream<List<EquipmentModel>> _equipmentStream;

  SearchFilterResult? _currentFilter;

  @override
  void initState() {
    super.initState();

    _equipmentStream =
        _equipmentService.getEquipmentByCategory(widget.category);
  }

  @override
  void didUpdateWidget(covariant CategoryEquipmentScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.category != widget.category) {
      _equipmentStream =
          _equipmentService.getEquipmentByCategory(widget.category);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  IconData _getEquipmentIcon(String category) {
    switch (category.toLowerCase()) {
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

  String _formatPrice(double price) {
    final value = price.toStringAsFixed(0);

    final formatted = value.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );

    return 'Rs. $formatted/day';
  }

  Map<String, dynamic> _equipmentToMap(EquipmentModel equipment) {
    return {
      'id': equipment.id,
      'name': equipment.name,
      'category': equipment.category,
      'brand': equipment.brand,
      'price': _formatPrice(equipment.pricePerDay),
      'priceText': _formatPrice(equipment.pricePerDay),
      'pricePerDay': equipment.pricePerDay,
      'condition': equipment.condition,
      'size': equipment.size,
      'imageUrl': equipment.imageUrl,
      'providerId': equipment.providerId,
      'owner': 'Equipment Provider',
      'rating': 'N/A',
      'reviews': '0',
      'description': '',
      'icon': _getEquipmentIcon(equipment.category),
      'isAvailable': equipment.isAvailable,
      'status': equipment.status,
      'unavailableDates': equipment.unavailableDates,
    };
  }

  List<EquipmentModel> _applyFilters(
    List<EquipmentModel> equipmentList,
  ) {
    final query = _searchController.text.trim().toLowerCase();

    return equipmentList.where((equipment) {
      if (query.isNotEmpty) {
        final searchableText =
            '${equipment.name} ${equipment.category} ${equipment.brand}'
                .toLowerCase();

        if (!searchableText.contains(query)) {
          return false;
        }
      }

      final filter = _currentFilter;

      if (filter == null) return true;

      if (filter.category != 'Any' &&
          equipment.category.toLowerCase() !=
              filter.category.toLowerCase()) {
        return false;
      }

      if (equipment.pricePerDay > filter.maxPrice) {
        return false;
      }

      if (filter.condition != 'Any' &&
          equipment.condition.toLowerCase() !=
              filter.condition.toLowerCase()) {
        return false;
      }

      if (filter.size != 'Any' &&
          equipment.size.toLowerCase() !=
              filter.size.toLowerCase()) {
        return false;
      }

      // Firestore equipment documents currently do not contain
      // location or transactionType fields.
      // Avoid assuming missing values are real data.
      if (filter.location != 'Any') {
        return false;
      }

      // Current Firestore records use pricePerDay, indicating
      // a rental price, but no explicit transactionType exists.
      // Do not include records for exchange-only filters.
      if (filter.transactionType.toLowerCase() == 'exchange') {
        return false;
      }

      return true;
    }).toList();
  }

  Future<void> _openFilterSheet() async {
    final SearchFilterResult? filter =
        await showModalBottomSheet<SearchFilterResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return SearchFilterSheet(
          initialFilter: _currentFilter,
        );
      },
    );

    if (!mounted || filter == null) return;

    setState(() {
      _currentFilter = filter;
    });
  }

  void _openEquipmentDetails(EquipmentModel equipment) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EquipmentDetailsScreen(
          equipment: _equipmentToMap(equipment),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF0F1),
        surfaceTintColor: const Color(0xFFFFF0F1),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: darkText,
            size: 20,
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Categories',
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF777777),
              ),
            ),
            Text(
              widget.category,
              style: const TextStyle(
                color: darkText,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildSearchSection(),
          Expanded(
            child: StreamBuilder<List<EquipmentModel>>(
              stream: _equipmentStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: primaryRed,
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return _buildErrorState(snapshot.error);
                }

                final equipmentList =
                    _applyFilters(snapshot.data ?? []);

                if (equipmentList.isEmpty) {
                  return _buildEmptyState();
                }

                return _buildEquipmentGrid(equipmentList);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      color: const Color(0xFFFFF0F1),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 46,
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Search by equipment, sport...',
                      hintStyle: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF999999),
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: primaryRed,
                        size: 20,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: const BorderSide(color: primaryRed),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: const BorderSide(
                          color: primaryRed,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: _openFilterSheet,
                  icon: const Icon(
                    Icons.tune_rounded,
                    color: Color(0xFF777777),
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEquipmentGrid(List<EquipmentModel> results) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        final columns = width < 520
            ? 2
            : width < 800
                ? 3
                : width < 1100
                    ? 4
                    : 5;

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: GridView.builder(
              padding: const EdgeInsets.all(14),
              itemCount: results.length,
              gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: 12,
                mainAxisSpacing: 14,
                mainAxisExtent: width < 520 ? 235 : 260,
              ),
              itemBuilder: (context, index) {
                return _buildEquipmentCard(results[index]);
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildEquipmentCard(EquipmentModel equipment) {
    final imageUrl = equipment.imageUrl.trim();
    final hasImage = imageUrl.startsWith('https://') ||
        imageUrl.startsWith('http://');

    return InkWell(
      onTap: () => _openEquipmentDetails(equipment),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFEEEEEE)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  topRight: Radius.circular(14),
                ),
                child: Container(
                  width: double.infinity,
                  color: const Color(0xFFFAFAFA),
                  child: hasImage
                      ? Image.network(
                          equipmentThumbnailUrl(imageUrl),
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Icon(
                            _getEquipmentIcon(equipment.category),
                            size: 60,
                            color: const Color(0xFF555555),
                          ),
                        )
                      : Icon(
                          _getEquipmentIcon(equipment.category),
                          size: 60,
                          color: const Color(0xFF555555),
                        ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    equipment.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: darkText,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _formatPrice(equipment.pricePerDay),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: primaryRed,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 13,
                        color: Colors.green,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Available',
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFF888888),
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
    );
  }

  Widget _buildErrorState(Object? error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 52,
              color: primaryRed,
            ),
            const SizedBox(height: 12),
            const Text(
              'Unable to load equipment',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$error',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off_rounded,
              size: 60,
              color: Color(0xFFBBBBBB),
            ),
            const SizedBox(height: 12),
            const Text(
              'No equipment found',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No ${widget.category.toLowerCase()} equipment matches your search or filters.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF888888),
                fontSize: 12,
              ),
            ),
            if (_currentFilter != null) ...[
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  setState(() {
                    _currentFilter = null;
                  });
                },
                child: const Text(
                  'Clear Filters',
                  style: TextStyle(color: primaryRed),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
