import 'package:flutter/material.dart';

import '../models/transaction_record.dart';
import 'transaction_details_screen.dart';

class TransactionHistoryScreen extends StatelessWidget {
  const TransactionHistoryScreen({super.key});

  static const Color primaryRed = Color(0xFFED1235);

  static const Color darkText = Color(0xFF242424);

  static const Color greyText = Color(0xFF929292);

  static const Color successGreen = Color(0xFF16A34A);

  static const List<TransactionRecord> transactions = [
    TransactionRecord(
      reference: 'SG-1048',
      type: 'Payment',
      date: '10 Sep 2026',
      status: 'Confirmed',
      amount: 'Rs. 10,400',
      isRefund: false,
      equipmentName: 'SS Cricket Bat',
      providerName: 'Kamal Sports Gear',
      paymentMethod: 'Visa ending 4242',
      description: 'Payment for the rental of SS Cricket Bat. The booking and payment were confirmed successfully.',
    ),
    TransactionRecord(
      reference: 'SG-0991',
      type: 'Refund',
      date: '6 Aug 2026',
      status: 'Completed',
      amount: 'Rs. 2,000',
      isRefund: true,
      equipmentName: 'Yonex Badminton Racket',
      providerName: 'City Sports Shop',
      paymentMethod: 'Visa ending 4242',
      description: 'Refund issued for the cancelled equipment rental. The refund has been completed successfully.',
    ),
  ];

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

                  ...transactions.map((transaction) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 28),
                      child: _buildTransactionItem(
                        context: context,
                        transaction: transaction,
                      ),
                    );
                  }),
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
    required BuildContext context,
    required TransactionRecord transaction,
  }) {
    final Color accentColor = transaction.isRefund ? successGreen : primaryRed;

    final Color iconBackground = transaction.isRefund
        ? const Color(0xFFE0F8E9)
        : const Color(0xFFFFEDF0);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TransactionDetailsScreen(transaction: transaction),
          ),
        );
      },
      borderRadius: BorderRadius.circular(15),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
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
                    '${transaction.reference} (${transaction.type})',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: darkText,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    '${transaction.date} - ${transaction.status}',
                    style: const TextStyle(fontSize: 13, color: greyText),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  transaction.isRefund
                      ? '+ ${transaction.amount}'
                      : transaction.amount,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: transaction.isRefund ? successGreen : darkText,
                  ),
                ),

                const SizedBox(height: 5),

                const Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: Color(0xFFC0C0C0),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
