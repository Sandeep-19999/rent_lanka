import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/transaction_record.dart';

class TransactionPdfService {
  static Future<void> downloadReceipt(TransactionRecord transaction) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'RENT LANKA',
                style: pw.TextStyle(
                  fontSize: 26,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.red,
                ),
              ),

              pw.SizedBox(height: 5),

              pw.Text(
                'Transaction Receipt',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),

              pw.SizedBox(height: 30),

              pw.Divider(),

              pw.SizedBox(height: 20),

              _detailRow('Transaction ID', transaction.reference),

              _detailRow('Transaction type', transaction.type),

              _detailRow('Equipment', transaction.equipmentName),

              _detailRow('Provider', transaction.providerName),

              _detailRow('Date', transaction.date),

              _detailRow('Payment method', transaction.paymentMethod),

              _detailRow('Status', transaction.status),

              pw.SizedBox(height: 15),

              pw.Divider(),

              pw.SizedBox(height: 15),

              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    transaction.isRefund ? 'Refund amount' : 'Amount paid',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    transaction.amount,
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 30),

              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Text(
                  transaction.description,
                  style: const pw.TextStyle(fontSize: 11),
                ),
              ),

              pw.Spacer(),

              pw.Divider(),

              pw.Text(
                'Thank you for using Rent Lanka.',
                style: const pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey700,
                ),
              ),

              pw.SizedBox(height: 4),

              pw.Text(
                'This is a system-generated transaction receipt.',
                style: const pw.TextStyle(
                  fontSize: 9,
                  color: PdfColors.grey600,
                ),
              ),
            ],
          );
        },
      ),
    );

    final bytes = await pdf.save();

    await Printing.sharePdf(
      bytes: bytes,
      filename: 'Rent_Lanka_${transaction.reference}_Receipt.pdf',
    );
  }

  static pw.Widget _detailRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 14),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 150,
            child: pw.Text(
              label,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Expanded(child: pw.Text(value)),
        ],
      ),
    );
  }
}
