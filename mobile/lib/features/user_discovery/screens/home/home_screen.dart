
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:rent_lanka_mobile/features/user_discovery/models/equipment_model.dart';
import 'package:rent_lanka_mobile/features/user_discovery/services/equipment_service.dart';

import 'package:rent_lanka_mobile/features/user_discovery/screens/search/search_screen.dart';
import 'package:rent_lanka_mobile/features/user_discovery/screens/search/search_results_screen.dart';
import 'package:rent_lanka_mobile/features/user_discovery/screens/search/category_equipment_screen.dart';
import 'package:rent_lanka_mobile/features/user_discovery/screens/equipment/equipment_details_screen.dart';
import 'package:rent_lanka_mobile/features/user_discovery/screens/favourites/my_favourites_screen.dart';

import 'package:rent_lanka_mobile/features/user_discovery/widgets/search_filter_sheet.dart';
import 'package:rent_lanka_mobile/features/user_discovery/widgets/app_side_menu.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color primaryRed = Color(0xFFED1C24);
  static const Color darkText = Color(0xFF171717);
  static const Color pageBackground = Color(0xFFF7F7F7);

  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>();

  final EquipmentService _equipmentService = EquipmentService();

  late final Stream<List<EquipmentModel>> _equipmentStream;

  int _selectedIndex = 0;
  String _userName = 'Player';

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Cricket', 'icon': Icons.sports_cricket},
    {'name': 'Football', 'icon': Icons.sports_soccer},
    {'name': 'Volleyball', 'icon': Icons.sports_volleyball},
    {'name': 'Cycling', 'icon': Icons.pedal_bike},
    {'name': 'Swimming', 'icon': Icons.pool},
    {'name': 'Hockey', 'icon': Icons.sports_hockey},
  ];

  @override
  void initState() {
    super.initState();
    _equipmentStream = _equipmentService.getAvailableEquipment();
    _loadUserName();
  }

  void _loadUserName() {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    String name = user.displayName?.trim() ?? '';

    if (name.isEmpty && user.email != null) {
      name = user.email!.split('@').first;
    }

    if (name.isNotEmpty) {
      setState(() {
        _userName = name;
      });
    }
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

  Map<String, dynamic> _equipmentToMap(
    EquipmentModel equipment,
  ) {
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

  void _openFavouritesScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const MyFavouritesScreen(),
      ),
    );
  }

  void _openSearchScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SearchScreen(),
      ),
    );
  }

  Future<void> _openFilterSheet() async {
    final SearchFilterResult? filter =
        await showModalBottomSheet<SearchFilterResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0x59000000),
      builder: (_) => const SearchFilterSheet(),
    );

    if (!mounted || filter == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SearchResultsScreen(
          searchQuery: '',
          initialFilter: filter,
        ),
      ),
    );
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

  void _openCategory(String category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CategoryEquipmentScreen(
          category: category,
        ),
      ),
    );
  }

  void _onBottomNavigationTap(int index) {
    if (index == 0) {
      setState(() {
        _selectedIndex = 0;
      });
      return;
    }

    if (index == 1) {
      _openSearchScreen();
      return;
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const AppSideMenu(),
      backgroundColor: pageBackground,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 1150,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        18,
                        20,
                        18,
                        28,
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          _buildSearchSection(),
                          const SizedBox(height: 24),
                          _buildSectionTitle('Categories'),
                          const SizedBox(height: 14),
                          _buildCategories(),
                          const SizedBox(height: 26),
                          _buildSectionTitle(
                            'Fresh Recommendations',
                          ),
                          const SizedBox(height: 14),
                          _buildEquipmentGrid(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w800,
        color: darkText,
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        20,
        18,
        20,
        24,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFFFEEF0),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 1150,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    _scaffoldKey.currentState?.openDrawer();
                  },
                  icon: const Icon(
                    Icons.menu_rounded,
                    color: darkText,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hi $_userName!',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: darkText,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Welcome',
                      style: TextStyle(
                        color: primaryRed,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
                Container(
                  width: 42,
                  height: 42,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    tooltip: 'My Favourites',
                    onPressed: _openFavouritesScreen,
                    icon: const Icon(
                      Icons.favorite_border_rounded,
                      color: primaryRed,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.notifications_none_rounded,
                    color: darkText,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchSection() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 48,
            child: TextField(
              readOnly: true,
              onTap: _openSearchScreen,
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
                contentPadding:
                    const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 12,
                ),
                filled: true,
                fillColor: Colors.white,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(
                    color: primaryRed,
                  ),
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
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFFE0E0E0),
            ),
          ),
          child: IconButton(
            onPressed: _openFilterSheet,
            icon: const Icon(
              Icons.tune_rounded,
              size: 20,
              color: Color(0xFF777777),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 92,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, _) =>
            const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final category = _categories[index];

          return InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              _openCategory(
                category['name'] as String,
              );
            },
            child: SizedBox(
              width: 74,
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(14),
                      border: Border.all(
                        color: index == 0
                            ? primaryRed
                            : const Color(0xFFEAEAEA),
                      ),
                    ),
                    child: Icon(
                      category['icon'] as IconData,
                      size: 29,
                      color: index == 0
                          ? primaryRed
                          : const Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    category['name'] as String,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: index == 0
                          ? primaryRed
                          : darkText,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ========================================================
  // FIREBASE EQUIPMENT GRID - RESPONSIVE
  // ========================================================

  Widget _buildEquipmentGrid() {
    return StreamBuilder<List<EquipmentModel>>(
      stream: _equipmentStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(
              vertical: 40,
            ),
            child: Center(
              child: CircularProgressIndicator(
                color: primaryRed,
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 30,
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.error_outline,
                  color: primaryRed,
                  size: 35,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Unable to load equipment',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        final equipmentList = snapshot.data ?? [];

        if (equipmentList.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(
              vertical: 40,
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 42,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'No equipment available right now',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final double width = constraints.maxWidth;

            int columns;

            if (width < 480) {
              columns = 2;
            } else if (width < 720) {
              columns = 3;
            } else if (width < 950) {
              columns = 4;
            } else {
              columns = 5;
            }

            return GridView.builder(
              shrinkWrap: true,
              physics:
                  const NeverScrollableScrollPhysics(),
              itemCount: equipmentList.length,
              gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: 14,
                mainAxisSpacing: 16,
                mainAxisExtent: width < 480 ? 235 : 260,
              ),
              itemBuilder: (context, index) {
                return _buildEquipmentCard(
                  equipmentList[index],
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildEquipmentCard(
    EquipmentModel equipment,
  ) {
    final String imageUrl = equipment.imageUrl.trim();

    final bool hasImage =
        imageUrl.startsWith('https\://') ||
        imageUrl.startsWith('http\://');

    return InkWell(
      onTap: () {
        _openEquipmentDetails(equipment);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFEEEEEE),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: Container(
                  width: double.infinity,
                  color: const Color(0xFFF8F8F8),
                  child: hasImage
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (
                            context,
                            error,
                            stackTrace,
                          ) {
                            return Icon(
                              _getEquipmentIcon(
                                equipment.category,
                              ),
                              size: 55,
                              color: const Color(
                                0xFF555555,
                              ),
                            );
                          },
                        )
                      : Icon(
                          _getEquipmentIcon(
                            equipment.category,
                          ),
                          size: 55,
                          color: const Color(
                            0xFF555555,
                          ),
                        ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                10,
                10,
                10,
                12,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    equipment.name,
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: darkText,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _formatPrice(
                      equipment.pricePerDay,
                    ),
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: primaryRed,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        size: 14,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 4),
                      const Expanded(
                        child: Text(
                          'Available',
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(
                              0xFF888888,
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
    );
  }

  Widget _buildBottomNavigation() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onBottomNavigationTap,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: primaryRed,
      unselectedItemColor:
          const Color(0xFF999999),
      selectedFontSize: 10,
      unselectedFontSize: 9,
      elevation: 8,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home_rounded),
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
          icon: Icon(
            Icons.person_outline_rounded,
          ),
          label: 'Profile',
        ),
      ],
    );
  }
}
