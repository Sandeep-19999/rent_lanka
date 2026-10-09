import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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

  String? _selectedEquipmentId;
  String? _selectedEquipmentName;

  bool _isSubmitting = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendExchangeRequest() async {
    if (_selectedEquipmentId == null || _selectedEquipmentName == null) {
      _showMessage('Please select equipment to offer.');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final requestId = await _exchangeService.sendExchangeRequest(
        requestedProviderId: widget.requestedProviderId,
        requestedEquipmentId: widget.requestedEquipmentId,
        requestedEquipmentName: widget.requestedEquipmentName,
        offeredEquipmentId: _selectedEquipmentId!,
        offeredEquipmentName: _selectedEquipmentName!,
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
          builder: (_) => ExchangeStatusScreen(
            exchangeRequestId: requestId,
          ),
        ),
      );
    } on FirebaseException catch (error) {
      if (!mounted) return;

      _showMessage(
        error.message ?? 'Unable to send exchange request.',
      );
    } catch (error) {
      if (!mounted) return;

      _showMessage(
        error.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                    'Choose one of your available items and send an offer to the equipment owner.',
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

                  _buildEquipmentDropdown(),

                  if (_selectedEquipmentName != null) ...[
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
                    style: TextStyle(
                      color: greyText,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 10),

                  TextField(
                    controller: _messageController,
                    minLines: 4,
                    maxLines: 5,
                    textInputAction: TextInputAction.newline,
                    decoration: InputDecoration(
                      hintText:
                          'Example: My item is in good condition. Would you like to exchange?',
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
                        borderSide: const BorderSide(
                          color: borderColor,
                        ),
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
            onPressed: _isSubmitting ? null : _sendExchangeRequest,
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
                  style: TextStyle(
                    color: greyText,
                    fontSize: 12,
                  ),
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
          const Icon(
            Icons.arrow_downward_rounded,
            color: primaryRed,
            size: 22,
          ),
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
        border: Border.all(
          color: const Color(0xFFCDE8D4),
        ),
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

  Widget _buildEquipmentDropdown() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _exchangeService.watchMyEquipment(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _informationBox(
            text: 'Unable to load your equipment.',
            icon: Icons.error_outline_rounded,
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
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
                color: primaryRed,
              ),
            ),
          );
        }

        final documents =
            snapshot.data?.docs.where((document) {
              final data = document.data();

              final bool isAvailable = data['isAvailable'] != false;

              final bool isNotRequestedItem =
                  document.id != widget.requestedEquipmentId;

              return isAvailable && isNotRequestedItem;
            }).toList() ??
            [];

        if (documents.isEmpty) {
          return _informationBox(
            text:
                'You do not have any available equipment to offer right now.',
            icon: Icons.inventory_2_outlined,
          );
        }

        final validSelectedId =
            documents.any(
              (document) => document.id == _selectedEquipmentId,
            )
            ? _selectedEquipmentId
            : null;

        return DropdownButtonFormField<String>(
          key: ValueKey(validSelectedId),
          initialValue: validSelectedId,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: darkText,
          ),
          hint: const Text(
            'Select equipment to offer',
            style: TextStyle(
              color: Color(0xFF9B9B9B),
              fontSize: 14,
            ),
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
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
          items: documents.map((document) {
            final data = document.data();

            final String equipmentName =
                data['name']?.toString() ?? 'Equipment';

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
          onChanged: (equipmentId) {
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
      },
    );
  }

  Widget _informationBox({
    required String text,
    required IconData icon,
  }) {
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
          Icon(
            icon,
            size: 21,
            color: greyText,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: greyText,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}