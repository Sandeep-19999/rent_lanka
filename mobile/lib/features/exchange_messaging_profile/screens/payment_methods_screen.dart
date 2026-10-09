import 'package:flutter/material.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  static const Color primaryRed = Color(0xFFED1235);

  static const Color darkText = Color(0xFF242424);

  String _defaultMethod = 'visa';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),

                  const SizedBox(height: 36),

                  const Text(
                    'SAVED PAYMENT METHODS',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF929292),
                    ),
                  ),

                  const SizedBox(height: 18),

                  _buildCard(
                    id: 'visa',
                    brand: 'Visa',
                    lastFour: '4242',
                    expiry: '12/28',
                    icon: Icons.credit_card,
                  ),

                  const SizedBox(height: 14),

                  _buildCard(
                    id: 'mastercard',
                    brand: 'Mastercard',
                    lastFour: '5521',
                    expiry: '08/27',
                    icon: Icons.credit_card,
                  ),

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        InkWell(
          onTap: () {
            Navigator.maybePop(context);
          },
          borderRadius: BorderRadius.circular(50),
          child: const Padding(
            padding: EdgeInsets.all(4),
            child: Icon(Icons.arrow_back_ios_new, size: 22, color: darkText),
          ),
        ),
        const SizedBox(width: 28),
        const Expanded(
          child: Text(
            'Payment methods',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: darkText,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCard({
    required String id,
    required String brand,
    required String lastFour,
    required String expiry,
    required IconData icon,
  }) {
    final bool selected = _defaultMethod == id;

    return InkWell(
      onTap: () {
        setState(() {
          _defaultMethod = id;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFFF3F5) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? primaryRed : const Color(0xFFE0E0E0),
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF2FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFF1565FF)),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$brand •••• $lastFour',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: darkText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Expires $expiry',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF929292),
                    ),
                  ),
                ],
              ),
            ),

            if (selected)
              const Icon(Icons.check_circle, color: primaryRed)
            else
              const Icon(Icons.circle_outlined, color: Color(0xFFC5C5C5)),
          ],
        ),
      ),
    );
  }

}
