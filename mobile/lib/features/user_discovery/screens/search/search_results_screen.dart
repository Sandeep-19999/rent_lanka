import 'package:rent_lanka_mobile/navigation/player_bottom_navigation.dart';
import 'package:flutter/material.dart';

import 'package:rent_lanka_mobile/features/user_discovery/models/equipment_model.dart';
import 'package:rent_lanka_mobile/features/user_discovery/services/equipment_service.dart';
import 'package:rent_lanka_mobile/features/user_discovery/screens/equipment/equipment_details_screen.dart';
import 'package:rent_lanka_mobile/features/user_discovery/widgets/search_filter_sheet.dart';

class SearchResultsScreen extends StatefulWidget {
  final String searchQuery;
  final SearchFilterResult? initialFilter;

  const SearchResultsScreen({
    super.key,
    required this.searchQuery,
    this.initialFilter,
  });

  @override
  State<SearchResultsScreen> createState() =>
      _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  static const Color primaryRed = Color(0xFFED1C24);
  static const Color darkText = Color(0xFF171717);

  final TextEditingController _searchController =
      TextEditingController();

  final EquipmentService _equipmentService = EquipmentService();

  late final Stream<List<EquipmentModel>> _equipmentStream;
  late String _currentQuery;
  SearchFilterResult? _currentFilter;

  @override
  void initState() {
    super.initState();

    _currentQuery = widget.searchQuery.trim();
    _currentFilter = widget.initialFilter;
    _searchController.text = _currentQuery;

    _equipmentStream = _equipmentService.getAvailableEquipment();
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
    final formatted = price.toStringAsFixed(0).replaceAllMapped(
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
      'location': equipment.location,
      'transactionType': equipment.transactionType,
    };
  }

  List<EquipmentModel> _applyFilters(
    List<EquipmentModel> equipmentList,
  ) {
    final query = _currentQuery.trim().toLowerCase();

    return equipmentList.where((equipment) {
      // Search by name, category, brand, or location.
      if (query.isNotEmpty) {
        final searchableText =
            '${equipment.name} '
            '${equipment.category} '
            '${equipment.brand} '
            '${equipment.location}'
                .toLowerCase();

        if (!searchableText.contains(query)) {
          return false;
        }
      }

      final filter = _currentFilter;

      if (filter == null) {
        return true;
      }

      // Category
      if (filter.category.trim().toLowerCase() != 'any' &&
          equipment.category.trim().toLowerCase() !=
              filter.category.trim().toLowerCase()) {
        return false;
      }

      // Maximum rental price
      if (equipment.pricePerDay > filter.maxPrice) {
        return false;
      }

      // Condition
      if (filter.condition.trim().toLowerCase() != 'any' &&
          equipment.condition.trim().toLowerCase() !=
              filter.condition.trim().toLowerCase()) {
        return false;
      }

      // Size
      if (filter.size.trim().toLowerCase() != 'any' &&
          equipment.size.trim().toLowerCase() !=
              filter.size.trim().toLowerCase()) {
        return false;
      }

      // Location from Firestore
      final selectedLocation =
          filter.location.trim().toLowerCase();

      final equipmentLocation =
          equipment.location.trim().toLowerCase();

      if (selectedLocation.isNotEmpty &&
          selectedLocation != 'any' &&
          selectedLocation != equipmentLocation) {
        return false;
      }

      // Rental / Exchange from Firestore
      final selectedType =
          filter.transactionType.trim().toLowerCase();

      final storedType =
          equipment.transactionType.trim().toLowerCase();

      // Older rental listings may not have transactionType.
      final effectiveType = storedType.isNotEmpty
          ? storedType
          : (equipment.pricePerDay > 0 ? 'rental' : '');

      if (selectedType.isNotEmpty &&
          selectedType != 'any' &&
          effectiveType != selectedType) {
        return false;
      }

      return true;
    }).toList();
  }

  Future<void> _openFilterSheet() async {
    final result = await showModalBottomSheet<SearchFilterResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0x59000000),
      builder: (_) => SearchFilterSheet(
        initialFilter: _currentFilter,
      ),
    );

    if (!mounted || result == null) {
      return;
    }

    setState(() {
      _currentFilter = result;
    });
  }

  void _performSearch(String value) {
    setState(() {
      _currentQuery = value.trim();
    });

    FocusScope.of(context).unfocus();
  }

  void _clearSearch() {
    _searchController.clear();

    setState(() {
      _currentQuery = '';
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
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: darkText,
            size: 20,
          ),
        ),
        title: const Text(
          'Search Results',
          style: TextStyle(
            color: darkText,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
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

                final results =
                    _applyFilters(snapshot.data ?? []);

                if (results.isEmpty) {
                  return _buildEmptyState();
                }

                return _buildResults(results);
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: TextField(
                    controller: _searchController,
                    textInputAction: TextInputAction.search,
                    onSubmitted: _performSearch,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Search equipment...',
                      hintStyle: const TextStyle(
                        color: Color(0xFF999999),
                        fontSize: 13,
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: primaryRed,
                        size: 21,
                      ),
                      suffixIcon:
                          _searchController.text.isNotEmpty
                              ? IconButton(
                                  onPressed: _clearSearch,
                                  icon: const Icon(
                                    Icons.close_rounded,
                                    color: Color(0xFF888888),
                                    size: 19,
                                  ),
                                )
                              : null,
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding:
                          const EdgeInsets.symmetric(
                        horizontal: 14,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide:
                            const BorderSide(color: primaryRed),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
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
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _currentFilter != null
                      ? const Color(0xFFFFF0F1)
                      : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _currentFilter != null
                        ? primaryRed
                        : const Color(0xFFE0E0E0),
                  ),
                ),
                child: IconButton(
                  onPressed: _openFilterSheet,
                  icon: Icon(
                    Icons.tune_rounded,
                    size: 20,
                    color: _currentFilter != null
                        ? primaryRed
                        : const Color(0xFF777777),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResults(List<EquipmentModel> results) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1100),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _currentQuery.isEmpty
                        ? 'Available Equipment'
                        : 'Results for "$_currentQuery"',
                    style: const TextStyle(
                      color: darkText,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Text(
                  '${results.length} found',
                  style: const TextStyle(
                    color: Color(0xFF777777),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...results.map(
              (equipment) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildEquipmentCard(equipment),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEquipmentCard(EquipmentModel equipment) {
    final imageUrl = equipment.imageUrl.trim();

    final hasImage =
        imageUrl.startsWith('https://') ||
        imageUrl.startsWith('http://');

    return InkWell(
      onTap: () => _openEquipmentDetails(equipment),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFEEEEEE),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(13),
              ),
              clipBehavior: Clip.antiAlias,
              child: hasImage
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Icon(
                        _getEquipmentIcon(equipment.category),
                        size: 43,
                        color: const Color(0xFF555555),
                      ),
                    )
                  : Icon(
                      _getEquipmentIcon(equipment.category),
                      size: 43,
                      color: const Color(0xFF555555),
                    ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    equipment.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: darkText,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${equipment.category} • ${equipment.condition}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF777777),
                      fontSize: 11,
                    ),
                  ),
                  if (equipment.location.isNotEmpty) ...[
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: Color(0xFF777777),
                        ),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            equipment.location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF777777),
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        size: 14,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Available',
                        style: TextStyle(
                          color: Color(0xFF777777),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  Text(
                    _formatPrice(equipment.pricePerDay),
                    style: const TextStyle(
                      color: primaryRed,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
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
              size: 50,
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
                color: Colors.grey,
                fontSize: 11,
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
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 85,
              height: 85,
              decoration: const BoxDecoration(
                color: Color(0xFFFFF0F1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off_rounded,
                color: primaryRed,
                size: 40,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'No equipment found',
              style: TextStyle(
                color: darkText,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 7),
            const Text(
              'No equipment matches your search or selected filters. Try changing your filters.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF888888),
                fontSize: 12,
                height: 1.5,
              ),
            ),
            if (_currentFilter != null) ...[
              const SizedBox(height: 18),
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    _currentFilter = null;
                  });
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryRed,
                  side: const BorderSide(color: primaryRed),
                ),
                child: const Text('Clear Filters'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() => const PlayerBottomNavigation(currentIndex: 1);
}
