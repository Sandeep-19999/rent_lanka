import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../features/user_discovery/services/auth_service.dart';

class WithdrawalHistoryScreen extends StatelessWidget {
  const WithdrawalHistoryScreen({super.key});

  static const Color primaryRed = Color(0xFFED1235);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FA),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 420,
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    18,
                    20,
                    18,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        padding: EdgeInsets.zero,
                        constraints:
                            const BoxConstraints(),
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Text(
                        'Withdrawal History',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(
                  height: 1,
                  color: Color(0xFFE8E8E8),
                ),

                Expanded(
                  child: StreamBuilder<
                      QuerySnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance
                        .collection('withdrawals')
                        .where(
                          'providerId',
                          isEqualTo:
                              AuthService.providerId,
                        )
                        .snapshots(),
                    builder: (
                      context,
                      snapshot,
                    ) {
                      if (snapshot.hasError) {
                        return const Center(
                          child: Text(
                            'Failed to load withdrawal history.',
                            style: TextStyle(
                              color: Colors.red,
                            ),
                          ),
                        );
                      }

                      if (!snapshot.hasData) {
                        return const Center(
                          child:
                              CircularProgressIndicator(
                            color: primaryRed,
                          ),
                        );
                      }

                      final documents =
                          snapshot.data!.docs.toList();

                      // Newest first.
                      documents.sort(
                        (a, b) {
                          final aTimestamp =
                              a.data()['requestedAt'];

                          final bTimestamp =
                              b.data()['requestedAt'];

                          if (aTimestamp
                                  is Timestamp &&
                              bTimestamp
                                  is Timestamp) {
                            return bTimestamp
                                .compareTo(
                              aTimestamp,
                            );
                          }

                          return 0;
                        },
                      );

                      if (documents.isEmpty) {
                        return const _EmptyHistory();
                      }

                      double totalRequested = 0;
                      int pendingCount = 0;

                      for (final document
                          in documents) {
                        final data =
                            document.data();

                        final amount =
                            data['amount'];

                        if (amount is num) {
                          totalRequested +=
                              amount.toDouble();
                        }

                        final status =
                            data['status']
                                    ?.toString()
                                    .toLowerCase() ??
                                'pending';

                        if (status ==
                            'pending') {
                          pendingCount++;
                        }
                      }

                      return ListView(
                        padding:
                            const EdgeInsets.fromLTRB(
                          20,
                          20,
                          20,
                          30,
                        ),
                        children: [
                          _SummaryCard(
                            totalRequested:
                                totalRequested,
                            requestCount:
                                documents.length,
                            pendingCount:
                                pendingCount,
                          ),

                          const SizedBox(
                            height: 24,
                          ),

                          const Text(
                            'Transactions',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight:
                                  FontWeight.w800,
                            ),
                          ),

                          const SizedBox(
                            height: 14,
                          ),

                          ...documents.map(
                            (document) {
                              final data =
                                  document.data();

                              final amountValue =
                                  data['amount'];

                              final double amount =
                                  amountValue is num
                                      ? amountValue
                                          .toDouble()
                                      : 0;

                              final bankName =
                                  data['bankName']
                                          ?.toString() ??
                                      'Bank';

                              final last4 =
                                  data['accountLast4']
                                          ?.toString() ??
                                      '';

                              final status =
                                  data['status']
                                          ?.toString()
                                          .toLowerCase() ??
                                      'pending';

                              final requestedAt =
                                  data['requestedAt'];

                              return Padding(
                                padding:
                                    const EdgeInsets
                                        .only(
                                  bottom: 12,
                                ),
                                child:
                                    _WithdrawalCard(
                                  amount: amount,
                                  bankName:
                                      bankName,
                                  last4:
                                      last4,
                                  status:
                                      status,
                                  requestedAt:
                                      requestedAt,
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    },
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

class _SummaryCard extends StatelessWidget {
  final double totalRequested;
  final int requestCount;
  final int pendingCount;

  const _SummaryCard({
    required this.totalRequested,
    required this.requestCount,
    required this.pendingCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: WithdrawalHistoryScreen.primaryRed,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'Total Withdrawal Requests',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Rs. ${_formatPrice(totalRequested)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: _SmallSummary(
                  label: 'Requests',
                  value: '$requestCount',
                ),
              ),
              Expanded(
                child: _SmallSummary(
                  label: 'Pending',
                  value: '$pendingCount',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SmallSummary extends StatelessWidget {
  final String label;
  final String value;

  const _SmallSummary({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _WithdrawalCard extends StatelessWidget {
  final double amount;
  final String bankName;
  final String last4;
  final String status;
  final dynamic requestedAt;

  const _WithdrawalCard({
    required this.amount,
    required this.bankName,
    required this.last4,
    required this.status,
    required this.requestedAt,
  });

  @override
  Widget build(BuildContext context) {
    final Color statusColor =
        _statusColor(status);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(15),
        border: Border.all(
          color: const Color(
            0xFFE5E5E5,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(
                0xFFFFEEF1,
              ),
              borderRadius:
                  BorderRadius.circular(
                12,
              ),
            ),
            child: const Icon(
              Icons
                  .account_balance_wallet_outlined,
              color: WithdrawalHistoryScreen
                  .primaryRed,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Rs. ${_formatPrice(amount)}',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  last4.isEmpty
                      ? bankName
                      : '$bankName •••• $last4',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  _formatDate(
                    requestedAt,
                  ),
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: statusColor
                  .withValues(
                alpha: 0.12,
              ),
              borderRadius:
                  BorderRadius.circular(
                20,
              ),
            ),
            child: Text(
              status.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight:
                    FontWeight.w800,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Color _statusColor(
    String status,
  ) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'approved':
        return Colors.green;

      case 'rejected':
      case 'cancelled':
        return Colors.red;

      default:
        return Colors.orange;
    }
  }

  static String _formatDate(
    dynamic value,
  ) {
    if (value is! Timestamp) {
      return 'Processing';
    }

    final date = value.toDate();

    final day =
        date.day.toString().padLeft(
              2,
              '0',
            );

    final month =
        date.month.toString().padLeft(
              2,
              '0',
            );

    final year = date.year;

    final hour =
        date.hour.toString().padLeft(
              2,
              '0',
            );

    final minute =
        date.minute.toString().padLeft(
              2,
              '0',
            );

    return '$day/$month/$year • $hour:$minute';
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 50,
              color: Colors.grey,
            ),
            SizedBox(height: 14),
            Text(
              'No withdrawal history yet',
              style: TextStyle(
                fontSize: 17,
                fontWeight:
                    FontWeight.w700,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Your withdrawal requests will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatPrice(
  double value,
) {
  if (value ==
      value.roundToDouble()) {
    return value.toInt().toString();
  }

  return value.toStringAsFixed(2);
}