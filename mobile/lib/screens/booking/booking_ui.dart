import 'package:flutter/material.dart';

import '../../models/booking_preview.dart';

const bookingRed = Color(0xFFED1235);

String bookingMoney(double amount) {
  if (!amount.isFinite) return 'Unavailable';

  return 'Rs. ${amount.toStringAsFixed(
    amount == amount.roundToDouble() ? 0 : 2,
  )}';
}

String bookingDate(DateTime date) =>
    '${date.day}/${date.month}/${date.year}';

String bookingDates(DateTimeRange dates) =>
    '${bookingDate(dates.start)} – ${bookingDate(dates.end)}';

Widget bookingRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 9),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
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
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ),
  );
}

Widget bookingCard(String title, List<Widget> children) {
  return Container(
    padding: const EdgeInsets.all(20),
    margin: const EdgeInsets.only(bottom: 20),
    decoration: BoxDecoration(
      color: const Color(0xFFF8F8FA),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFFE4E4E8)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    ),
  );
}

Widget bookingButton(
  String label,
  VoidCallback? onPressed, {
  bool outlined = false,
}) {
  final shape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(28),
  );

  return Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: SizedBox(
      width: double.infinity,
      height: 54,
      child: outlined
          ? OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: bookingRed,
                side: const BorderSide(color: bookingRed),
                shape: shape,
              ),
              child: Text(label),
            )
          : ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: bookingRed,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: shape,
              ),
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
    ),
  );
}

Widget bookingPage(String title, List<Widget> children) {
  return Scaffold(
    backgroundColor: Colors.white,
    appBar: AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
    ),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: children,
        ),
      ),
    ),
  );
}

Widget bookingInformation(BookingPreview booking) {
  return bookingCard(
    booking.equipmentName,
    [
      bookingRow('Rental Dates', bookingDates(booking.rentalDates)),
      bookingRow('Duration', '${booking.days} days'),
      bookingRow('Price per day', bookingMoney(booking.pricePerDay)),
      bookingRow(
        'Receive Method',
        booking.receiveMethod == 'pickup' ? 'Pickup' : 'Delivery',
      ),
      if (booking.receiveMethod == 'delivery')
        bookingRow('Delivery Address', booking.deliveryAddress),
      if (booking.receiveMethod == 'pickup')
        const Text(
          'Confirm the collection location with the provider.',
          style: TextStyle(color: Colors.black54, height: 1.5),
        ),
    ],
  );
}

Widget bookingPrices(BookingPreview booking) {
  return bookingCard(
    'Price Breakdown',
    [
      bookingRow('Rental Fee', bookingMoney(booking.rentalFee)),
      bookingRow(
        'Security Deposit',
        booking.securityDeposit == null
            ? 'Not specified'
            : bookingMoney(booking.securityDeposit!),
      ),
      bookingRow(
        'Delivery Fee',
        booking.deliveryFee == null
            ? 'To be confirmed'
            : bookingMoney(booking.deliveryFee!),
      ),
      const Divider(),
      bookingRow(
        booking.finalAmountKnown ? 'Total' : 'Known Subtotal',
        bookingMoney(booking.knownSubtotal),
      ),
      if (!booking.finalAmountKnown)
        const Text(
          'Unconfirmed charges are not included in this subtotal.',
          style: TextStyle(
            color: Colors.black54,
            fontSize: 12,
            height: 1.5,
          ),
        ),
    ],
  );
}

const bookingPreviewNote = Padding(
  padding: EdgeInsets.symmetric(vertical: 16),
  child: Text(
    'Preview only — no payment charged or booking submitted. '
    'Changes are kept while this booking preview is open.',
    textAlign: TextAlign.center,
    style: TextStyle(
      color: Colors.black45,
      fontSize: 12,
      height: 1.5,
    ),
  ),
);