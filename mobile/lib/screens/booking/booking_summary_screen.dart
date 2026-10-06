import 'package:flutter/material.dart';

import 'checkout_screen.dart';
import 'pickup_delivery_screen.dart';

class BookingSummaryScreen extends StatefulWidget {
  final String equipmentId;
  final String providerId;
  final String equipmentName;
  final String imageUrl;
  final double pricePerDay;
  final DateTimeRange rentalDates;
  final double? securityDeposit;

  const BookingSummaryScreen({
    super.key,
    required this.equipmentId,
    required this.providerId,
    required this.equipmentName,
    required this.imageUrl,
    required this.pricePerDay,
    required this.rentalDates,
    this.securityDeposit,
  });

  @override
  State<BookingSummaryScreen> createState() =>
      _BookingSummaryScreenState();
}

class _BookingSummaryScreenState extends State<BookingSummaryScreen> {
  static const primaryRed = Color(0xFFED1235);

  FulfilmentSelection? _selection;

  int get _days {
    final start = widget.rentalDates.start;
    final end = widget.rentalDates.end;

    return DateTime.utc(end.year, end.month, end.day)
            .difference(DateTime.utc(start.year, start.month, start.day))
            .inDays +
        1;
  }

  String _money(double value) {
    return value.toStringAsFixed(
      value == value.roundToDouble() ? 0 : 2,
    );
  }

  String _date(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Future<void> _chooseMethod() async {
    final result = await Navigator.push<FulfilmentSelection>(
      context,
      MaterialPageRoute<FulfilmentSelection>(
        builder: (context) => PickupDeliveryScreen(
          equipmentName: widget.equipmentName,
          initialSelection: _selection,
        ),
      ),
    );

    if (!mounted || result == null) return;

    setState(() {
      _selection = result;
    });
  }

  void _openCheckout() {
    final selection = _selection;
    if (selection == null) return;

    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => CheckoutScreen(
          equipmentId: widget.equipmentId,
          providerId: widget.providerId,
          equipmentName: widget.equipmentName,
          pricePerDay: widget.pricePerDay,
          rentalDates: widget.rentalDates,
          securityDeposit: widget.securityDeposit,
          receiveMethod: selection.method,
          deliveryAddress: selection.address,
          // Delivery pricing has not been connected yet.
          deliveryFee: selection.method == 'pickup' ? 0.0 : null,
        ),
      ),
    );
  }

  Widget _row(String label, String value, {bool total = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.black54),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: total ? primaryRed : Colors.black87,
                fontSize: total ? 20 : 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _box(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE4E4E8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: const Color(0xFFF1F1F3),
      alignment: Alignment.center,
      child: const Icon(
        Icons.sports_cricket_outlined,
        size: 38,
        color: Colors.black38,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rentalFee = widget.pricePerDay * _days;
    final deposit = widget.securityDeposit;
    final selection = _selection;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: const Text(
          'Booking Summary',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
            children: [
              const Text(
                'Review your booking',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Check your equipment and rental dates.',
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 24),
              _box([
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        width: 85,
                        height: 85,
                        child: widget.imageUrl.isEmpty
                            ? _placeholder()
                            : Image.network(
                                widget.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    _placeholder(),
                              ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.equipmentName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Rs. ${_money(widget.pricePerDay)} / day',
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
              ]),
              const SizedBox(height: 26),
              const Text(
                'Rental Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              _box([
                _row('Start Date', _date(widget.rentalDates.start)),
                _row('End Date', _date(widget.rentalDates.end)),
                _row('Duration', '$_days days'),
              ]),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => Navigator.pop(context, true),
                  icon: const Icon(Icons.edit_calendar_outlined),
                  label: const Text('Edit Dates'),
                  style: TextButton.styleFrom(
                    foregroundColor: primaryRed,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Price Breakdown',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              _box([
                _row(
                  'Rental Fee ($_days days)',
                  'Rs. ${_money(rentalFee)}',
                ),
                _row(
                  'Security Deposit',
                  deposit == null
                      ? 'Not specified'
                      : 'Rs. ${_money(deposit)}',
                ),
                const Divider(height: 24),
                _row(
                  deposit == null ? 'Rental Subtotal' : 'Subtotal',
                  'Rs. ${_money(rentalFee + (deposit ?? 0))}',
                  total: true,
                ),
              ]),
              if (selection != null) ...[
                const SizedBox(height: 22),
                _box([
                  Text(
                    selection.method == 'pickup'
                        ? 'Receive Method: Pickup'
                        : 'Receive Method: Delivery',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (selection.method == 'delivery') ...[
                    const SizedBox(height: 10),
                    Text(selection.address),
                    const SizedBox(height: 8),
                    const Text(
                      'Delivery fee: To be confirmed',
                      style: TextStyle(color: Colors.black54),
                    ),
                  ],
                ]),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _chooseMethod,
                    style: TextButton.styleFrom(
                      foregroundColor: primaryRed,
                    ),
                    child: const Text('Change Pickup / Delivery'),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              const Text(
                'Availability and the final amount must be verified '
                'before booking.',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: selection == null
                      ? _chooseMethod
                      : _openCheckout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryRed,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: Text(
                    selection == null
                        ? 'Continue'
                        : 'Continue to Checkout',
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
      ),
    );
  }
}