class TransactionRecord {
  final String reference;
  final String type;
  final String date;
  final String status;
  final String amount;
  final bool isRefund;

  final String equipmentName;
  final String providerName;
  final String paymentMethod;
  final String description;

  const TransactionRecord({
    required this.reference,
    required this.type,
    required this.date,
    required this.status,
    required this.amount,
    required this.isRefund,
    required this.equipmentName,
    required this.providerName,
    required this.paymentMethod,
    required this.description,
  });
}
