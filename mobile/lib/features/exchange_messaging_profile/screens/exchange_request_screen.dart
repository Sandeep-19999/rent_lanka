import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

import '../../provider/services/cloudinary_service.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/exchange_equipment_rules.dart';

import '../services/exchange_service.dart';
import 'exchange_status_screen.dart';

class ExchangeRequestScreen extends StatefulWidget {
  final String requestedEquipmentId;
  final String requestedEquipmentName;
  final String requestedProviderId;

  const ExchangeRequestScreen({
    super.key,
    required this.requestedEquipmentId,
    required this.requestedEquipmentName,
    required this.requestedProviderId,
  });

  @override
  State<ExchangeRequestScreen> createState() => _ExchangeRequestScreenState();
}

class _ExchangeRequestScreenState extends State<ExchangeRequestScreen> {
  static const Color primaryRed = Color(0xFFED1235);
  static const Color darkText = Color(0xFF242424);
  static const Color greyText = Color(0xFF7A7A7A);
  static const Color borderColor = Color(0xFFE5E5E5);
  static const Color backgroundColor = Color(0xFFF8F8F8);

  final ExchangeService _exchangeService = ExchangeService();
  final TextEditingController _messageController = TextEditingController();

  final _offerTitle = TextEditingController();
  final _offerDetails = TextEditingController();
  bool _enterOffer = true;
  bool _isPickingPhoto = false;
  Uint8List? _offerPhoto;
  String _photoName = 'offer.jpg';
  CloudinaryUploadResult? _uploadedPhoto;

  String? _selectedEquipmentId;
  String? _selectedEquipmentName;

  bool _isSubmitting = false;
  late Stream<QuerySnapshot<Map<String, dynamic>>> _equipmentStream;
  String? _equipmentOwnerId;
  late final Stream<User?> _authChanges;

  @override
  void initState() {
    super.initState();
    _equipmentOwnerId = FirebaseAuth.instance.currentUser?.uid;
    _authChanges = FirebaseAuth.instance.authStateChanges();
    _equipmentStream = _exchangeService.watchMyEquipment();
  }

  @override
  void dispose() {
    _offerTitle.dispose();
    _offerDetails.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendExchangeRequest() async {
    if (_isSubmitting) return;
    if (FirebaseAuth.instance.currentUser == null) {
      _showMessage('Please log in to send an exchange request.');
      return;
    }
    if (_enterOffer &&
        (_offerTitle.text.trim().isEmpty ||
            _offerDetails.text.trim().isEmpty)) {
      _showMessage('Please enter your equipment title and details.');
      return;
    }
    if (!_enterOffer &&
        (_selectedEquipmentId == null || _selectedEquipmentName == null)) {
      _showMessage('Please select equipment to offer.');
      return;
    }

    final submittingUid = FirebaseAuth.instance.currentUser!.uid;
    setState(() {
      _isSubmitting = true;
    });

    try {
      if (_enterOffer && _offerPhoto != null) {
        _uploadedPhoto ??= await CloudinaryService().uploadImage(
          _offerPhoto!,
          filename: _photoName,
        );
      }
      if (FirebaseAuth.instance.currentUser?.uid != submittingUid) {
        throw Exception(
          'Your login changed. Please reopen the exchange request.',
        );
      }
      final requestId = await _exchangeService.sendExchangeRequest(
        requestedProviderId: widget.requestedProviderId,
        requestedEquipmentId: widget.requestedEquipmentId,
        requestedEquipmentName: widget.requestedEquipmentName,
        offeredEquipmentId: _enterOffer ? '' : _selectedEquipmentId!,
        offeredEquipmentName: _enterOffer
            ? _offerTitle.text.trim()
            : _selectedEquipmentName!,
        offeredEquipmentDetails: _enterOffer ? _offerDetails.text.trim() : null,
        offeredEquipmentImageUrl: _enterOffer
            ? _uploadedPhoto?.secureUrl ?? ''
            : '',
        offeredEquipmentImagePublicId: _enterOffer
            ? _uploadedPhoto?.publicId
            : null,
        message: _messageController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Exchange request sent successfully.'),
          backgroundColor: Color(0xFF2E9B50),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ExchangeStatusScreen(exchangeRequestId: requestId),
        ),
      );
    } on FirebaseException catch (error) {
      if (!mounted) return;

      _showMessage(error.message ?? 'Unable to send exchange request.');
    } catch (error) {
      if (!mounted) return;

      _showMessage(error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authChanges,
      builder: (context, authSnapshot) {
        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid != _equipmentOwnerId) {
          _equipmentOwnerId = uid;
          _selectedEquipmentId = null;
          _selectedEquipmentName = null;
          _offerTitle.clear();
          _offerDetails.clear();
          _offerPhoto = null;
          _uploadedPhoto = null;
          _equipmentStream = _exchangeService.watchMyEquipment();
        }
        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          key: ValueKey(uid),
          stream: _equipmentStream,
          builder: (context, snapshot) => _buildPage(context, snapshot),
        );
      },
    );
  }

  Widget _buildPage(
    BuildContext context,
    AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot,
  ) {
    final documents =
        snapshot.hasError || snapshot.connectionState != ConnectionState.active
        ? <QueryDocumentSnapshot<Map<String, dynamic>>>[]
        : snapshot.data?.docs
                  .where(
                    (doc) => ExchangeEquipmentRules.canOffer(
                      userId: FirebaseAuth.instance.currentUser?.uid ?? '',
                      equipmentId: doc.id,
                      requestedEquipmentId: widget.requestedEquipmentId,
                      data: doc.data(),
                    ),
                  )
                  .toList() ??
              [];
    final hasValidSelection = documents.any(
      (doc) => doc.id == _selectedEquipmentId,
    );
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: darkText,
          ),
        ),
        titleSpacing: 0,
        title: const Text(
          'Exchange Request',
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
            constraints: const BoxConstraints(maxWidth: 500),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Make an exchange offer',
                    style: TextStyle(
                      color: darkText,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Add the equipment you want to offer, or choose one of your listed items.',
                    style: TextStyle(
                      color: greyText,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'You want',
                    style: TextStyle(
                      color: darkText,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),

                  _buildRequestedItemCard(),

                  const SizedBox(height: 24),

                  const Text(
                    'You offer',
                    style: TextStyle(
                      color: darkText,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: _isSubmitting
                              ? null
                              : () => setState(() => _enterOffer = true),
                          child: Text(
                            'Add your equipment',
                            style: TextStyle(
                              color: _enterOffer ? primaryRed : greyText,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextButton(
                          onPressed: _isSubmitting
                              ? null
                              : () => setState(() => _enterOffer = false),
                          child: Text(
                            'Choose listed equipment',
                            style: TextStyle(
                              color: !_enterOffer ? primaryRed : greyText,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_enterOffer)
                    _buildOfferForm()
                  else
                    _buildEquipmentDropdown(snapshot, documents),

                  if (!_enterOffer &&
                      hasValidSelection &&
                      _selectedEquipmentName != null) ...[
                    const SizedBox(height: 12),
                    _buildSelectedOfferCard(),
                  ],

                  const SizedBox(height: 26),

                  const Text(
                    'Message',
                    style: TextStyle(
                      color: darkText,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Add a short note for the equipment owner.',
                    style: TextStyle(color: greyText, fontSize: 13),
                  ),
                  const SizedBox(height: 10),

                  TextField(
                    controller: _messageController,
                    minLines: 4,
                    maxLines: 5,
                    textInputAction: TextInputAction.newline,
                    decoration: InputDecoration(
                      hintText: 'Example: My item is in good condition. Would you like to exchange?',
                      hintStyle: const TextStyle(
                        color: Color(0xFFA0A0A0),
                        fontSize: 13,
                        height: 1.4,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.all(16),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: primaryRed,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF4F6),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: primaryRed,
                          size: 20,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'The equipment owner will review your offer before the exchange is confirmed.',
                            style: TextStyle(
                              color: Color(0xFF656565),
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(18, 10, 18, 16),
        child: SizedBox(
          height: 54,
          child: ElevatedButton(
            onPressed:
                _isSubmitting ||
                    _isPickingPhoto ||
                    FirebaseAuth.instance.currentUser == null ||
                    (_enterOffer
                        ? _offerTitle.text.trim().isEmpty ||
                              _offerDetails.text.trim().isEmpty
                        : !hasValidSelection)
                ? null
                : _sendExchangeRequest,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryRed,
              foregroundColor: Colors.white,
              disabledBackgroundColor: primaryRed.withValues(alpha: 0.55),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: Colors.white,
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.swap_horiz_rounded),
                      SizedBox(width: 8),
                      Text(
                        'Send Exchange Request',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickOfferPhoto() async {
    if (_isSubmitting || _isPickingPhoto) return;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    setState(() => _isPickingPhoto = true);
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1280,
        maxHeight: 1280,
        imageQuality: 75,
      );
      if (image == null) return;
      final bytes = await image.readAsBytes();
      if (bytes.length > 10 * 1024 * 1024) {
        throw Exception('Please choose a photo smaller than 10 MB.');
      }
      if (!mounted || FirebaseAuth.instance.currentUser?.uid != uid) return;
      setState(() {
        _offerPhoto = bytes;
        _photoName = image.name;
        _uploadedPhoto = null;
      });
    } catch (error) {
      if (mounted) _showMessage('Unable to select photo: $error');
    } finally {
      if (mounted) setState(() => _isPickingPhoto = false);
    }
  }

  Widget _buildOfferForm() {
    InputDecoration decoration(String label, String hint) => InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _offerTitle,
          enabled: !_isSubmitting,
          maxLength: 120,
          onChanged: (_) => setState(() {}),
          decoration: decoration('Equipment title', 'Example: Cricket bat'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _offerDetails,
          enabled: !_isSubmitting,
          minLines: 3,
          maxLines: 5,
          maxLength: 2000,
          onChanged: (_) => setState(() {}),
          decoration: decoration(
            'Equipment details',
            'Brand, size, condition and other details',
          ),
        ),
        const SizedBox(height: 12),
        if (_offerPhoto != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.memory(_offerPhoto!, height: 160, fit: BoxFit.cover),
          ),
        OutlinedButton.icon(
          onPressed: _isSubmitting || _isPickingPhoto ? null : _pickOfferPhoto,
          icon: const Icon(Icons.add_photo_alternate_outlined),
          label: Text(
            _isPickingPhoto
                ? 'Selecting photo…'
                : _offerPhoto == null
                ? 'Add photo (optional)'
                : 'Change photo',
          ),
        ),
        if (_offerPhoto != null)
          TextButton(
            onPressed: _isSubmitting
                ? null
                : () => setState(() {
                    _offerPhoto = null;
                    _uploadedPhoto = null;
                  }),
            child: const Text('Remove photo'),
          ),
      ],
    );
  }

  Widget _buildRequestedItemCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: const Color(0xFFFFEEF1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.sports_cricket_rounded,
              color: primaryRed,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Requested equipment',
                  style: TextStyle(color: greyText, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.requestedEquipmentName,
                  style: const TextStyle(
                    color: darkText,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_downward_rounded, color: primaryRed, size: 22),
        ],
      ),
    );
  }

  Widget _buildSelectedOfferCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF3FAF5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFCDE8D4)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: Color(0xFF2E9B50),
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Offering: $_selectedEquipmentName',
              style: const TextStyle(
                color: darkText,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEquipmentDropdown(
    AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot,
    List<QueryDocumentSnapshot<Map<String, dynamic>>> documents,
  ) {
    if (FirebaseAuth.instance.currentUser == null) {
      return _informationBox(
        text: 'Please log in to offer your equipment.',
        icon: Icons.login,
      );
    }
    if (snapshot.hasError) {
      return Column(
        children: [
          _informationBox(
            text: 'Unable to load your equipment. Please retry.',
            icon: Icons.error_outline_rounded,
          ),
          TextButton(
            onPressed: () => setState(() {
              _equipmentStream = _exchangeService.watchMyEquipment();
            }),
            child: const Text('Retry'),
          ),
        ],
      );
    }

    if (snapshot.connectionState == ConnectionState.waiting) {
      return Container(
        height: 58,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor),
        ),
        child: const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(strokeWidth: 2.2, color: primaryRed),
        ),
      );
    }

    if (documents.isEmpty) {
      return _informationBox(
        text: 'You do not have any available equipment to offer right now.',
        icon: Icons.inventory_2_outlined,
      );
    }

    final validSelectedId =
        documents.any((document) => document.id == _selectedEquipmentId)
        ? _selectedEquipmentId
        : null;

    return DropdownButtonFormField<String>(
      key: ValueKey(validSelectedId),
      initialValue: validSelectedId,
      isExpanded: true,
      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: darkText),
      hint: const Text(
        'Select equipment to offer',
        style: TextStyle(color: Color(0xFF9B9B9B), fontSize: 14),
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryRed, width: 1.5),
        ),
      ),
      items: documents.map((document) {
        final data = document.data();

        final String equipmentName = data['name']?.toString() ?? 'Equipment';

        return DropdownMenuItem<String>(
          value: document.id,
          child: Text(
            equipmentName,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: darkText,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }).toList(),
      onChanged: _isSubmitting
          ? null
          : (equipmentId) {
              if (equipmentId == null) return;

              final selectedDocument = documents.firstWhere(
                (document) => document.id == equipmentId,
              );

              final selectedData = selectedDocument.data();

              setState(() {
                _selectedEquipmentId = selectedDocument.id;
                _selectedEquipmentName =
                    selectedData['name']?.toString() ?? 'Equipment';
              });
            },
    );
  }

  Widget _informationBox({required String text, required IconData icon}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Icon(icon, size: 21, color: greyText),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: greyText, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
