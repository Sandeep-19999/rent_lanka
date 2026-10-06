import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'booking_summary_screen.dart';
import 'rental_dates_screen.dart';

class EquipmentDetailsScreen extends StatefulWidget {
  final String? equipmentId;

  const EquipmentDetailsScreen({
    super.key,
    this.equipmentId,
  });

  @override
  State<EquipmentDetailsScreen> createState() =>
      _EquipmentDetailsScreenState();
}

class _EquipmentDetailsScreenState extends State<EquipmentDetailsScreen> {
  static const primaryRed = Color(0xFFED1235);

  late final Stream<QuerySnapshot<Map<String, dynamic>>> _stream;

  String? _selectedId;
  DateTimeRange? _dates;

  @override
  void initState() {
    super.initState();
    _selectedId = widget.equipmentId;
    _stream = FirebaseFirestore.instance.collection('equipment').snapshots();
  }

  String _text(Map<String, dynamic> data, String key) {
    return data[key]?.toString().trim() ?? '';
  }

  String _money(double value) {
    return value.toStringAsFixed(
      value == value.roundToDouble() ? 0 : 2,
    );
  }

  Widget _placeholder() {
    return Container(
      color: const Color(0xFFF1F1F3),
      alignment: Alignment.center,
      child: const Icon(
        Icons.sports_cricket_outlined,
        size: 72,
        color: Colors.black38,
      ),
    );
  }

  Future<void> _startBooking({
    required String equipmentId,
    required Map<String, dynamic> data,
    required String name,
    required double price,
  }) async {
    bool editDates = true;

    while (mounted && editDates) {
      final dates = await Navigator.push<DateTimeRange>(
        context,
        MaterialPageRoute<DateTimeRange>(
          builder: (context) => RentalDatesScreen(
            equipmentName: name,
            pricePerDay: price,
            initialDates: _dates,
          ),
        ),
      );

      if (!mounted || dates == null) return;

      setState(() {
        _dates = dates;
      });

      final rawDeposit = data['securityDeposit'];
      final deposit = rawDeposit is num &&
              rawDeposit.toDouble().isFinite &&
              rawDeposit >= 0
          ? rawDeposit.toDouble()
          : null;

      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute<bool>(
          builder: (context) => BookingSummaryScreen(
            equipmentId: equipmentId,
            providerId: _text(data, 'providerId'),
            equipmentName: name,
            imageUrl: _text(data, 'imageUrl'),
            pricePerDay: price,
            rentalDates: dates,
            securityDeposit: deposit,
          ),
        ),
      );

      if (!mounted) return;

      // Edit Dates returns true; ordinary Back finishes this flow.
      editDates = result == true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: const Text(
          'Equipment Details',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _stream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Unable to load equipment. Check your connection '
                  'and Firestore read permissions.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: primaryRed),
            );
          }

          final documents = snapshot.data!.docs;

          if (documents.isEmpty) {
            return const Center(
              child: Text('No equipment listings yet.'),
            );
          }

          QueryDocumentSnapshot<Map<String, dynamic>>? selected;

          if (_selectedId == null) {
            selected = documents.first;
          } else {
            for (final document in documents) {
              if (document.id == _selectedId) {
                selected = document;
                break;
              }
            }
          }

          if (selected == null) {
            return const Center(
              child: Text('This listing is no longer available.'),
            );
          }

          final equipmentId = selected.id;
          final data = selected.data();

          final rawPrice = data['pricePerDay'];
          final price = rawPrice is num ? rawPrice.toDouble() : 0.0;

          final name = _text(data, 'name').isEmpty
              ? 'Equipment'
              : _text(data, 'name');

          final imageUrl = _text(data, 'imageUrl');
          final description = _text(data, 'description');
          final providerName = _text(data, 'providerName');

          final available = data['isAvailable'] == true &&
              _text(data, 'status').toLowerCase() == 'available';

          final validPrice = price.isFinite && price > 0;
          final canBook = available && validPrice;

          final details = [
            if (_text(data, 'brand').isNotEmpty)
              'Brand: ${_text(data, 'brand')}',
            if (_text(data, 'size').isNotEmpty)
              'Size: ${_text(data, 'size')}',
            if (_text(data, 'condition').isNotEmpty)
              '${_text(data, 'condition')} Condition',
          ].join(' | ');

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                children: [
                  if (widget.equipmentId == null) ...[
                    DropdownButtonFormField<String>(
                      key: ValueKey(equipmentId),
                      initialValue: equipmentId,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Choose equipment to preview',
                        border: OutlineInputBorder(),
                      ),
                      items: documents.map((document) {
                        return DropdownMenuItem<String>(
                          value: document.id,
                          child: Text(
                            document.data()['name']?.toString() ??
                                'Equipment',
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedId = value;
                          _dates = null;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: SizedBox(
                      height: 245,
                      child: imageUrl.isEmpty
                          ? _placeholder()
                          : Image.network(
                              imageUrl,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  _placeholder(),
                            ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    validPrice
                        ? 'Rs. ${_money(price)} / day'
                        : 'Rental price unavailable',
                    style: const TextStyle(
                      color: primaryRed,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (details.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      details,
                      style: const TextStyle(
                        color: Colors.black54,
                        height: 1.5,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Text(
                    available ? 'Available' : 'Currently unavailable',
                    style: TextStyle(
                      color: available ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    elevation: 0,
                    color: const Color(0xFFF8F8FA),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFFFE8EC),
                        child: Icon(
                          Icons.storefront_outlined,
                          color: primaryRed,
                        ),
                      ),
                      title: Text(
                        providerName.isEmpty
                            ? 'Equipment Provider'
                            : providerName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      subtitle: const Text('Listing owner'),
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    description.isEmpty
                        ? 'The provider has not added a description yet.'
                        : description,
                    style: const TextStyle(
                      color: Colors.black54,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      onPressed: canBook
                          ? () => _startBooking(
                                equipmentId: equipmentId,
                                data: data,
                                name: name,
                                price: price,
                              )
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryRed,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: Text(
                        _dates == null
                            ? 'Book Equipment'
                            : 'Review Booking',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}