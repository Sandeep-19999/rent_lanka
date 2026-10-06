import 'package:flutter/material.dart';

class CancelBookingScreen extends StatefulWidget {
  final String equipmentName;

  const CancelBookingScreen({
    super.key,
    required this.equipmentName,
  });

  @override
  State<CancelBookingScreen> createState() =>
      _CancelBookingScreenState();
}

class _CancelBookingScreenState extends State<CancelBookingScreen> {
  static const primaryRed = Color(0xFFED1235);

  final _otherReasonController = TextEditingController();

  String? _reason;

  static const _reasons = [
    'My plans changed',
    'Selected the wrong equipment',
    'Selected the wrong dates',
    'Other',
  ];

  @override
  void dispose() {
    _otherReasonController.dispose();
    super.dispose();
  }

  void _confirmCancellation() {
    if (_reason == null) return;

    final reason = _reason == 'Other'
        ? _otherReasonController.text.trim()
        : _reason!;

    if (reason.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your cancellation reason.'),
        ),
      );
      return;
    }

    Navigator.pop(context, reason);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: const Text(
          'Cancel Booking',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const Icon(
                Icons.event_busy_outlined,
                size: 64,
                color: primaryRed,
              ),
              const SizedBox(height: 20),
              const Text(
                'Cancel this booking?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.equipmentName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'Reason for cancellation',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              ..._reasons.map((reason) {
                final selected = _reason == reason;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Material(
                    color: selected
                        ? const Color(0xFFFFEEF1)
                        : const Color(0xFFF8F8FA),
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => setState(() => _reason = reason),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(child: Text(reason)),
                            Icon(
                              selected
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_unchecked,
                              color:
                                  selected ? primaryRed : Colors.black38,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
              if (_reason == 'Other') ...[
                const SizedBox(height: 8),
                TextField(
                  controller: _otherReasonController,
                  maxLines: 3,
                  maxLength: 300,
                  decoration: InputDecoration(
                    labelText: 'Your reason',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed:
                      _reason == null ? null : _confirmCancellation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryRed,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Text(
                    'Confirm Cancellation',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryRed,
                  minimumSize: const Size(double.infinity, 52),
                ),
                child: const Text('Keep Booking'),
              ),
              const SizedBox(height: 24),
              const Text(
                'Preview only — no saved reservation or refund is affected.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black45,
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}