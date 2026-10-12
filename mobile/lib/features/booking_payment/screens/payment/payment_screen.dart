import 'package:flutter/material.dart';

import '../../models/booking_model.dart';
import '../../services/booking_service.dart';
import '../../services/payment_service.dart';
import '../../utils/date_utils.dart';
import '../booking/booking_confirmation_screen.dart';
import '../../widgets/booking_widgets.dart';
import '../../widgets/payment_method_form.dart';

/// Payment & Checkout (EV04 / FR10): select a payment method and pay.
class PaymentScreen extends StatefulWidget {
  final BookingDraft draft;

  const PaymentScreen({super.key, required this.draft});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _numberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  PaymentMethod _method = PaymentMethod.card;
  String? _bank;
  bool _processing = false;

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  Future<void> _pay() async {
    FocusScope.of(context).unfocus();

    if (_method == PaymentMethod.card && !_formKey.currentState!.validate()) {
      return;
    }
    if (_method == PaymentMethod.onlineBanking && _bank == null) {
      showMessage(context, 'Please select your bank.', error: true);
      return;
    }

    setState(() => _processing = true);

    try {
      final bookingId = await BookingService().confirmBooking(
        draft: widget.draft,
        paymentMethod: _method,
        bank: _bank,
        card: _method == PaymentMethod.card
            ? CardDetails(
                holderName: _nameController.text,
                number: _numberController.text,
                expiry: _expiryController.text,
                cvv: _cvvController.text,
              )
            : null,
      );

      if (!mounted) return;

      // Clear the booking flow so Back can't resubmit the payment.
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => BookingConfirmationScreen(bookingId: bookingId),
        ),
        (route) => route.isFirst,
      );
    } on BookingException catch (error) {
      if (!mounted) return;
      setState(() => _processing = false);
      showMessage(context, error.message, error: true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _processing = false);
      showMessage(
        context,
        'Something went wrong while booking. You have not been charged. '
        'Please try again.',
        error: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.draft.price.totalPayable;

    return PopScope(
      canPop: !_processing,
      child: BookingPage(
        title: 'Payment',
        bottom: PrimaryButton(
          label: _method == PaymentMethod.cashOnPickup
              ? 'Confirm Booking'
              : 'Pay ${formatLkr(total)} Securely',
          icon: Icons.lock,
          loading: _processing,
          onPressed: _pay,
        ),
        body: AbsorbPointer(
          absorbing: _processing,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const BookingSteps(current: 2),
                const SizedBox(height: 20),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: primaryRed,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Amount to pay',
                        style: TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formatLkr(total),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.draft.equipment.name} - '
                        '${widget.draft.rentalDays} day(s)',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),
                PaymentMethodForm(
                  method: _method,
                  onMethodChanged: (value) => setState(() => _method = value),
                  bank: _bank,
                  onBankChanged: (value) => setState(() => _bank = value),
                  formKey: _formKey,
                  nameController: _nameController,
                  numberController: _numberController,
                  expiryController: _expiryController,
                  cvvController: _cvvController,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
