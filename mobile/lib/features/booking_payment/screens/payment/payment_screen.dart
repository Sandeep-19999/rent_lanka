import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/booking_model.dart';
import '../../services/booking_service.dart';
import '../../services/payment_service.dart';
import '../../utils/date_utils.dart';
import '../booking/booking_confirmation_screen.dart';
import '../../widgets/booking_widgets.dart';

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
                const Text(
                  'Payment method',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),

                RadioGroup<PaymentMethod>(
                  groupValue: _method,
                  onChanged: (value) {
                    if (value != null) setState(() => _method = value);
                  },
                  child: Column(
                    children: [
                      for (final method in PaymentMethod.values)
                        _MethodTile(
                          method: method,
                          selected: method == _method,
                          onTap: () => setState(() => _method = method),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                if (_method == PaymentMethod.card) _cardForm(),
                if (_method == PaymentMethod.onlineBanking) _bankPicker(),
                if (_method == PaymentMethod.cashOnPickup)
                  const _InfoBox(
                    text: 'Pay the provider in cash when you collect the '
                        'equipment. Your booking is still sent for approval now.',
                  ),

                const SizedBox(height: 18),
                const Row(
                  children: [
                    Icon(Icons.verified_user_outlined, size: 18, color: textGrey),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Your card details are only used for this payment and '
                        'are never stored. Only the last 4 digits are saved '
                        'on your receipt.',
                        style: TextStyle(color: textGrey, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _cardForm() {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        children: [
          TextFormField(
            controller: _nameController,
            textCapitalization: TextCapitalization.characters,
            autofillHints: const [AutofillHints.creditCardName],
            decoration: _decoration('Name on card', Icons.person_outline),
            validator: PaymentService.validateHolderName,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _numberController,
            keyboardType: TextInputType.number,
            autofillHints: const [AutofillHints.creditCardNumber],
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(19),
              _CardNumberFormatter(),
            ],
            decoration: _decoration('Card number', Icons.credit_card),
            validator: PaymentService.validateCardNumber,
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextFormField(
                  controller: _expiryController,
                  keyboardType: TextInputType.number,
                  autofillHints: const [AutofillHints.creditCardExpirationDate],
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                    _ExpiryFormatter(),
                  ],
                  decoration: _decoration('Expiry (MM/YY)', Icons.date_range),
                  validator: (value) => PaymentService.validateExpiry(value),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _cvvController,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  autofillHints: const [AutofillHints.creditCardSecurityCode],
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  decoration: _decoration('CVV', Icons.lock_outline),
                  validator: PaymentService.validateCvv,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bankPicker() {
    return DropdownButtonFormField<String>(
      initialValue: _bank,
      decoration: _decoration('Select your bank', Icons.account_balance),
      items: [
        for (final bank in PaymentService.supportedBanks)
          DropdownMenuItem(value: bank, child: Text(bank)),
      ],
      onChanged: (value) => setState(() => _bank = value),
    );
  }

  static InputDecoration _decoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 20),
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

class _MethodTile extends StatelessWidget {
  final PaymentMethod method;
  final bool selected;
  final VoidCallback onTap;

  const _MethodTile({
    required this.method,
    required this.selected,
    required this.onTap,
  });

  static IconData _icon(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.card:
        return Icons.credit_card;
      case PaymentMethod.onlineBanking:
        return Icons.account_balance_outlined;
      case PaymentMethod.cashOnPickup:
        return Icons.payments_outlined;
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
                child: Text(
                  method.label,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              Radio<PaymentMethod>(value: method, activeColor: primaryRed),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final String text;
  const _InfoBox({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: softGrey,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(text, style: const TextStyle(height: 1.4)),
    );
  }
}

/// `4242424242424242` -> `4242 4242 4242 4242`
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }
    final text = buffer.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

/// `1228` -> `12/28`
class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll('/', '');
    final text = digits.length > 2
        ? '${digits.substring(0, 2)}/${digits.substring(2)}'
        : digits;
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
