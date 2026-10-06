import 'package:flutter/material.dart';

class TransactionHistoryScreen extends StatelessWidget {
  const TransactionHistoryScreen({super.key});

  static const Color primaryRed = Color(0xFFED1235);
  static const Color darkText = Color(0xFF242424);
  static const Color greyText = Color(0xFF929292);
  static const Color successGreen = Color(0xFF16A34A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),

                  const SizedBox(height: 42),

                  _buildTransactionItem(
                    reference: 'SG-1048',
                    type: 'Payment',
                    date: '10 Sep',
                    status: 'Confirmed',
                    amount: 'Rs. 10,400',
                    isRefund: false,
                  ),

                  const SizedBox(height: 34),

                  _buildTransactionItem(
                    reference: 'SG-0991',
                    type: 'Refund',
                    date: '6 Aug',
                    status: 'Completed',
                    amount: '+ Rs. 2,000',
                    isRefund: true,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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

        const SizedBox(width: 32),

        const Text(
          'Transaction history',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: darkText,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionItem({
    required String reference,
    required String type,
    required String date,
    required String status,
    required String amount,
    required bool isRefund,
  }) {
    final Color accentColor = isRefund ? successGreen : primaryRed;

    final Color iconBackground = isRefund
        ? const Color(0xFFE0F8E9)
        : const Color(0xFFFFEDF0);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 52,
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: iconBackground,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Container(
            width: 22,
            height: 22,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: accentColor, width: 2),
            ),
            child: Icon(Icons.add, size: 15, color: accentColor),
          ),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$reference ($type)',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: darkText,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                '$date • $status',
                style: const TextStyle(fontSize: 13, color: greyText),
              ),
            ],
          ),
        ),

        const SizedBox(width: 12),

        Text(
          amount,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: isRefund ? successGreen : darkText,
          ),
        ),
      ],
    );
  }
}
