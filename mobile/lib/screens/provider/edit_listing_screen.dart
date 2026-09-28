import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditListingScreen extends StatefulWidget {
  final String equipmentId;

  const EditListingScreen({
    super.key,
    required this.equipmentId,
  });

  @override
  State<EditListingScreen> createState() =>
      _EditListingScreenState();
}

class _EditListingScreenState extends State<EditListingScreen> {
  static const Color primaryRed = Color(0xFFED1235);

  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController =
      TextEditingController();

  final TextEditingController brandController =
      TextEditingController();

  final TextEditingController sizeController =
      TextEditingController();

  final TextEditingController priceController =
      TextEditingController();

  String? selectedSport;
  String? selectedCondition;

  bool isLoading = true;
  bool isSaving = false;

  final List<String> sports = [
    'Cricket',
    'Football',
    'Volleyball',
    'Swimming',
    'Cycling',
    'Hockey',
    'Tennis',
    'Badminton',
  ];

  final List<String> conditions = [
    'Excellent',
    'Good',
    'Fair',
  ];

  @override
  void initState() {
    super.initState();
    _loadEquipment();
  }

  Future<void> _loadEquipment() async {
    try {
      final document = await FirebaseFirestore.instance
          .collection('equipment')
          .doc(widget.equipmentId)
          .get();

      if (!document.exists) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Equipment not found'),
          ),
        );

        Navigator.pop(context);
        return;
      }

      final data =
          document.data() as Map<String, dynamic>;

      nameController.text =
          data['name']?.toString() ?? '';

      brandController.text =
          data['brand']?.toString() ?? '';

      sizeController.text =
          data['size']?.toString() ?? '';

      final price = data['pricePerDay'];

      if (price is num) {
        if (price.toDouble() ==
            price.toDouble().roundToDouble()) {
          priceController.text =
              price.toInt().toString();
        } else {
          priceController.text =
              price.toString();
        }
      }

      final category =
          data['category']?.toString();

      final condition =
          data['condition']?.toString();

      setState(() {
        if (sports.contains(category)) {
          selectedSport = category;
        }

        if (conditions.contains(condition)) {
          selectedCondition = condition;
        }

        isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to load equipment: $error',
          ),
        ),
      );
    }
  }

  Future<void> _updateListing() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedSport == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select a sport/category',
          ),
        ),
      );
      return;
    }

    if (selectedCondition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select equipment condition',
          ),
        ),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('equipment')
          .doc(widget.equipmentId)
          .update({
        'name': nameController.text.trim(),
        'category': selectedSport,
        'brand': brandController.text.trim(),
        'size': sizeController.text.trim(),
        'condition': selectedCondition,
        'pricePerDay': double.parse(
          priceController.text.trim(),
        ),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Listing updated successfully!',
          ),
        ),
      );

      Navigator.pop(context);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to update listing: $error',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    brandController.dispose();
    sizeController.dispose();
    priceController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(maxWidth: 420),
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: primaryRed,
                    ),
                  )
                : SingleChildScrollView(
                    padding:
                        const EdgeInsets.fromLTRB(
                      20,
                      18,
                      20,
                      30,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          // Header
                          Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                padding:
                                    EdgeInsets.zero,
                                constraints:
                                    const BoxConstraints(),
                                icon: const Icon(
                                  Icons
                                      .arrow_back_ios_new,
                                  size: 22,
                                ),
                              ),

                              const SizedBox(
                                width: 14,
                              ),

                              const Text(
                                'Edit Listing',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight:
                                      FontWeight.w800,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 30),

                          _label('Equipment Name'),

                          const SizedBox(height: 8),

                          TextFormField(
                            controller:
                                nameController,
                            decoration:
                                _inputDecoration(
                              'Equipment name',
                            ),
                            validator: (value) {
                              if (value == null ||
                                  value
                                      .trim()
                                      .isEmpty) {
                                return 'Please enter equipment name';
                              }

                              return null;
                            },
                          ),

                          const SizedBox(height: 20),

                          _label(
                            'Sport / Category',
                          ),

                          const SizedBox(height: 8),

                          DropdownButtonFormField<
                              String>(
                            value: selectedSport,
                            decoration:
                                _inputDecoration(
                              'Select category',
                            ),
                            items: sports.map((sport) {
                              return DropdownMenuItem(
                                value: sport,
                                child: Text(sport),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedSport =
                                    value;
                              });
                            },
                          ),

                          const SizedBox(height: 20),

                          _label('Brand'),

                          const SizedBox(height: 8),

                          TextFormField(
                            controller:
                                brandController,
                            decoration:
                                _inputDecoration(
                              'Brand',
                            ),
                          ),

                          const SizedBox(height: 20),

                          _label('Size'),

                          const SizedBox(height: 8),

                          TextFormField(
                            controller:
                                sizeController,
                            decoration:
                                _inputDecoration(
                              'Size',
                            ),
                          ),

                          const SizedBox(height: 20),

                          _label('Condition'),

                          const SizedBox(height: 8),

                          DropdownButtonFormField<
                              String>(
                            value:
                                selectedCondition,
                            decoration:
                                _inputDecoration(
                              'Select condition',
                            ),
                            items: conditions
                                .map((condition) {
                              return DropdownMenuItem(
                                value: condition,
                                child:
                                    Text(condition),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedCondition =
                                    value;
                              });
                            },
                          ),

                          const SizedBox(height: 20),

                          _label(
                            'Rental Price Per Day',
                          ),

                          const SizedBox(height: 8),

                          TextFormField(
                            controller:
                                priceController,
                            keyboardType:
                                const TextInputType
                                    .numberWithOptions(
                              decimal: true,
                            ),
                            decoration:
                                _inputDecoration(
                              'Rental price',
                              prefixText: 'Rs. ',
                            ),
                            validator: (value) {
                              if (value == null ||
                                  value
                                      .trim()
                                      .isEmpty) {
                                return 'Please enter rental price';
                              }

                              final price =
                                  double.tryParse(
                                value.trim(),
                              );

                              if (price == null ||
                                  price <= 0) {
                                return 'Please enter a valid price';
                              }

                              return null;
                            },
                          ),

                          const SizedBox(height: 30),

                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: isSaving
                                  ? null
                                  : _updateListing,
                              style: ElevatedButton
                                  .styleFrom(
                                backgroundColor:
                                    primaryRed,
                                foregroundColor:
                                    Colors.white,
                                disabledBackgroundColor:
                                    const Color(
                                  0xFFBBBBBB,
                                ),
                                elevation: 0,
                                shape:
                                    RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    28,
                                  ),
                                ),
                              ),
                              child: isSaving
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child:
                                          CircularProgressIndicator(
                                        strokeWidth:
                                            2.5,
                                        color:
                                            Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'Update Listing',
                                      style:
                                          TextStyle(
                                        fontSize:
                                            16,
                                        fontWeight:
                                            FontWeight
                                                .w800,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  InputDecoration _inputDecoration(
    String hint, {
    String? prefixText,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixText: prefixText,
      filled: true,
      fillColor: const Color(0xFFFAFAFA),
      contentPadding:
          const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFFDDDDDD),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: primaryRed,
          width: 1.5,
        ),
      ),
    );
  }
}