import 'package:flutter/material.dart';

class SearchFilterResult {
  final String category;
  final String location;
  final double maxPrice;
  final String condition;
  final String size;
  final String transactionType;

  const SearchFilterResult({
    required this.category,
    required this.location,
    required this.maxPrice,
    required this.condition,
    required this.size,
    required this.transactionType,
  });
}

class SearchFilterSheet extends StatefulWidget {
  final SearchFilterResult? initialFilter;

  const SearchFilterSheet({
    super.key,
    this.initialFilter,
  });

  @override
  State<SearchFilterSheet> createState() => _SearchFilterSheetState();
}

class _SearchFilterSheetState extends State<SearchFilterSheet> {
  static const Color primaryRed = Color(0xFFED1C24);
  static const Color darkText = Color(0xFF171717);

  String _selectedCategory = 'Any';
  String _selectedLocation = 'Any';
  double _maxPrice = 5000;
  String _selectedCondition = 'Any';
  String _selectedSize = 'Any';
  String _transactionType = 'Rental';

  final List<String> _categories = [
    'Any',
    'Cricket',
    'Football',
    'Badminton',
    'Hockey',
    'Cycling',
    'Camping',
  ];

  final List<String> _locations = [
  'Any',
  'Ampara',
  'Anuradhapura',
  'Badulla',
  'Batticaloa',
  'Colombo',
  'Galle',
  'Gampaha',
  'Hambantota',
  'Jaffna',
  'Kalutara',
  'Kandy',
  'Kegalle',
  'Kilinochchi',
  'Kurunegala',
  'Mannar',
  'Matale',
  'Matara',
  'Monaragala',
  'Mullaitivu',
  'Nuwara Eliya',
  'Polonnaruwa',
  'Puttalam',
  'Ratnapura',
  'Trincomalee',
  'Vavuniya',
];

  final List<String> _conditions = [
    'Any',
    'New',
    'Like New',
    'Good',
  ];

  final List<String> _sizes = [
    'Any',
    'Small',
    'Medium',
    'Large',
  ];

  @override
  void initState() {
    super.initState();

    final SearchFilterResult? filter = widget.initialFilter;

    if (filter != null) {
      _selectedCategory = filter.category;
      _selectedLocation = filter.location;
      _maxPrice = filter.maxPrice;
      _selectedCondition = filter.condition;
      _selectedSize = filter.size;
      _transactionType = filter.transactionType;
    }
  }

  void _applyFilters() {
    final SearchFilterResult result = SearchFilterResult(
      category: _selectedCategory,
      location: _selectedLocation,
      maxPrice: _maxPrice,
      condition: _selectedCondition,
      size: _selectedSize,
      transactionType: _transactionType,
    );

    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            const SizedBox(height: 10),

            // Small top handle
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFD9D9D9),
                borderRadius: BorderRadius.circular(20),
              ),
            ),

            const SizedBox(height: 10),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Filters',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        color: darkText,
                      ),
                    ),
                  ),

                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.close_rounded,
                      color: darkText,
                    ),
                  ),
                ],
              ),
            ),

            const Divider(
              height: 1,
              color: Color(0xFFEEEEEE),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  20,
                  20,
                  20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // SPORT CATEGORY
                    _buildLabel('Sport Category'),

                    const SizedBox(height: 8),

                    _buildDropdown(
                      value: _selectedCategory,
                      items: _categories,
                      onChanged: (value) {
                        if (value == null) return;

                        setState(() {
                          _selectedCategory = value;
                        });
                      },
                    ),

                    const SizedBox(height: 20),

                    // LOCATION
                    _buildLabel('Location'),

                    const SizedBox(height: 8),

                    _buildDropdown(
                      value: _selectedLocation,
                      items: _locations,
                      onChanged: (value) {
                        if (value == null) return;

                        setState(() {
                          _selectedLocation = value;
                        });
                      },
                    ),

                    const SizedBox(height: 20),

                    // PRICE RANGE
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Price Range (Per Day)',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: darkText,
                            ),
                          ),
                        ),

                        Text(
                          _maxPrice >= 10000
                              ? 'Rs. 10,000+'
                              : 'Rs. ${_maxPrice.round()}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: primaryRed,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 5),

                    Slider(
                      value: _maxPrice,
                      min: 0,
                      max: 10000,
                      divisions: 20,
                      activeColor: primaryRed,
                      inactiveColor: const Color(0xFFE5E5E5),
                      onChanged: (value) {
                        setState(() {
                          _maxPrice = value;
                        });
                      },
                    ),

                    const Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Rs. 0',
                          style: TextStyle(
                            color: Color(0xFF888888),
                            fontSize: 11,
                          ),
                        ),
                        Text(
                          'Rs. 10,000+',
                          style: TextStyle(
                            color: Color(0xFF888888),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // CONDITION
                    _buildLabel('Condition'),

                    const SizedBox(height: 8),

                    _buildDropdown(
                      value: _selectedCondition,
                      items: _conditions,
                      onChanged: (value) {
                        if (value == null) return;

                        setState(() {
                          _selectedCondition = value;
                        });
                      },
                    ),

                    const SizedBox(height: 20),

                    // SIZE
                    _buildLabel('Size'),

                    const SizedBox(height: 8),

                    _buildDropdown(
                      value: _selectedSize,
                      items: _sizes,
                      onChanged: (value) {
                        if (value == null) return;

                        setState(() {
                          _selectedSize = value;
                        });
                      },
                    ),

                    const SizedBox(height: 20),

                    // TRANSACTION TYPE
                    _buildLabel('Transaction Type'),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: _buildTransactionOption(
                            title: 'Rental',
                            value: 'Rental',
                          ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: _buildTransactionOption(
                            title: 'Exchange',
                            value: 'Exchange',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // APPLY BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _applyFilters,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryRed,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Apply Filters',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: darkText,
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE0E0E0),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Color(0xFF777777),
          ),
          style: const TextStyle(
            color: darkText,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildTransactionOption({
    required String title,
    required String value,
  }) {
    final bool isSelected =
        _transactionType == value;

    return InkWell(
      onTap: () {
        setState(() {
          _transactionType = value;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFFFF0F1)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? primaryRed
                : const Color(0xFFE0E0E0),
          ),
        ),
        child: Row(
          children: [
            Radio<String>(
              value: value,
              groupValue: _transactionType,
              activeColor: primaryRed,
              materialTapTargetSize:
                  MaterialTapTargetSize.shrinkWrap,
              onChanged: (newValue) {
                if (newValue == null) return;

                setState(() {
                  _transactionType = newValue;
                });
              },
            ),

            const SizedBox(width: 2),

            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? primaryRed
                    : darkText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}