// import 'package:flutter/material.dart';


// class AddEquipmentScreen extends StatefulWidget {
//   const AddEquipmentScreen({super.key});

//   @override
//   State<AddEquipmentScreen> createState() => _AddEquipmentScreenState();
// }

// class _AddEquipmentScreenState extends State<AddEquipmentScreen> {
//   static const Color primaryRed = Color(0xFFED1235);

//   final _formKey = GlobalKey<FormState>();

//   final nameController = TextEditingController();
//   final brandController = TextEditingController();
//   final sizeController = TextEditingController();
//   final priceController = TextEditingController();

//   String? selectedCategory;
//   String? selectedCondition;

//   @override
//   void dispose() {
//     nameController.dispose();
//     brandController.dispose();
//     sizeController.dispose();
//     priceController.dispose();
//     super.dispose();
//   }

//   InputDecoration _inputDecoration(String hint) {
//     return InputDecoration(
//       hintText: hint,
//       hintStyle: const TextStyle(
//         color: Color(0xFF999999),
//         fontSize: 15,
//       ),
//       contentPadding: const EdgeInsets.symmetric(
//         horizontal: 14,
//         vertical: 16,
//       ),
//       filled: true,
//       fillColor: Colors.white,
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(10),
//         borderSide: const BorderSide(
//           color: Color(0xFFDADADA),
//         ),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(10),
//         borderSide: const BorderSide(
//           color: primaryRed,
//           width: 1.4,
//         ),
//       ),
//       errorBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(10),
//         borderSide: const BorderSide(
//           color: Colors.red,
//         ),
//       ),
//     );
//   }

//   Widget _label(String text) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 7),
//       child: Text(
//         text,
//         style: const TextStyle(
//           fontSize: 14,
//           fontWeight: FontWeight.w700,
//           color: Color(0xFF222222),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,

//       body: SafeArea(
//         child: Center(
//           child: ConstrainedBox(
//             constraints: const BoxConstraints(maxWidth: 420),
//             child: Form(
//               key: _formKey,
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         IconButton(
//                           onPressed: () {
//                             Navigator.pop(context);
//                           },
//                           padding: EdgeInsets.zero,
//                           alignment: Alignment.centerLeft,
//                           icon: const Icon(
//                             Icons.arrow_back_ios_new,
//                             size: 23,
//                           ),
//                         ),

//                         const SizedBox(width: 2),

//                         const Text(
//                           'Add equipment',
//                           style: TextStyle(
//                             fontSize: 22,
//                             fontWeight: FontWeight.w700,
//                             color: primaryRed,
//                           ),
//                         ),
//                       ],
//                     ),

//                     const SizedBox(height: 30),

//                     _label('Equipment name'),

//                     TextFormField(
//                       controller: nameController,
//                       decoration: _inputDecoration(
//                         'e.g. Cricket Bat',
//                       ),
//                       validator: (value) {
//                         if (value == null || value.trim().isEmpty) {
//                           return 'Equipment name is required';
//                         }
//                         return null;
//                       },
//                     ),

//                     const SizedBox(height: 14),

//                     _label('Sport / category'),

//                     DropdownButtonFormField<String>(
//                       decoration: _inputDecoration('Select category'),
//                       value: selectedCategory,
//                       items: const [
//                         DropdownMenuItem(
//                           value: 'Cricket',
//                           child: Text('Cricket'),
//                         ),
//                         DropdownMenuItem(
//                           value: 'Football',
//                           child: Text('Football'),
//                         ),
//                         DropdownMenuItem(
//                           value: 'Volleyball',
//                           child: Text('Volleyball'),
//                         ),
//                         DropdownMenuItem(
//                           value: 'Swimming',
//                           child: Text('Swimming'),
//                         ),
//                         DropdownMenuItem(
//                           value: 'Cycling',
//                           child: Text('Cycling'),
//                         ),
//                         DropdownMenuItem(
//                           value: 'Hockey',
//                           child: Text('Hockey'),
//                         ),
//                       ],
//                       onChanged: (value) {
//                         setState(() {
//                           selectedCategory = value;
//                         });
//                       },
//                     ),

//                     const SizedBox(height: 14),

//                     _label('Brand'),

//                     TextFormField(
//                       controller: brandController,
//                       decoration: _inputDecoration('Brand name'),
//                     ),

//                     const SizedBox(height: 14),

//                     _label('Size'),

//                     TextFormField(
//                       controller: sizeController,
//                       decoration: _inputDecoration('Size'),
//                     ),

//                     const SizedBox(height: 14),

//                     _label('Condition'),

//                     DropdownButtonFormField<String>(
//                       decoration: _inputDecoration(
//                         'Excellent / Good / Fair',
//                       ),
//                       value: selectedCondition,
//                       items: const [
//                         DropdownMenuItem(
//                           value: 'Excellent',
//                           child: Text('Excellent'),
//                         ),
//                         DropdownMenuItem(
//                           value: 'Good',
//                           child: Text('Good'),
//                         ),
//                         DropdownMenuItem(
//                           value: 'Fair',
//                           child: Text('Fair'),
//                         ),
//                       ],
//                       onChanged: (value) {
//                         setState(() {
//                           selectedCondition = value;
//                         });
//                       },
//                     ),

//                     const SizedBox(height: 14),

//                     _label('Rental price'),

//                     TextFormField(
//                       controller: priceController,
//                       keyboardType: TextInputType.number,
//                       decoration: _inputDecoration('Rs. per day'),
//                       validator: (value) {
//                         if (value == null || value.trim().isEmpty) {
//                           return 'Rental price is required';
//                         }
//                         return null;
//                       },
//                     ),

//                     const SizedBox(height: 24),

//                     InkWell(
//                       onTap: () {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(
//                             content: Text(
//                               'Photo upload will be added later.',
//                             ),
//                           ),
//                         );
//                       },
//                       borderRadius: BorderRadius.circular(12),
//                       child: Container(
//                         width: double.infinity,
//                         height: 105,
//                         decoration: BoxDecoration(
//                           color: const Color(0xFFF7F7F9),
//                           borderRadius: BorderRadius.circular(12),
//                           border: Border.all(
//                             color: const Color(0xFFD5D5D5),
//                           ),
//                         ),
//                         child: const Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(
//                               Icons.add,
//                               size: 28,
//                               color: Color(0xFF888888),
//                             ),
//                             SizedBox(height: 4),
//                             Text(
//                               'ADD PHOTOS',
//                               style: TextStyle(
//                                 fontSize: 15,
//                                 fontWeight: FontWeight.w700,
//                                 color: Color(0xFF888888),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),

//                     const SizedBox(height: 34),

//                     SizedBox(
//                       width: double.infinity,
//                       height: 52,
//                       child: ElevatedButton(
//                         onPressed: () {
//                           if (_formKey.currentState!.validate()) {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               const SnackBar(
//                                 content: Text(
//                                   'Listing ready to publish.',
//                                 ),
//                               ),
//                             );
//                           }
//                         },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: primaryRed,
//                           foregroundColor: Colors.white,
//                           elevation: 0,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(9),
//                           ),
//                         ),
//                         child: const Text(
//                           'Publish listing',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w700,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../features/user_discovery/services/auth_service.dart';

class AddEquipmentScreen extends StatefulWidget {
  const AddEquipmentScreen({super.key});

  @override
  State<AddEquipmentScreen> createState() => _AddEquipmentScreenState();
}

class _AddEquipmentScreenState extends State<AddEquipmentScreen> {
  static const Color primaryRed = Color(0xFFED1235);

  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController brandController = TextEditingController();
  final TextEditingController sizeController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  String? selectedSport;
  String? selectedCondition;

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
  void dispose() {
    nameController.dispose();
    brandController.dispose();
    sizeController.dispose();
    priceController.dispose();
    super.dispose();
  }

  Future<void> _publishListing() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedSport == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a sport/category'),
        ),
      );
      return;
    }

    if (selectedCondition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select equipment condition'),
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
          .add({
        'name': nameController.text.trim(),
        'category': selectedSport,
        'brand': brandController.text.trim(),
        'size': sizeController.text.trim(),
        'condition': selectedCondition,
        'pricePerDay':
            double.parse(priceController.text.trim()),

        // Temporary until Firebase Authentication is connected
        'providerId': AuthService.providerId,

        'status': 'Available',
        'isAvailable': true,

        // Image upload will be connected later
        'imageUrl': '',

        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Equipment published successfully!',
          ),
        ),
      );

      Navigator.pop(context);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to publish equipment: $error',
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 420,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
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
                          padding: EdgeInsets.zero,
                          constraints:
                              const BoxConstraints(),
                          icon: const Icon(
                            Icons.arrow_back_ios_new,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Text(
                          'Add Equipment',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    _label('Equipment Name'),

                    const SizedBox(height: 8),

                    TextFormField(
                      controller: nameController,
                      decoration: _inputDecoration(
                        'Example: SS Cricket Bat',
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty) {
                          return 'Please enter equipment name';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    _label('Sport / Category'),

                    const SizedBox(height: 8),

                    DropdownButtonFormField<String>(
                      value: selectedSport,
                      decoration: _inputDecoration(
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
                          selectedSport = value;
                        });
                      },
                    ),

                    const SizedBox(height: 20),

                    _label('Brand'),

                    const SizedBox(height: 8),

                    TextFormField(
                      controller: brandController,
                      decoration: _inputDecoration(
                        'Example: SS',
                      ),
                    ),

                    const SizedBox(height: 20),

                    _label('Size'),

                    const SizedBox(height: 8),

                    TextFormField(
                      controller: sizeController,
                      decoration: _inputDecoration(
                        'Example: Standard',
                      ),
                    ),

                    const SizedBox(height: 20),

                    _label('Condition'),

                    const SizedBox(height: 8),

                    DropdownButtonFormField<String>(
                      value: selectedCondition,
                      decoration: _inputDecoration(
                        'Select condition',
                      ),
                      items: conditions.map((condition) {
                        return DropdownMenuItem(
                          value: condition,
                          child: Text(condition),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCondition = value;
                        });
                      },
                    ),

                    const SizedBox(height: 20),

                    _label('Rental Price Per Day'),

                    const SizedBox(height: 8),

                    TextFormField(
                      controller: priceController,
                      keyboardType:
                          const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: _inputDecoration(
                        'Example: 1200',
                        prefixText: 'Rs. ',
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty) {
                          return 'Please enter rental price';
                        }

                        final price =
                            double.tryParse(value.trim());

                        if (price == null ||
                            price <= 0) {
                          return 'Please enter a valid price';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    // Add photos placeholder
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 28,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F8F8),
                        borderRadius:
                            BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFFDADADA),
                        ),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.add_a_photo_outlined,
                            size: 34,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Add Photos',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            'Photo upload will be connected later',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Publish button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed:
                            isSaving ? null : _publishListing,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryRed,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                              const Color(0xFFBBBBBB),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(28),
                          ),
                        ),
                        child: isSaving
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child:
                                    CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Publish Listing',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight:
                                      FontWeight.w800,
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
      hintStyle: const TextStyle(
        color: Colors.grey,
        fontSize: 14,
      ),
      filled: true,
      fillColor: const Color(0xFFFAFAFA),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFFDDDDDD),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFFDDDDDD),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: primaryRed,
          width: 1.5,
        ),
      ),
    );
  }
}