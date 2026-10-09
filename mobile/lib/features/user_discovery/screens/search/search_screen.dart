import 'package:rent_lanka_mobile/navigation/player_bottom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:rent_lanka_mobile/features/user_discovery/screens/search/search_results_screen.dart';

class SearchScreen extends StatefulWidget {
  final String? initialQuery;

  const SearchScreen({
    super.key,
    this.initialQuery,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  static const Color primaryRed = Color(0xFFED1C24);
  static const Color darkText = Color(0xFF171717);

  late TextEditingController _searchController;

  final List<String> _recentSearches = [
    'Cricket bat',
    'Camping tent',
    'Badminton racket',
  ];

  @override
  void initState() {
    super.initState();

    _searchController = TextEditingController(
      text: widget.initialQuery ?? '',
    );
  }

  void _performSearch(String value) {
    final query = value.trim();

    if (query.isEmpty) {
      return;
    }

    if (!_recentSearches.any(
      (item) => item.toLowerCase() == query.toLowerCase(),
    )) {
      setState(() {
        _recentSearches.insert(0, query);
      });
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchResultsScreen(
          searchQuery: query,
        ),
      ),
    );
  }

  void _removeRecentSearch(int index) {
    setState(() {
      _recentSearches.removeAt(index);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: darkText,
          ),
        ),
        titleSpacing: 0,
        title: const Text(
          'Search',
          style: TextStyle(
            color: darkText,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 6, 18, 18),
            child: SizedBox(
              height: 48,
              child: TextField(
                controller: _searchController,
                autofocus: true,
                textInputAction: TextInputAction.search,
                onSubmitted: _performSearch,
                decoration: InputDecoration(
                  hintText: 'Search by equipment, sport...',
                  hintStyle: const TextStyle(
                    color: Color(0xFFAAAAAA),
                    fontSize: 12,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: primaryRed,
                    size: 21,
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      _searchController.clear();
                    },
                    icon: const Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: Color(0xFF999999),
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.zero,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: const BorderSide(
                      color: primaryRed,
                    ),
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

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Recent searches',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: darkText,
              ),
            ),
          ),

          const SizedBox(height: 5),

          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _recentSearches.length,
              separatorBuilder: (context, index) {
                return const Divider(
                  height: 1,
                  color: Color(0xFFEEEEEE),
                );
              },
              itemBuilder: (context, index) {
                final search = _recentSearches[index];

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  minLeadingWidth: 20,
                  leading: const Icon(
                    Icons.history_rounded,
                    size: 17,
                    color: Color(0xFF888888),
                  ),
                  title: Text(
                    search,
                    style: const TextStyle(
                      fontSize: 12,
                      color: darkText,
                    ),
                  ),
                  trailing: IconButton(
                    onPressed: () {
                      _removeRecentSearch(index);
                    },
                    icon: const Icon(
                      Icons.close_rounded,
                      size: 17,
                      color: Color(0xFF999999),
                    ),
                  ),
                  onTap: () {
                    _searchController.text = search;
                    _performSearch(search);
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildBottomNavigation() => const PlayerBottomNavigation(currentIndex: 1);
}
