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

  static const Color borderColor = Color(0xFFE0E0E0);

  static const Color hintColor = Color(0xFF9B9B9B);

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select equipment to offer.')),
      );

      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final String requestId = await _exchangeService.sendExchangeRequest(
        requestedProviderId: widget.requestedProviderId,
        requestedEquipmentId: widget.requestedEquipmentId,
        requestedEquipmentName: widget.requestedEquipmentName,
        offeredEquipmentId: _selectedEquipmentId!,
        offeredEquipmentName: _selectedEquipmentName!,
        message: _messageController.text,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Exchange request sent successfully.'),
          backgroundColor: Color(0xFF2E9B50),
        ),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ExchangeStatusScreen(exchangeRequestId: requestId),
        ),
      );
    } on FirebaseException catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Firebase error: '
            '${error.message ?? error.code}',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to send exchange request: '
            '$error',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),

                  const SizedBox(height: 30),

                  const Text(
                    'Request an exchange',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF242424),
                    ),
                  ),

                  const SizedBox(height: 28),

                  const Text(
                    'Your equipment',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF242424),
                    ),
                  ),

                  const SizedBox(height: 8),

                  _buildEquipmentDropdown(),

                  const SizedBox(height: 18),

                  const Text(
                    'Message',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF242424),
                    ),
                  ),

                  const SizedBox(height: 8),

                  TextField(
                    controller: _messageController,
                    maxLines: 4,
                    minLines: 4,
                    textInputAction: TextInputAction.newline,
                    decoration: InputDecoration(
                      hintText: 'Explain your exchange offer...',
                      hintStyle: const TextStyle(
                        color: hintColor,
                        fontSize: 14,
                      ),
                      contentPadding: const EdgeInsets.all(14),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: borderColor,
                          width: 1.3,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: primaryRed,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 14, color: hintColor),
                      children: [
                        const TextSpan(text: 'Requested item: '),
                        TextSpan(
                          text: widget.requestedEquipmentName,
                          style: const TextStyle(
                            color: Color(0xFF242424),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 35),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _sendExchangeRequest,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryRed,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: primaryRed.withValues(
                          alpha: 0.55,
                        ),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
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
                          : const Text(
                              'Send exchange request',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
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
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        InkWell(
          onTap: () {
            Navigator.maybePop(context);
          },
          borderRadius: BorderRadius.circular(50),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 4, horizontal: 2),
            child: Icon(
              Icons.arrow_back_ios_new,
              size: 22,
              color: Color(0xFF242424),
            ),
          ),
        ),
        const SizedBox(width: 14),
        const Text(
          'Exchange request',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Color(0xFF242424),
          ),
        ),
      ],
    );
  }

  Widget _buildEquipmentDropdown() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _exchangeService.watchMyEquipment(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _informationBox(
            text: 'Unable to load your equipment.',
            icon: Icons.error_outline,
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: 52,
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: borderColor, width: 1.3),
            ),
            child: const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
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
            text: 'No available equipment found for your account.',
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
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Color(0xFF242424),
          ),
          hint: const Text(
            'Select item to offer',
            style: TextStyle(color: hintColor, fontSize: 14),
          ),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 5,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: borderColor, width: 1.3),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: primaryRed, width: 1.5),
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
                style: const TextStyle(fontSize: 14, color: Color(0xFF242424)),
              ),
            );
          }).toList(),
          onChanged: (equipmentId) {
            if (equipmentId == null) {
              return;
            }

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

  Widget _informationBox({required String text, required IconData icon}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: 1.3),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: hintColor),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, color: hintColor),
            ),
          ),
        ],
      ),
    );
  }
}
