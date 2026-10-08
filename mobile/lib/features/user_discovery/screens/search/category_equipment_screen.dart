
import 'package:flutter/material.dart';

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

  SearchFilterResult? _currentFilter;

  final List<Map<String, dynamic>> _equipment = [
    {
      'name': 'SS Cricket Bat',
      'category': 'Cricket',
      'location': 'Colombo',
      'condition': 'Good',
      'size': 'Medium',
      'price': 1200.0,
      'priceText': 'Rs. 1,200/day',
      'transactionType': 'Rental',
      'rating': '4.8',
      'owner': 'Kamal Sports Gear',
      'description':
          'Professional English willow cricket bat. '
          'Used for one season. Perfect for hard tennis '
          'or leather ball.',
      'icon': Icons.sports_cricket,
    },
    {
      'name': 'Kookaburra Ball',
      'category': 'Cricket',
      'location': 'Gampaha',
      'condition': 'Like New',
      'size': 'Small',
      'price': 500.0,
      'priceText': 'Rs. 500/day',
      'transactionType': 'Rental',
      'rating': '4.6',
      'owner': 'Kasun',
      'icon': Icons.sports_baseball,
    },
    {
      'name': 'Cricket Helmet',
      'category': 'Cricket',
      'location': 'Kandy',
      'condition': 'Good',
      'size': 'Medium',
      'price': 400.0,
      'priceText': 'Rs. 400/day',
      'transactionType': 'Rental',
      'rating': '4.7',
      'owner': 'Sahan',
      'icon': Icons.sports_cricket,
    },
    {
      'name': 'Batting Gloves',
      'category': 'Cricket',
      'location': 'Colombo',
      'condition': 'New',
      'size': 'Medium',
      'price': 800.0,
      'priceText': 'Rs. 800/day',
      'transactionType': 'Rental',
      'rating': '4.9',
      'owner': 'Nimal',
      'icon': Icons.back_hand_outlined,
    },
    {
      'name': 'Wooden Stumps',
      'category': 'Cricket',
      'location': 'Galle',
      'condition': 'Good',
      'size': 'Large',
      'price': 300.0,
      'priceText': 'Rs. 300/day',
      'transactionType': 'Rental',
      'rating': '4.5',
      'owner': 'Ravindu',
      'icon': Icons.sports_cricket,
    },
    {
      'name': 'Full Kit Bag',
      'category': 'Cricket',
      'location': 'Colombo',
      'condition': 'Good',
      'size': 'Large',
      'price': 2000.0,
      'priceText': 'Rs. 2,000/day',
      'transactionType': 'Rental',
      'rating': '4.8',
      'owner': 'Kamal Sports Gear',
      'icon': Icons.work_outline,
    },
    {
      'name': 'Thigh Guard',
      'category': 'Cricket',
      'location': 'Matara',
      'condition': 'Good',
      'size': 'Medium',
      'price': 250.0,
      'priceText': 'Rs. 250/day',
      'transactionType': 'Rental',
      'rating': '4.4',
      'owner': 'Akila',
      'icon': Icons.shield_outlined,
    },
    {
      'name': 'Guard',
      'category': 'Cricket',
      'location': 'Kalutara',
      'condition': 'Good',
      'size': 'Small',
      'price': 150.0,
      'priceText': 'Rs. 150/day',
      'transactionType': 'Rental',
      'rating': '4.3',
      'owner': 'Tharindu',
      'icon': Icons.shield,
    },
    {
      'name': 'Adidas Football',
      'category': 'Football',
      'location': 'Colombo',
      'condition': 'New',
      'size': 'Medium',
      'price': 500.0,
      'priceText': 'Rs. 500/day',
      'transactionType': 'Rental',
      'rating': '4.9',
      'owner': 'Sports Gear',
      'icon': Icons.sports_soccer,
    },
    {
      'name': 'Volleyball',
      'category': 'Volleyball',
      'location': 'Gampaha',
      'condition': 'Good',
      'size': 'Medium',
      'price': 450.0,
      'priceText': 'Rs. 450/day',
      'transactionType': 'Rental',
      'rating': '4.6',
      'owner': 'Sports Gear',
      'icon': Icons.sports_volleyball,
    },
    {
      'name': 'Mountain Bicycle',
      'category': 'Cycling',
      'location': 'Kandy',
      'condition': 'Like New',
      'size': 'Large',
      'price': 2500.0,
      'priceText': 'Rs. 2,500/day',
      'transactionType': 'Rental',
      'rating': '4.8',
      'owner': 'Cycle Hub',
      'icon': Icons.pedal_bike,
    },
    {
      'name': 'Swimming Goggles',
      'category': 'Swimming',
      'location': 'Colombo',
      'condition': 'New',
      'size': 'Small',
      'price': 300.0,
      'priceText': 'Rs. 300/day',
      'transactionType': 'Rental',
      'rating': '4.7',
      'owner': 'Swim Shop',
      'icon': Icons.pool,
    },
    {
      'name': 'Hockey Stick',
      'category': 'Hockey',
      'location': 'Matara',
      'condition': 'Good',
      'size': 'Medium',
      'price': 750.0,
      'priceText': 'Rs. 750/day',
      'transactionType': 'Rental',
      'rating': '4.5',
      'owner': 'Hockey Gear',
      'icon': Icons.sports_hockey,
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredEquipment {
    final String query =
        _searchController.text.trim().toLowerCase();

    return _equipment.where((item) {
      if (item['category'] != widget.category) {
        return false;
      }

      final String name =
          (item['name'] as String).toLowerCase();

      if (query.isNotEmpty && !name.contains(query)) {
        return false;
      }

      final SearchFilterResult? filter = _currentFilter;

      if (filter != null) {
        if (filter.category != 'Any' &&
            item['category'] != filter.category) {
          return false;
        }

        if (filter.location != 'Any' &&
            item['location'] != filter.location) {
          return false;
        }

        if ((item['price'] as double) > filter.maxPrice) {
          return false;
        }

        if (filter.condition != 'Any' &&
            item['condition'] != filter.condition) {
          return false;
        }

        if (filter.size != 'Any' &&
            item['size'] != filter.size) {
          return false;
        }

        if (item['transactionType'] !=
            filter.transactionType) {
          return false;
        }
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
      builder: (context) {
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

  void _openEquipmentDetails(
    Map<String, dynamic> item,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EquipmentDetailsScreen(
          equipment: item,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> results =
        _filteredEquipment;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF0F1),
        surfaceTintColor: const Color(0xFFFFF0F1),
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
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
            child: results.isEmpty
                ? _buildEmptyState()
                : _buildEquipmentGrid(results),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      color: const Color(0xFFFFF0F1),
      padding: const EdgeInsets.fromLTRB(
        16,
        8,
        16,
        16,
      ),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 46,
              child: TextField(
                controller: _searchController,
                onChanged: (_) {
                  setState(() {});
                },
                decoration: InputDecoration(
                  hintText:
                      'Search by equipment, sport...',
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
                      const EdgeInsets.symmetric(
                    horizontal: 12,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(25),
                    borderSide: const BorderSide(
                      color: primaryRed,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(25),
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
    );
  }

  Widget _buildEquipmentGrid(
    List<Map<String, dynamic>> results,
  ) {
    return GridView.builder(
      padding: const EdgeInsets.all(14),
      itemCount: results.length,
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 12,
        childAspectRatio: 0.76,
      ),
      itemBuilder: (context, index) {
        final Map<String, dynamic> item = results[index];

        return InkWell(
          onTap: () {
            _openEquipmentDetails(item);
          },
          borderRadius: BorderRadius.circular(14),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFAFAFA),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(14),
                        topRight: Radius.circular(14),
                      ),
                    ),
                    child: Icon(
                      item['icon'] as IconData,
                      size: 65,
                      color: const Color(0xFF555555),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(9),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['name'] as String,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: darkText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['priceText'] as String,
                        style: const TextStyle(
                          color: primaryRed,
                          fontSize: 11,
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
      },
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
