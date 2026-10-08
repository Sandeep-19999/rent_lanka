
import 'package:flutter/material.dart';

import 'package:rent_lanka_mobile/features/user_discovery/widgets/search_filter_sheet.dart';
import 'package:rent_lanka_mobile/features/user_discovery/screens/equipment/equipment_details_screen.dart';

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

class _SearchResultsScreenState
    extends State<SearchResultsScreen> {
  static const Color primaryRed = Color(0xFFED1C24);
  static const Color darkText = Color(0xFF171717);

  late String _currentQuery;
  SearchFilterResult? _currentFilter;

  final TextEditingController _searchController =
      TextEditingController();

  final List<Map<String, dynamic>> _equipment = [
    {
      'name': 'SS Cricket Bat',
      'category': 'Cricket',
      'brand': 'SS',
      'location': 'Colombo',
      'price': 1200.0,
      'priceText': 'Rs. 1,200/day',
      'condition': 'Good',
      'size': 'Medium',
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
      'name': 'Kookaburra Hard Ball',
      'category': 'Cricket',
      'brand': 'Kookaburra',
      'location': 'Gampaha',
      'price': 500.0,
      'priceText': 'Rs. 500/day',
      'condition': 'Like New',
      'size': 'Small',
      'transactionType': 'Rental',
      'rating': '4.6',
      'owner': 'Kasun',
      'icon': Icons.sports_baseball,
    },
    {
      'name': 'Cricket Pad & Gloves Set',
      'category': 'Cricket',
      'brand': 'SS',
      'location': 'Kandy',
      'price': 900.0,
      'priceText': 'Rs. 900/day',
      'condition': 'Good',
      'size': 'Large',
      'transactionType': 'Rental',
      'rating': '4.7',
      'owner': 'Sahan',
      'icon': Icons.sports_cricket,
    },
    {
      'name': 'Adidas Football',
      'category': 'Football',
      'brand': 'Adidas',
      'location': 'Kalutara',
      'price': 500.0,
      'priceText': 'Rs. 500/day',
      'condition': 'New',
      'size': 'Medium',
      'transactionType': 'Rental',
      'rating': '4.9',
      'owner': 'Tharindu',
      'icon': Icons.sports_soccer,
    },
    {
      'name': 'Yonex Badminton Racket',
      'category': 'Badminton',
      'brand': 'Yonex',
      'location': 'Colombo',
      'price': 800.0,
      'priceText': 'Rs. 800/day',
      'condition': 'Like New',
      'size': 'Medium',
      'transactionType': 'Exchange',
      'rating': '4.8',
      'owner': 'Dinuka',
      'icon': Icons.sports_tennis,
    },
    {
      'name': 'Camping Tent',
      'category': 'Camping',
      'brand': 'Outdoor',
      'location': 'Galle',
      'price': 2000.0,
      'priceText': 'Rs. 2,000/day',
      'condition': 'Good',
      'size': 'Large',
      'transactionType': 'Rental',
      'rating': '4.5',
      'owner': 'Ravindu',
      'icon': Icons.cabin_outlined,
    },
    {
      'name': 'Hockey Stick',
      'category': 'Hockey',
      'brand': 'Grays',
      'location': 'Matara',
      'price': 750.0,
      'priceText': 'Rs. 750/day',
      'condition': 'Good',
      'size': 'Medium',
      'transactionType': 'Exchange',
      'rating': '4.7',
      'owner': 'Akila',
      'icon': Icons.sports_hockey,
    },
    {
      'name': 'Mountain Bicycle',
      'category': 'Cycling',
      'brand': 'Giant',
      'location': 'Kurunegala',
      'price': 2500.0,
      'priceText': 'Rs. 2,500/day',
      'condition': 'Like New',
      'size': 'Large',
      'transactionType': 'Rental',
      'rating': '4.9',
      'owner': 'Malith',
      'icon': Icons.pedal_bike,
    },
  ];

  @override
  void initState() {
    super.initState();

    _currentQuery = widget.searchQuery;
    _currentFilter = widget.initialFilter;
    _searchController.text = _currentQuery;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredEquipment {
    List<Map<String, dynamic>> results =
        List<Map<String, dynamic>>.from(_equipment);

    final String query =
        _currentQuery.trim().toLowerCase();

    if (query.isNotEmpty) {
      results = results.where((item) {
        final String name =
            (item['name'] as String).toLowerCase();

        final String category =
            (item['category'] as String).toLowerCase();

        final String brand =
            (item['brand'] as String).toLowerCase();

        final String location =
            (item['location'] as String).toLowerCase();

        return name.contains(query) ||
            category.contains(query) ||
            brand.contains(query) ||
            location.contains(query);
      }).toList();
    }

    final SearchFilterResult? filter = _currentFilter;

    if (filter != null) {
      results = results.where((item) {
        final bool categoryMatch =
            filter.category == 'Any' ||
                item['category'] == filter.category;

        final bool locationMatch =
            filter.location == 'Any' ||
                item['location'] == filter.location;

        final bool priceMatch =
            (item['price'] as double) <= filter.maxPrice;

        final bool conditionMatch =
            filter.condition == 'Any' ||
                item['condition'] == filter.condition;

        final bool sizeMatch =
            filter.size == 'Any' ||
                item['size'] == filter.size;

        final bool transactionMatch =
            item['transactionType'] ==
                filter.transactionType;

        return categoryMatch &&
            locationMatch &&
            priceMatch &&
            conditionMatch &&
            sizeMatch &&
            transactionMatch;
      }).toList();
    }

    return results;
  }

  Future<void> _openFilterSheet() async {
    final SearchFilterResult? result =
        await showModalBottomSheet<SearchFilterResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0x59000000),
      builder: (context) {
        return SearchFilterSheet(
          initialFilter: _currentFilter,
        );
      },
    );

    if (result == null || !mounted) return;

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
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
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
            child: results.isEmpty
                ? _buildEmptyState()
                : _buildResults(results),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(
        18,
        10,
        18,
        16,
      ),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 48,
              child: TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                onSubmitted: _performSearch,
                onChanged: (_) {
                  setState(() {});
                },
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
                    borderRadius:
                        BorderRadius.circular(24),
                    borderSide: const BorderSide(
                      color: primaryRed,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(24),
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
    );
  }

  Widget _buildResults(
    List<Map<String, dynamic>> results,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        18,
        18,
        18,
        24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
          ListView.separated(
            shrinkWrap: true,
            physics:
                const NeverScrollableScrollPhysics(),
            itemCount: results.length,
            separatorBuilder: (context, index) {
              return const SizedBox(height: 12);
            },
            itemBuilder: (context, index) {
              return _buildEquipmentCard(
                results[index],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEquipmentCard(
    Map<String, dynamic> item,
  ) {
    return InkWell(
      onTap: () {
        _openEquipmentDetails(item);
      },
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
              child: Icon(
                item['icon'] as IconData,
                size: 43,
                color: const Color(0xFF555555),
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name'] as String,
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
                    '${item['category']} • ${item['condition']}',
                    style: const TextStyle(
                      color: Color(0xFF777777),
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: Color(0xFF888888),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        item['location'] as String,
                        style: const TextStyle(
                          color: Color(0xFF777777),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item['priceText'] as String,
                          style: const TextStyle(
                            color: primaryRed,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.star_rounded,
                        size: 15,
                        color: Color(0xFFFFB300),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        item['rating'] as String,
                        style: const TextStyle(
                          color: darkText,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
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
                  side: const BorderSide(
                    color: primaryRed,
                  ),
                ),
                child: const Text('Clear Filters'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return BottomNavigationBar(
      currentIndex: 1,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: primaryRed,
      unselectedItemColor:
          const Color(0xFF999999),
      selectedFontSize: 10,
      unselectedFontSize: 9,
      onTap: (index) {
        if (index == 0) {
          Navigator.pop(context);
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search_rounded),
          label: 'Search',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.download_outlined),
          label: 'Booking',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.chat_bubble_outline_rounded,
          ),
          label: 'Messages',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline_rounded),
          label: 'Profile',
        ),
      ],
    );
  }
}
