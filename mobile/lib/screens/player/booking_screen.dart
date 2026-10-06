import 'package:flutter/material.dart';

import '../../models/booking.dart';
import '../../models/equipment.dart';
import '../../services/booking_service.dart';
import '../../utils/date_utils.dart';
import 'booking_summary_screen.dart';
import 'widgets/booking_widgets.dart';

/// Rental Booking: rent dates + pickup / delivery selection (EV04, EV08).
class BookingScreen extends StatefulWidget {
  final Equipment equipment;

  const BookingScreen({super.key, required this.equipment});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _service = BookingService();
  final _addressController = TextEditingController();
  final _noteController = TextEditingController();

  Set<String> _unavailable = {};
  bool _loadingDates = true;
  String? _loadError;

  DateTime? _start;
  DateTime? _end;
  PickupMethod _pickupMethod = PickupMethod.ownerPickup;

  @override
  void initState() {
    super.initState();
    _loadUnavailableDates();
  }

  @override
  void dispose() {
    _addressController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadUnavailableDates() async {
    setState(() {
      _loadingDates = true;
      _loadError = null;
    });
    try {
      final dates = await _service.unavailableDateKeys(widget.equipment);
      if (!mounted) return;
      setState(() {
        _unavailable = dates;
        _loadingDates = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadError = 'Could not check availability. Please try again.';
        _loadingDates = false;
      });
    }
  }

  Future<void> _pickDates() async {
    final today = AppDates.dateOnly(DateTime.now());
    final picked = await showDateRangePicker(
      context: context,
      firstDate: today,
      lastDate: today.add(const Duration(days: BookingService.bookingWindowDays)),
      initialDateRange: _start != null && _end != null
          ? DateTimeRange(start: _start!, end: _end!)
          : null,
      helpText: 'Select rental period',
      saveText: 'Done',
      selectableDayPredicate: (day, _, _) =>
          !_unavailable.contains(AppDates.key(day)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(primary: primaryRed),
        ),
        child: child!,
      ),
    );
    if (picked == null || !mounted) return;

    // The picker greys out blocked days but still allows a range that
    // spans them, so validate the whole range.
    final error = BookingService.validateDates(
      start: picked.start,
      end: picked.end,
      unavailable: _unavailable,
    );
    if (error != null) {
      showMessage(context, error, error: true);
      return;
    }

    setState(() {
      _start = AppDates.dateOnly(picked.start);
      _end = AppDates.dateOnly(picked.end);
    });
  }

  void _continue() {
    if (_start == null || _end == null) {
      showMessage(context, 'Please select your rental dates.', error: true);
      return;
    }
    if (_pickupMethod == PickupMethod.delivery &&
        _addressController.text.trim().length < 5) {
      showMessage(context, 'Please enter a delivery address.', error: true);
      return;
    }

    final draft = BookingDraft(
      equipment: widget.equipment,
      startDate: _start!,
      endDate: _end!,
      pickupMethod: _pickupMethod,
      deliveryAddress: _addressController.text,
      note: _noteController.text,
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => BookingSummaryScreen(draft: draft)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final equipment = widget.equipment;
    final days = _start != null && _end != null
        ? AppDates.rentalDays(_start!, _end!)
        : 0;

    return BookingPage(
      title: 'Rental Booking',
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (days > 0)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InfoRow(
                label: '$days day${days == 1 ? '' : 's'} x '
                    '${formatLkr(equipment.pricePerDay)}',
                value: formatLkr(days * equipment.pricePerDay),
                emphasise: true,
              ),
            ),
          PrimaryButton(
            label: 'Continue to Summary',
            onPressed: _loadingDates || _loadError != null ? null : _continue,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BookingSteps(current: 0),
            const SizedBox(height: 20),

            Row(
              children: [
                EquipmentThumb(
                  category: equipment.category,
                  imageUrl: equipment.imageUrl,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        equipment.name,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${formatLkr(equipment.pricePerDay)} / day',
                        style: const TextStyle(
                          color: primaryRed,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),
            const _Label('Rental period'),
            const SizedBox(height: 10),

            if (_loadingDates)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: CircularProgressIndicator(color: primaryRed),
                ),
              )
            else if (_loadError != null)
              SectionCard(
                child: Column(
                  children: [
                    Text(_loadError!, style: const TextStyle(color: Colors.red)),
                    TextButton(
                      onPressed: _loadUnavailableDates,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: _DateTile(
                      label: 'Start date',
                      date: _start,
                      onTap: _pickDates,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DateTile(
                      label: 'End date',
                      date: _end,
                      onTap: _pickDates,
                    ),
                  ),
                ],
              ),

            if (!_loadingDates && _unavailable.isNotEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Greyed-out dates are already booked or blocked by the provider.',
                  style: TextStyle(color: textGrey, fontSize: 12),
                ),
              ),

            const SizedBox(height: 24),
            const _Label('Pickup / Delivery'),
            const SizedBox(height: 6),

            RadioGroup<PickupMethod>(
              groupValue: _pickupMethod,
              onChanged: (value) {
                if (value != null) setState(() => _pickupMethod = value);
              },
              child: Column(
                children: [
                  for (final method in PickupMethod.values)
                    _PickupOption(
                      method: method,
                      selected: method == _pickupMethod,
                      subtitle: _pickupSubtitle(method, equipment),
                      onTap: () => setState(() => _pickupMethod = method),
                    ),
                ],
              ),
            ),

            if (_pickupMethod == PickupMethod.delivery) ...[
              const SizedBox(height: 8),
              TextField(
                controller: _addressController,
                textCapitalization: TextCapitalization.words,
                maxLines: 2,
                decoration: _inputDecoration(
                  'Delivery address',
                  'House no, street, city',
                ),
              ),
            ],

            const SizedBox(height: 20),
            const _Label('Note to provider (optional)'),
            const SizedBox(height: 10),
            TextField(
              controller: _noteController,
              maxLines: 3,
              maxLength: 300,
              decoration: _inputDecoration(
                null,
                'E.g. preferred pickup time or questions about the item',
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _pickupSubtitle(PickupMethod method, Equipment equipment) {
    switch (method) {
      case PickupMethod.ownerPickup:
        return equipment.location.isNotEmpty
            ? 'Collect from ${equipment.location}'
            : 'Collect from the provider - free';
      case PickupMethod.shopPickup:
        return 'Collect from the provider\'s shop - free';
      case PickupMethod.delivery:
        return 'Delivered to your address - '
            '${formatLkr(PriceBreakdown.deliveryFeeAmount)}';
    }
  }

  static InputDecoration _inputDecoration(String? label, String hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: softGrey,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: primaryRed),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
    );
  }
}

class _DateTile extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;

  const _DateTile({required this.label, required this.date, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: date != null ? primaryRed : borderGrey),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: textGrey, fontSize: 12)),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: primaryRed),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    date == null ? 'Select' : AppDates.pretty(date!),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PickupOption extends StatelessWidget {
  final PickupMethod method;
  final bool selected;
  final String subtitle;
  final VoidCallback onTap;

  const _PickupOption({
    required this.method,
    required this.selected,
    required this.subtitle,
    required this.onTap,
  });

  static IconData _icon(PickupMethod method) {
    switch (method) {
      case PickupMethod.ownerPickup:
        return Icons.person_pin_circle_outlined;
      case PickupMethod.shopPickup:
        return Icons.storefront_outlined;
      case PickupMethod.delivery:
        return Icons.local_shipping_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: selected ? primaryRed : borderGrey),
            color: selected ? primaryRed.withValues(alpha: 0.04) : null,
          ),
          child: Row(
            children: [
              Icon(_icon(method), color: selected ? primaryRed : Colors.black54),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      method.label,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(color: textGrey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Radio<PickupMethod>(value: method, activeColor: primaryRed),
            ],
          ),
        ),
      ),
    );
  }
}
