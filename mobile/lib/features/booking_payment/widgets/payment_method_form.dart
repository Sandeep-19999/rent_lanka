import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/booking_model.dart';
import '../services/payment_service.dart';
import 'booking_widgets.dart';

/// Payment method picker with the card form, bank picker and cash note.
///
/// Shared by the Payment screen (new booking) and the Edit Booking screen.
/// The parent owns the controllers and [formKey] so it can validate and
/// read the card details when the user pays.
class PaymentMethodForm extends StatelessWidget {
  final PaymentMethod method;
  final ValueChanged<PaymentMethod> onMethodChanged;
  final String? bank;
  final ValueChanged<String?> onBankChanged;
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController numberController;
  final TextEditingController expiryController;
  final TextEditingController cvvController;
  final String cashInfo;

  const PaymentMethodForm({
    super.key,
    required this.method,
    required this.onMethodChanged,
    required this.bank,
    required this.onBankChanged,
    required this.formKey,
    required this.nameController,
    required this.numberController,
    required this.expiryController,
    required this.cvvController,
    this.cashInfo = 'Pay the provider in cash when you collect the '
        'equipment. Your booking is still sent for approval now.',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payment method',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),

        RadioGroup<PaymentMethod>(
          groupValue: method,
          onChanged: (value) {
            if (value != null) onMethodChanged(value);
          },
          child: Column(
            children: [
              for (final option in PaymentMethod.values)
                _MethodTile(
                  method: option,
                  selected: option == method,
                  onTap: () => onMethodChanged(option),
                ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        if (method == PaymentMethod.card) _cardForm(),
        if (method == PaymentMethod.onlineBanking) _bankPicker(),
        if (method == PaymentMethod.cashOnPickup) _InfoBox(text: cashInfo),

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
    );
  }

  Widget _cardForm() {
    return Form(
      key: formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        children: [
          TextFormField(
            controller: nameController,
            textCapitalization: TextCapitalization.characters,
            autofillHints: const [AutofillHints.creditCardName],
            decoration: _decoration('Name on card', Icons.person_outline),
            validator: PaymentService.validateHolderName,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: numberController,
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
                  controller: expiryController,
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
                  controller: cvvController,
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
      initialValue: bank,
      decoration: _decoration('Select your bank', Icons.account_balance),
      items: [
        for (final option in PaymentService.supportedBanks)
          DropdownMenuItem(value: option, child: Text(option)),
      ],
      onChanged: onBankChanged,
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
      width: double.infinity,
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
