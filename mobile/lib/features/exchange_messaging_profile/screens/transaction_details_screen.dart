import 'package:flutter/material.dart';

import '../models/transaction_record.dart';
import '../services/transaction_pdf_service.dart';

class TransactionDetailsScreen extends StatefulWidget {
  final TransactionRecord transaction;

  const TransactionDetailsScreen({super.key, required this.transaction});

  @override
  State<TransactionDetailsScreen> createState() =>
      _TransactionDetailsScreenState();
}

class _TransactionDetailsScreenState extends State<TransactionDetailsScreen> {
  static const Color primaryRed = Color(0xFFED1235);

  static const Color darkText = Color(0xFF242424);

  static const Color greyText = Color(0xFF929292);

  static const Color successGreen = Color(0xFF16A34A);

  bool _isGeneratingPdf = false;

  Future<void> _downloadPdf() async {
    setState(() {
      _isGeneratingPdf = true;
    });

    try {
      await TransactionPdfService.downloadReceipt(widget.transaction);
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to create PDF: $error')));
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingPdf = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final transaction = widget.transaction;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
              child: Column(
                children: [
                  _buildHeader(),

                  const SizedBox(height: 32),

                  _buildStatusCard(),

                  const SizedBox(height: 26),

                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildDetailsCard(transaction),

                          const SizedBox(height: 20),

                          _buildDescriptionCard(transaction),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _isGeneratingPdf ? null : _downloadPdf,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryRed,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      icon: _isGeneratingPdf
                          ? const SizedBox(
                              width: 19,
                              height: 19,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.picture_as_pdf_outlined),
                      label: Text(
                        _isGeneratingPdf
                            ? 'Creating PDF...'
                            : 'Download PDF Receipt',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
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

        const SizedBox(width: 26),

        const Expanded(
          child: Text(
            'Transaction details',
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

  Widget _buildStatusCard() {
    final transaction = widget.transaction;

    final Color color = transaction.isRefund ? successGreen : primaryRed;

    final Color background = transaction.isRefund
        ? const Color(0xFFE9F9EF)
        : const Color(0xFFFFF1F3);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 2),
            ),
            child: Icon(
              transaction.isRefund
                  ? Icons.keyboard_return_rounded
                  : Icons.check_rounded,
              color: color,
              size: 27,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            transaction.status,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            transaction.amount,
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w800,
              color: darkText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard(TransactionRecord transaction) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE1E1E1)),
      ),
      child: Column(
        children: [
          _detailRow('Transaction ID', transaction.reference),
          _divider(),
          _detailRow('Type', transaction.type),
          _divider(),
          _detailRow('Equipment', transaction.equipmentName),
          _divider(),
          _detailRow('Provider', transaction.providerName),
          _divider(),
          _detailRow('Date', transaction.date),
          _divider(),
          _detailRow('Payment method', transaction.paymentMethod),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard(TransactionRecord transaction) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Transaction note',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: darkText,
            ),
          ),

          const SizedBox(height: 7),

          Text(
            transaction.description,
            style: const TextStyle(fontSize: 13, height: 1.45, color: greyText),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: greyText),
            ),
          ),
          const SizedBox(width: 20),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: darkText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Divider(height: 1, color: Color(0xFFEAEAEA)),
    );
  }
}
