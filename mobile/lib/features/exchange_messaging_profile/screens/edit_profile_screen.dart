import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/profile_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() =>
      _EditProfileScreenState();
}

class _EditProfileScreenState
    extends State<EditProfileScreen> {
  static const Color primaryRed = Color(0xFFED1235);
  static const Color darkText = Color(0xFF242424);
  static const Color borderColor = Color(0xFFE4E4E4);
  static const Color backgroundColor = Color(0xFFF8F8F8);

  final ProfileService _profileService =
      ProfileService();

  final ImagePicker _imagePicker =
      ImagePicker();

  final TextEditingController
      _nameController =
      TextEditingController();

  final TextEditingController
      _emailController =
      TextEditingController();

  final TextEditingController
      _phoneController =
      TextEditingController();

  final TextEditingController
      _locationController =
      TextEditingController();

  Uint8List? _selectedImageBytes;
  String? _selectedImageFileName;

  String _existingPhotoUrl = '';

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final document =
          await _profileService.getProfile();

      final data = document.data();

      final User? firebaseUser =
          FirebaseAuth.instance.currentUser;

      _nameController.text =
          data?['name']?.toString() ??
              firebaseUser?.displayName ??
              '';

      _emailController.text =
          data?['email']?.toString() ??
              firebaseUser?.email ??
              '';

      _phoneController.text =
          data?['phone']?.toString() ??
              firebaseUser?.phoneNumber ??
              '';

      _locationController.text =
          data?['location']?.toString() ?? '';

      _existingPhotoUrl =
          data?['photoUrl']?.toString() ?? '';
    } catch (error) {
      if (!mounted) return;

      _showMessage(
        'Unable to load profile: $error',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickProfilePhoto() async {
    try {
      final XFile? image =
          await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1200,
      );

      if (image == null) {
        return;
      }

      final Uint8List bytes =
          await image.readAsBytes();

      if (!mounted) return;

      setState(() {
        _selectedImageBytes = bytes;
        _selectedImageFileName = image.name;
      });
    } catch (error) {
      if (!mounted) return;

      _showMessage(
        'Unable to select photo: $error',
      );
    }
  }

  Future<void> _saveChanges() async {
    FocusScope.of(context).unfocus();

    final String name =
        _nameController.text.trim();

    final String email =
        _emailController.text.trim();

    final String phone =
        _phoneController.text.trim();

    final String location =
        _locationController.text.trim();

    if (name.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        location.isEmpty) {
      _showMessage(
        'Please complete all fields.',
      );
      return;
    }

    if (!_isValidEmail(email)) {
      _showMessage(
        'Please enter a valid email address.',
      );
      return;
    }

    if (phone.length < 9) {
      _showMessage(
        'Please enter a valid phone number.',
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      String photoUrl =
          _existingPhotoUrl;

      if (_selectedImageBytes != null &&
          _selectedImageFileName != null) {
        photoUrl =
            await _profileService
                .uploadProfilePhoto(
          imageBytes:
              _selectedImageBytes!,
          fileName:
              _selectedImageFileName!,
        );
      }

      await _profileService.saveProfile(
        name: name,
        email: email,
        phone: phone,
        location: location,
        photoUrl: photoUrl,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Profile updated successfully.',
          ),
          backgroundColor:
              Color(0xFF2E9B50),
        ),
      );

      Navigator.pop(context);
    } catch (error) {
      if (!mounted) return;

      _showMessage(
        'Unable to update profile: $error',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  bool _isValidEmail(
    String email,
  ) {
    return RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    ).hasMatch(email);
  }

  void _showMessage(
    String message,
  ) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: backgroundColor,
        body: Center(
          child: CircularProgressIndicator(
            color: primaryRed,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.maybePop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: darkText,
          ),
        ),
        titleSpacing: 0,
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: darkText,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 500,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                18,
                22,
                18,
                120,
              ),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 22, 20, 12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFFFFEEF1), Colors.white],
                        begin: Alignment.topCenter, end: Alignment.bottomCenter),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFFFDFE6)),
                    ),
                    child: Column(children: [
                      _buildProfilePhoto(),
                      const Text('A familiar face builds trust.',
                        style: TextStyle(fontSize: 12, color: Color(0xFF85858F))),
                      const SizedBox(height: 8),
                    ]),
                  ),

                  const SizedBox(height: 20),

                  _buildFormCard(),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(
          18,
          10,
          18,
          16,
        ),
        child: SizedBox(
          height: 54,
          child: ElevatedButton(
            onPressed:
                _isSaving
                    ? null
                    : _saveChanges,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryRed,
              foregroundColor: Colors.white,
              disabledBackgroundColor:
                  primaryRed.withValues(
                alpha: 0.55,
              ),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(
                  14,
                ),
              ),
            ),
            child: _isSaving
                ? const Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Saving...',
                        style: TextStyle(
                          fontWeight:
                              FontWeight.w700,
                        ),
                      ),
                    ],
                  )
                : const Text(
                    'Save Changes',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePhoto() {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 112,
              height: 112,
              clipBehavior:
                  Clip.antiAlias,
              decoration: BoxDecoration(
                color:
                    const Color(0xFFFFEEF1),
                shape: BoxShape.circle,
                border: Border.all(
                  color:
                      const Color(0xFFFFD4DB),
                  width: 3,
                ),
              ),
              child: _profilePhotoWidget(),
            ),

            Positioned(
              right: 0,
              bottom: 4,
              child: InkWell(
                onTap: _isSaving
                    ? null
                    : _pickProfilePhoto,
                borderRadius:
                    BorderRadius.circular(50),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration:
                      const BoxDecoration(
                    color: primaryRed,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt_outlined,
                    color: Colors.white,
                    size: 19,
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        TextButton.icon(
          onPressed: _isSaving
              ? null
              : _pickProfilePhoto,
          icon: const Icon(
            Icons.photo_library_outlined,
            size: 18,
          ),
          label: const Text(
            'Change profile photo',
            style: TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
          style: TextButton.styleFrom(
            foregroundColor: primaryRed,
          ),
        ),
      ],
    );
  }

  Widget _profilePhotoWidget() {
    if (_selectedImageBytes != null) {
      return Image.memory(
        _selectedImageBytes!,
        fit: BoxFit.cover,
      );
    }

    if (_existingPhotoUrl.isNotEmpty) {
      return Image.network(
        _existingPhotoUrl,
        fit: BoxFit.cover,
        errorBuilder: (
          context,
          error,
          stackTrace,
        ) {
          return const Icon(
            Icons.person_rounded,
            size: 65,
            color: primaryRed,
          );
        },
      );
    }

    return const Icon(
      Icons.person_rounded,
      size: 65,
      color: primaryRed,
    );
  }

  Widget _buildFormCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'Personal Information',
            style: TextStyle(
              color: darkText,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 20),

          _buildLabel(
            'Full Name',
          ),

          const SizedBox(height: 7),

          _buildTextField(
            controller: _nameController,
            icon: Icons.person_outline_rounded,
            hintText: 'Enter your full name',
            keyboardType:
                TextInputType.name,
          ),

          const SizedBox(height: 17),

          _buildLabel(
            'Email Address',
          ),

          const SizedBox(height: 7),

          _buildTextField(
            controller: _emailController,
            icon: Icons.mail_outline_rounded,
            hintText: 'Enter your email address',
            keyboardType:
                TextInputType.emailAddress,
          ),

          const SizedBox(height: 17),

          _buildLabel(
            'Phone Number',
          ),

          const SizedBox(height: 7),

          _buildTextField(
            controller: _phoneController,
            icon: Icons.phone_outlined,
            hintText: '+94 77 123 4567',
            keyboardType:
                TextInputType.phone,
          ),

          const SizedBox(height: 17),

          _buildLabel(
            'Location',
          ),

          const SizedBox(height: 7),

          _buildTextField(
            controller:
                _locationController,
            icon:
                Icons.location_on_outlined,
            hintText:
                'Example: Colombo',
            keyboardType:
                TextInputType.streetAddress,
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(
    String text,
  ) {
    return Text(
      text,
      style: const TextStyle(
        color: darkText,
        fontSize: 13,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController
        controller,
    required IconData icon,
    required String hintText,
    required TextInputType
        keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      enabled: !_isSaving,
      style: const TextStyle(
        color: darkText,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          color: Color(0xFFAAAAAA),
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
        prefixIcon: Icon(
          icon,
          color: const Color(0xFF929292),
          size: 21,
        ),
        filled: true,
        fillColor: const Color(0xFFFAFAFA),
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(13),
          borderSide: const BorderSide(
            color: borderColor,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(13),
          borderSide: const BorderSide(
            color: primaryRed,
            width: 1.4,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(13),
          borderSide: const BorderSide(
            color: borderColor,
          ),
        ),
      ),
    );
  }
}