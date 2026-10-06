import 'package:flutter/material.dart';

class FulfilmentSelection {
  final String method;
  final String address;

  const FulfilmentSelection({
    required this.method,
    required this.address,
  });
}

class PickupDeliveryScreen extends StatefulWidget {
  final String equipmentName;
  final FulfilmentSelection? initialSelection;

  const PickupDeliveryScreen({
    super.key,
    required this.equipmentName,
    this.initialSelection,
  });

  @override
  State<PickupDeliveryScreen> createState() =>
      _PickupDeliveryScreenState();
}

class _PickupDeliveryScreenState extends State<PickupDeliveryScreen> {
  static const primaryRed = Color(0xFFED1235);

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _addressController;
  late String _method;

  @override
  void initState() {
    super.initState();
    _method = widget.initialSelection?.method ?? 'pickup';
    _addressController = TextEditingController(
      text: widget.initialSelection?.address ?? '',
    );
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Widget _option({
    required String method,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final selected = _method == method;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: selected
            ? const Color(0xFFFFF3F5)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            setState(() {
              _method = method;
            });
          },
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected
                    ? primaryRed
                    : const Color(0xFFE4E4E8),
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: primaryRed, size: 30),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Colors.black54,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: selected ? primaryRed : Colors.grey,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirm() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.pop(
      context,
      FulfilmentSelection(
        method: _method,
        address: _method == 'delivery'
            ? _addressController.text.trim()
            : '',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: const Text(
          'Pickup / Delivery',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
              children: [
                const Text(
                  'How would you like to receive it?',
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.equipmentName,
                  style: const TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 28),
                _option(
                  method: 'pickup',
                  title: 'Pickup',
                  subtitle: 'Collect equipment from the provider.',
                  icon: Icons.storefront_outlined,
                ),
                _option(
                  method: 'delivery',
                  title: 'Delivery',
                  subtitle: 'Request delivery to your address.',
                  icon: Icons.local_shipping_outlined,
                ),
                const SizedBox(height: 12),
                if (_method == 'pickup')
                  const Text(
                    'The pickup location must be confirmed with '
                    'the provider before collection.',
                    style: TextStyle(
                      color: Colors.black54,
                      height: 1.6,
                    ),
                  )
                else ...[
                  const Text(
                    'Delivery Address',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _addressController,
                    maxLines: 3,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: 'House number, street and town',
                      filled: true,
                      fillColor: const Color(0xFFF8F8FA),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    validator: (value) {
                      if (_method == 'delivery' &&
                          (value == null || value.trim().isEmpty)) {
                        return 'Please enter your delivery address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Delivery availability and charges must be '
                    'confirmed before checkout.',
                    style: TextStyle(
                      color: Colors.black54,
                      height: 1.6,
                    ),
                  ),
                ],
                const SizedBox(height: 30),
                SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _confirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryRed,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: const Text(
                      'Confirm Selection',
                      style: TextStyle(
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
      ),
    );
  }
}