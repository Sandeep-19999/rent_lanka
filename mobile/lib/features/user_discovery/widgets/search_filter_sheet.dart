
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

  static const SearchFilterResult defaults = SearchFilterResult(
    category: 'Any',
    location: 'Any',
    maxPrice: double.infinity,
    condition: 'Any',
    size: 'Any',
    transactionType: 'Rental',
  );
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
  static const double sliderMaximum = 10000;

  String _selectedCategory = 'Any';
  String _selectedLocation = 'Any';
  double _maxPrice = double.infinity;
  String _selectedCondition = 'Any';
  String _selectedSize = 'Any';
  String _transactionType = 'Rental';

  final List<String> _categories = [
    'Any',
    'Cricket',
    'Football',
    'Volleyball',
    'Cycling',
    'Swimming',
    'Hockey',
    'Badminton',
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
    'Fair',
  ];

  final List<String> _sizes = [
    'Any',
    'Small',
    'Medium',
    'Large',
    'Standard',
    'SH',
  ];

  @override
  void initState() {
    super.initState();
    _loadFilter(
      widget.initialFilter ?? SearchFilterResult.defaults,
    );
  }

  void _loadFilter(SearchFilterResult filter) {
    _selectedCategory = filter.category;
    _selectedLocation = filter.location;
    _maxPrice = filter.maxPrice;
    _selectedCondition = filter.condition;
    _selectedSize = filter.size;
    _transactionType = filter.transactionType;
  }

  SearchFilterResult _createResult() {
    return SearchFilterResult(
      category: _selectedCategory,
      location: _selectedLocation,
      maxPrice: _maxPrice,
      condition: _selectedCondition,
      size: _selectedSize,
      transactionType: _transactionType,
    );
  }

  void _applyFilters() {
    Navigator.pop(context, _createResult());
  }

  void _resetFilters() {
    setState(() {
      _loadFilter(SearchFilterResult.defaults);
    });
  }

  String _formatPrice(double price) {
    if (price.isInfinite || price >= sliderMaximum) {
      return 'Any price';
    }

    final formatted = price.round().toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );

    return 'Rs. $formatted';
  }

  bool get _hasActiveFilters {
    return _selectedCategory != 'Any' ||
        _selectedLocation != 'Any' ||
        _maxPrice.isFinite ||
        _selectedCondition != 'Any' ||
        _selectedSize != 'Any' ||
        _transactionType != 'Rental';
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * 0.88;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFD9D9D9),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
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
                  if (_hasActiveFilters)
                    TextButton(
                      onPressed: _resetFilters,
                      child: const Text(
                        'Reset',
                        style: TextStyle(color: primaryRed),
                      ),
                    ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Sport Category'),
                    const SizedBox(height: 8),
                    _buildDropdown(
                      value: _selectedCategory,
                      items: _categories,
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      },
                    ),
                    const SizedBox(height: 20),

                    _buildLabel('Location'),
                    const SizedBox(height: 8),
                    _buildDropdown(
                      value: _selectedLocation,
                      items: _locations,
                      onChanged: (value) {
                        setState(() {
                          _selectedLocation = value;
                        });
                      },
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Location filtering requires location data in equipment listings.',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF888888),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Maximum Price (Per Day)',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: darkText,
                            ),
                          ),
                        ),
                        Text(
                          _formatPrice(_maxPrice),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: primaryRed,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Slider(
                      value: _maxPrice.isInfinite
                          ? sliderMaximum
                          : _maxPrice.clamp(0.0, sliderMaximum),
                      min: 0,
                      max: sliderMaximum,
                      divisions: 100,
                      activeColor: primaryRed,
                      inactiveColor: const Color(0xFFE5E5E5),
                      onChanged: (value) {
                        setState(() {
                          _maxPrice = value >= sliderMaximum
                              ? double.infinity
                              : value;
                        });
                      },
                    ),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Rs. 0',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF888888),
                          ),
                        ),
                        Text(
                          'Any price',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF888888),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    _buildLabel('Condition'),
                    const SizedBox(height: 8),
                    _buildDropdown(
                      value: _selectedCondition,
                      items: _conditions,
                      onChanged: (value) {
                        setState(() {
                          _selectedCondition = value;
                        });
                      },
                    ),
                    const SizedBox(height: 20),

                    _buildLabel('Size'),
                    const SizedBox(height: 8),
                    _buildDropdown(
                      value: _selectedSize,
                      items: _sizes,
                      onChanged: (value) {
                        setState(() {
                          _selectedSize = value;
                        });
                      },
                    ),
                    const SizedBox(height: 20),

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
                    const SizedBox(height: 6),
                    const Text(
                      'Exchange filtering requires transaction type data in Firestore.',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF888888),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Color(0xFFEEEEEE)),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: OutlinedButton(
                        onPressed: _resetFilters,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: primaryRed,
                          side: const BorderSide(color: primaryRed),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Reset'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _applyFilters,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryRed,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Apply Filters',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
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

  Widget _buildLabel(String label) {
    return Text(
      label,
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
    required ValueChanged<String> onChanged,
  }) {
    final selectedValue = items.contains(value) ? value : 'Any';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedValue,
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
          onChanged: (value) {
            if (value != null) {
              onChanged(value);
            }
          },
        ),
      ),
    );
  }

  Widget _buildTransactionOption({
    required String title,
    required String value,
  }) {
    final isSelected = _transactionType == value;

    return InkWell(
      onTap: () {
        setState(() {
          _transactionType = value;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 12),
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
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected
                  ? primaryRed
                  : const Color(0xFF999999),
              size: 20,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? primaryRed : darkText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
