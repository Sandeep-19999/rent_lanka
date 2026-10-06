import 'package:flutter/material.dart';

import '../../models/booking_preview.dart';
import 'booking_ui.dart';

class EditBookingScreen extends StatefulWidget {
  final BookingPreview booking;

  const EditBookingScreen({
    super.key,
    required this.booking,
  });

  @override
  State<EditBookingScreen> createState() => _EditBookingScreenState();
}

class _EditBookingScreenState extends State<EditBookingScreen> {
  final _formKey = GlobalKey<FormState>();

  late DateTimeRange _dates;
  late String _receiveMethod;
  late String _paymentMethod;
  late TextEditingController _address;

  @override
  void initState() {
    super.initState();

    _dates = widget.booking.rentalDates;
    _receiveMethod = widget.booking.receiveMethod;
    _paymentMethod = widget.booking.paymentMethod;
    _address = TextEditingController(
      text: widget.booking.deliveryAddress,
    );
  }

  @override
  void dispose() {
    _address.dispose();
    super.dispose();
  }

  int get _days {
    final start = _dates.start;
    final end = _dates.end;

    return DateTime.utc(end.year, end.month, end.day)
            .difference(DateTime.utc(start.year, start.month, start.day))
            .inDays +
        1;
  }

  double? get _deliveryFee {
    if (_receiveMethod == 'pickup') return 0;

    if (_address.text.trim() == widget.booking.quotedDeliveryAddress) {
      return widget.booking.quotedDeliveryFee;
    }

    return null;
  }

  Future<void> _chooseDates() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastDate = DateTime(today.year + 2, today.month, today.day);

    final start = DateUtils.dateOnly(_dates.start);
    final end = DateUtils.dateOnly(_dates.end);

    final initialRange =
        !start.isBefore(today) && !end.isAfter(lastDate)
            ? DateTimeRange(start: start, end: end)
            : null;

    final result = await showDateRangePicker(
      context: context,
      firstDate: today,
      lastDate: lastDate,
      initialDateRange: initialRange,
      helpText: 'Select rental dates',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: bookingRed,
              primary: bookingRed,
            ),
          ),
          child: child!,
        );
      },
    );

    if (!mounted || result == null) return;

    setState(() => _dates = result);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final subtotal = widget.booking.pricePerDay * _days +
        (widget.booking.securityDeposit ?? 0) +
        (_deliveryFee ?? 0);

    if (DateUtils.dateOnly(_dates.start).isBefore(today) ||
        _days < 1 ||
        !subtotal.isFinite ||
        subtotal <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select valid future rental dates.'),
        ),
      );
      return;
    }

    widget.booking.update(
      dates: _dates,
      method: _receiveMethod,
      address: _address.text,
      payment: _paymentMethod,
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final rentalFee = widget.booking.pricePerDay * _days;
    final deliveryFee = _deliveryFee;
    final subtotal = rentalFee +
        (widget.booking.securityDeposit ?? 0) +
        (deliveryFee ?? 0);
    final finalAmountKnown =
        widget.booking.securityDeposit != null && deliveryFee != null;

    return bookingPage(
      'Edit Booking',
      [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.booking.equipmentName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 24),
              bookingCard(
                'Rental Dates',
                [
                  bookingRow('Dates', bookingDates(_dates)),
                  bookingRow('Duration', '$_days days'),
                  bookingButton(
                    'Change Dates',
                    _chooseDates,
                    outlined: true,
                  ),
                ],
              ),
              const Text(
                'Pickup / Delivery',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 12,
                children: [
                  ChoiceChip(
                    label: const Text('Pickup'),
                    selected: _receiveMethod == 'pickup',
                    onSelected: (_) {
                      setState(() => _receiveMethod = 'pickup');
                    },
                  ),
                  ChoiceChip(
                    label: const Text('Delivery'),
                    selected: _receiveMethod == 'delivery',
                    onSelected: (_) {
                      setState(() => _receiveMethod = 'delivery');
                    },
                  ),
                ],
              ),
              if (_receiveMethod == 'delivery') ...[
                const SizedBox(height: 18),
                TextFormField(
                  controller: _address,
                  maxLines: 3,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    labelText: 'Delivery Address',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (_receiveMethod == 'delivery' &&
                        (value == null || value.trim().isEmpty)) {
                      return 'Enter your delivery address.';
                    }

                    return null;
                  },
                ),
              ],
              const SizedBox(height: 24),
              DropdownButtonFormField<String>(
                initialValue: _paymentMethod,
                decoration: const InputDecoration(
                  labelText: 'Payment Method',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'card',
                    child: Text('Card'),
                  ),
                  DropdownMenuItem(
                    value: 'online_banking',
                    child: Text('Online Banking'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _paymentMethod = value);
                  }
                },
              ),
              const SizedBox(height: 24),
              bookingCard(
                'Updated Price',
                [
                  bookingRow('Rental Fee', bookingMoney(rentalFee)),
                  bookingRow(
                    'Security Deposit',
                    widget.booking.securityDeposit == null
                        ? 'Not specified'
                        : bookingMoney(widget.booking.securityDeposit!),
                  ),
                  bookingRow(
                    'Delivery Fee',
                    deliveryFee == null
                        ? 'To be confirmed'
                        : bookingMoney(deliveryFee),
                  ),
                  const Divider(),
                  bookingRow(
                    finalAmountKnown ? 'Total' : 'Known Subtotal',
                    bookingMoney(subtotal),
                  ),
                  if (!finalAmountKnown)
                    const Text(
                      'Unconfirmed charges are not included. '
                      'A changed delivery address requires a new quote.',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                ],
              ),
              bookingButton(
                'Save Changes',
                widget.booking.cancelled ? null : _save,
              ),
              bookingButton(
                'Discard Changes',
                () => Navigator.pop(context),
                outlined: true,
              ),
              bookingPreviewNote,
            ],
          ),
        ),
      ],
    );
  }
}