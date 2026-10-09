import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

import '../services/equipment_service.dart';
import '../services/cloudinary_service.dart';

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

  final EquipmentService _equipmentService = EquipmentService();

  String? selectedSport;
  String? selectedCondition;

  bool isSaving = false;
  Uint8List? _photo;
  String _photoFilename = 'equipment.jpg';
  CloudinaryUploadResult? _uploadedPhoto;
  final TextEditingController descriptionController = TextEditingController();

  Future<void> _pickPhoto() async {
    if (isSaving) return;
    try {
      final file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1280,
        maxHeight: 1280,
        imageQuality: 75,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      if (bytes.length > 10 * 1024 * 1024) {
        throw Exception('Please choose an image smaller than 10 MB.');
      }
      if (!mounted) return;
      setState(() {
        _photo = bytes;
        _photoFilename = file.name;
        _uploadedPhoto = null;
      });
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$error')));
      }
    }
  }

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

  final List<String> conditions = ['Excellent', 'Good', 'Fair'];

  @override
  void dispose() {
    descriptionController.dispose();
    nameController.dispose();
    brandController.dispose();
    sizeController.dispose();
    priceController.dispose();

    super.dispose();
  }

  Future<void> _publishListing() async {
    if (isSaving) return;
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedSport == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a sport/category')),
      );

      return;
    }

    if (selectedCondition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select equipment condition')),
      );

      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      if (_photo != null) {
        _uploadedPhoto ??= await CloudinaryService().uploadImage(
          _photo!,
          filename: _photoFilename,
        );
      }
      await _equipmentService.addEquipment(
        name: nameController.text.trim(),
        category: selectedSport!,
        brand: brandController.text.trim(),
        size: sizeController.text.trim(),
        condition: selectedCondition!,
        imageUrl: _uploadedPhoto?.secureUrl ?? '',
        imagePublicId: _uploadedPhoto?.publicId,
        description: descriptionController.text,
        pricePerDay: double.parse(priceController.text.trim()),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Equipment published successfully!')),
      );

      Navigator.pop(context);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _uploadedPhoto == null
                ? 'Failed to publish equipment: $error'
                : 'Photo uploaded, but equipment could not be saved. Retry Publish to reuse the photo. $error',
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
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.arrow_back_ios_new, size: 22),
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
                      decoration: _inputDecoration('Example: SS Cricket Bat'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
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
                      decoration: _inputDecoration('Select category'),
                      items: sports.map((sport) {
                        return DropdownMenuItem<String>(
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
                      decoration: _inputDecoration('Example: SS'),
                    ),

                    const SizedBox(height: 20),

                    _label('Size'),

                    const SizedBox(height: 8),

                    TextFormField(
                      controller: sizeController,
                      decoration: _inputDecoration('Example: Standard'),
                    ),

                    const SizedBox(height: 20),

                    _label('Condition'),

                    const SizedBox(height: 8),

                    DropdownButtonFormField<String>(
                      value: selectedCondition,
                      decoration: _inputDecoration('Select condition'),
                      items: conditions.map((condition) {
                        return DropdownMenuItem<String>(
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
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: _inputDecoration(
                        'Example: 1200',
                        prefixText: 'Rs. ',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter rental price';
                        }

                        final price = double.tryParse(value.trim());

                        if (price == null || price <= 0) {
                          return 'Please enter a valid price';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    TextFormField(
                      controller: descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Description (optional)',
                      ),
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: isSaving ? null : _pickPhoto,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F8F8),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFDADADA)),
                        ),
                        child: _photo != null
                            ? Image.memory(
                                _photo!,
                                height: 150,
                                fit: BoxFit.contain,
                              )
                            : const Column(
                                children: [
                                  Icon(
                                    Icons.add_a_photo_outlined,
                                    size: 34,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 8),
                                  Text('Add Photos'),
                                  SizedBox(height: 5),
                                  Text('Choose an equipment image'),
                                ],
                              ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: isSaving ? null : _publishListing,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryRed,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: const Color(0xFFBBBBBB),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: isSaving
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Publish Listing',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
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
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
    );
  }

  InputDecoration _inputDecoration(String hint, {String? prefixText}) {
    return InputDecoration(
      hintText: hint,
      prefixText: prefixText,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
      filled: true,
      fillColor: const Color(0xFFFAFAFA),
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryRed, width: 1.5),
      ),
    );
  }
}
