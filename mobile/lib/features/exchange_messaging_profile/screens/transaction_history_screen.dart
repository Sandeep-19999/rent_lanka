import '../services/transaction_service.dart';
import 'dart:async';
import 'package:flutter/material.dart';

import '../models/transaction_record.dart';
import 'transaction_details_screen.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState
    extends State<TransactionHistoryScreen> {
  static const Color primaryRed = Color(0xFFED1235);
  static const Color darkText = Color(0xFF242424);
  static const Color greyText = Color(0xFF7D7D7D);
  static const Color borderColor = Color(0xFFE7E7E7);
  static const Color backgroundColor = Color(0xFFF8F8F8);
  static const Color successGreen = Color(0xFF24945E);

  String _selectedFilter = 'All';

  static const List<String> filters = [
    'All',
    'Payments',
    'Refunds',
  ];

  List<TransactionRecord> transactions = [];
  StreamSubscription<List<TransactionRecord>>? _subscription;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _subscription = TransactionService().watchMyTransactions().listen((records) {
      if (mounted) setState(() { transactions = records; _loading = false; _error = null; });
    }, onError: (Object error) {
      if (mounted) setState(() { _loading = false; _error = error.toString(); });
    });
  }

  @override
  void dispose() { _subscription?.cancel(); super.dispose(); }

  List<TransactionRecord> get _filteredTransactions {
    switch (_selectedFilter) {
      case 'Payments':
        return transactions
            .where((transaction) => !transaction.isRefund)
            .toList();

      case 'Refunds':
        return transactions
            .where((transaction) => transaction.isRefund)
            .toList();

      default:
        return transactions;
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<TransactionRecord> filtered =
        _filteredTransactions;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: darkText,
          ),
        ),
        titleSpacing: 0,
        title: const Text(
          'Transaction History',
          style: TextStyle(
            color: darkText,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 500,
            ),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                      18,
                      20,
                      18,
                      30,
                    ),
                    children: [
                      _buildSummaryCard(),

                      const SizedBox(height: 22),

                      const Text(
                        'Transactions',
                        style: TextStyle(
                          color: darkText,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 12),

                      _buildFilters(),

                      const SizedBox(height: 18),

                      if (_loading)
                        const Center(child: CircularProgressIndicator())
                      else if (_error != null)
                        Text(_error!, style: const TextStyle(color: primaryRed))
                      else if (filtered.isEmpty)
                        _buildEmptyState()
                      else
                        ...filtered.map(
                          (transaction) =>
                              Padding(
                            padding:
                                const EdgeInsets.only(
                              bottom: 12,
                            ),
                            child:
                                _buildTransactionCard(
                              transaction,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    final int paymentCount = transactions
        .where((transaction) => !transaction.isRefund)
        .length;

    final int refundCount = transactions
        .where((transaction) => transaction.isRefund)
        .length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F3),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.receipt_long_outlined,
                  color: primaryRed,
                  size: 25,
                ),
              ),
              SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your transactions',
                      style: TextStyle(
                        color: darkText,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'View your rental payments and refunds.',
                      style: TextStyle(
                        color: greyText,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  icon: Icons.payments_outlined,
                  label: 'Payments',
                  value: '$paymentCount',
                  color: primaryRed,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: _buildSummaryItem(
                  icon:
                      Icons.keyboard_return_rounded,
                  label: 'Refunds',
                  value: '$refundCount',
                  color: successGreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(
                alpha: 0.10,
              ),
              borderRadius:
                  BorderRadius.circular(11),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: darkText,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    color: greyText,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final bool selected =
              filter == _selectedFilter;

          return Padding(
            padding:
                const EdgeInsets.only(
              right: 8,
            ),
            child: ChoiceChip(
              label: Text(filter),
              selected: selected,
              showCheckmark: false,
              selectedColor:
                  const Color(0xFFFFE9ED),
              backgroundColor:
                  Colors.white,
              side: BorderSide(
                color: selected
                    ? primaryRed
                    : borderColor,
              ),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(
                  30,
                ),
              ),
              labelStyle: TextStyle(
                color: selected
                    ? primaryRed
                    : greyText,
                fontWeight: selected
                    ? FontWeight.w700
                    : FontWeight.w600,
              ),
              onSelected: (_) {
                setState(() {
                  _selectedFilter =
                      filter;
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTransactionCard(
    TransactionRecord transaction,
  ) {
    final Color accentColor =
        transaction.isRefund
            ? successGreen
            : primaryRed;

    final Color iconBackground =
        transaction.isRefund
            ? const Color(0xFFEAF8F1)
            : const Color(0xFFFFEEF1);

    return Material(
      color: Colors.white,
      borderRadius:
          BorderRadius.circular(18),
      child: InkWell(
        borderRadius:
            BorderRadius.circular(18),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  TransactionDetailsScreen(
                transaction: transaction,
              ),
            ),
          );
        },
        child: Container(
          padding:
              const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(18),
            border: Border.all(
              color: borderColor,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius:
                      BorderRadius.circular(
                    14,
                  ),
                ),
                child: Icon(
                  transaction.isRefund
                      ? Icons
                          .keyboard_return_rounded
                      : Icons
                          .payments_outlined,
                  color: accentColor,
                  size: 24,
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            transaction
                                .equipmentName,
                            maxLines: 1,
                            overflow:
                                TextOverflow
                                    .ellipsis,
                            style:
                                const TextStyle(
                              color: darkText,
                              fontSize: 15,
                              fontWeight:
                                  FontWeight
                                      .w800,
                            ),
                          ),
                        ),

                        const SizedBox(
                          width: 8,
                        ),

                        Text(
                          transaction.isRefund
                              ? '+ ${transaction.amount}'
                              : transaction.amount,
                          style: TextStyle(
                            color:
                                transaction
                                        .isRefund
                                    ? successGreen
                                    : darkText,
                            fontSize: 14,
                            fontWeight:
                                FontWeight.w800,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 5),

                    Text(
                      '${transaction.type} • ${transaction.reference}',
                      style: const TextStyle(
                        color: greyText,
                        fontSize: 11,
                      ),
                    ),

                    const SizedBox(height: 7),

                    Row(
                      children: [
                        Text(
                          transaction.date,
                          style:
                              const TextStyle(
                            color: greyText,
                            fontSize: 11,
                          ),
                        ),

                        const SizedBox(
                          width: 8,
                        ),

                        Container(
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration:
                              BoxDecoration(
                            color: accentColor
                                .withValues(
                              alpha: 0.10,
                            ),
                            borderRadius:
                                BorderRadius
                                    .circular(
                              20,
                            ),
                          ),
                          child: Text(
                            transaction.status,
                            style:
                                TextStyle(
                              color:
                                  accentColor,
                              fontSize: 9,
                              fontWeight:
                                  FontWeight
                                      .w700,
                            ),
                          ),
                        ),

                        const Spacer(),

                        const Icon(
                          Icons
                              .chevron_right_rounded,
                          color: Color(
                            0xFFAAAAAA,
                          ),
                          size: 20,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 50,
        horizontal: 25,
      ),
      child: const Column(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor:
                Color(0xFFFFEEF1),
            child: Icon(
              Icons.receipt_long_outlined,
              color: primaryRed,
              size: 32,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'No transactions found',
            style: TextStyle(
              color: darkText,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Your rental payments and refunds will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: greyText,
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}