import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import 'add_bank_account_screen.dart';
import 'withdrawal_history_screen.dart';

class WithdrawFundsScreen extends StatefulWidget {
  const WithdrawFundsScreen({super.key});

  @override
  State<WithdrawFundsScreen> createState() =>
      _WithdrawFundsScreenState();
}

class _WithdrawFundsScreenState
    extends State<WithdrawFundsScreen> {
  static const Color primaryRed = Color(0xFFED1235);

  final TextEditingController amountController =
      TextEditingController();

  String? selectedBankId;
  bool isSubmitting = false;

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  // =========================================================
  // OPEN ADD BANK ACCOUNT
  // =========================================================
  Future<void> _openAddBankAccount() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const AddBankAccountScreen(),
      ),
    );
  }

  // =========================================================
  // OPEN WITHDRAWAL HISTORY
  // =========================================================
  void _openWithdrawalHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const WithdrawalHistoryScreen(),
      ),
    );
  }

  // =========================================================
  // COMPLETED RENTAL TOTAL
  // =========================================================
  double _calculateCompletedRentalValue(
    List<QueryDocumentSnapshot<Map<String, dynamic>>>
        documents,
  ) {
    double total = 0;

    for (final document in documents) {
      final data = document.data();

      final String status =
          data['status']?.toString().toLowerCase() ?? '';

      if (status == 'completed') {
        final amount = data['totalAmount'];

        if (amount is num) {
          total += amount.toDouble();
        }
      }
    }

    return total;
  }

  // =========================================================
  // WITHDRAWAL TOTAL
  // =========================================================
  double _calculateWithdrawalTotal(
    List<QueryDocumentSnapshot<Map<String, dynamic>>>
        documents,
  ) {
    double total = 0;

    for (final document in documents) {
      final data = document.data();

      final String status =
          data['status']?.toString().toLowerCase() ??
              'pending';

      // Rejected or cancelled requests should
      // not reduce the available balance.
      if (status == 'rejected' ||
          status == 'cancelled') {
        continue;
      }

      final amount = data['amount'];

      if (amount is num) {
        total += amount.toDouble();
      }
    }

    return total;
  }

  // =========================================================
  // MAX BUTTON
  // =========================================================
  void _setMaxAmount(
    double availableBalance,
  ) {
    if (availableBalance <= 0) {
      amountController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No balance is currently available to withdraw.',
          ),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    amountController.text =
        availableBalance.toStringAsFixed(0);

    setState(() {});
  }

  // =========================================================
  // CONFIRM WITHDRAWAL
  // =========================================================
  Future<void> _confirmWithdrawal({
    required double availableBalance,
    required List<
            QueryDocumentSnapshot<Map<String, dynamic>>>
        bankDocuments,
  }) async {
    if (isSubmitting) return;

    final double? amount = double.tryParse(
      amountController.text.trim(),
    );

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter a valid withdrawal amount.',
          ),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    if (availableBalance <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'You do not have any available balance to withdraw.',
          ),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    if (amount > availableBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Maximum available amount is Rs. '
            '${_formatPrice(availableBalance)}.',
          ),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    if (bankDocuments.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please add a bank account first.',
          ),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    final String effectiveBankId =
        selectedBankId ?? bankDocuments.first.id;

    QueryDocumentSnapshot<Map<String, dynamic>>?
        selectedDocument;

    for (final document in bankDocuments) {
      if (document.id == effectiveBankId) {
        selectedDocument = document;
        break;
      }
    }

    if (selectedDocument == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select a bank account.',
          ),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    final selectedBank = selectedDocument;
    final bankData = selectedBank.data();

    final String bankName =
        bankData['bankName']?.toString() ?? 'Bank';

    final String accountHolder =
        bankData['accountHolderName']?.toString() ?? '';

    final String accountNumber =
        bankData['accountNumber']?.toString() ?? '';

    final String branch =
        bankData['branch']?.toString() ?? '';

    setState(() {
      isSubmitting = true;
    });

    try {
      // Latest completed rentals
      final rentalSnapshot =
          await FirebaseFirestore.instance
              .collection('rental_requests')
              .where(
                'providerId',
                isEqualTo: AuthService.providerId,
              )
              .get();

      // Latest withdrawals
      final withdrawalSnapshot =
          await FirebaseFirestore.instance
              .collection('withdrawals')
              .where(
                'providerId',
                isEqualTo: AuthService.providerId,
              )
              .get();

      final double latestCompletedValue =
          _calculateCompletedRentalValue(
        rentalSnapshot.docs,
      );

      final double latestWithdrawnValue =
          _calculateWithdrawalTotal(
        withdrawalSnapshot.docs,
      );

      double latestAvailableBalance =
          latestCompletedValue -
              latestWithdrawnValue;

      if (latestAvailableBalance < 0) {
        latestAvailableBalance = 0;
      }

      // Balance may have changed while page was open.
      if (amount > latestAvailableBalance) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Your available balance has changed. '
              'Current balance is Rs. '
              '${_formatPrice(latestAvailableBalance)}.',
            ),
            backgroundColor: Colors.red,
          ),
        );

        return;
      }

      // Save withdrawal request
      await FirebaseFirestore.instance
          .collection('withdrawals')
          .add({
        'providerId': AuthService.providerId,
        'bankAccountId': selectedBank.id,
        'bankName': bankName,
        'accountHolderName': accountHolder,
        'accountLast4':
            _getLastFour(accountNumber),
        'branch': branch,
        'amount': amount,
        'status': 'pending',
        'requestedAt':
            FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      amountController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Withdrawal request for Rs. '
            '${_formatPrice(amount)} '
            'submitted successfully.',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to submit withdrawal: $error',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
    }
  }

  // =========================================================
  // BUILD
  // =========================================================
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

            // Rental earnings
            child: StreamBuilder<
                QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('rental_requests')
                  .where(
                    'providerId',
                    isEqualTo: AuthService.providerId,
                  )
                  .snapshots(),
              builder: (
                context,
                rentalSnapshot,
              ) {
                if (rentalSnapshot.hasError) {
                  return _errorScreen(
                    'Failed to load rental earnings.',
                  );
                }

                if (!rentalSnapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: primaryRed,
                    ),
                  );
                }

                final double completedRentalValue =
                    _calculateCompletedRentalValue(
                  rentalSnapshot.data!.docs,
                );

                // Withdrawals
                return StreamBuilder<
                    QuerySnapshot<
                        Map<String, dynamic>>>(
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
                    withdrawalSnapshot,
                  ) {
                    if (withdrawalSnapshot.hasError) {
                      return _errorScreen(
                        'Failed to load withdrawals.',
                      );
                    }

                    if (!withdrawalSnapshot.hasData) {
                      return const Center(
                        child:
                            CircularProgressIndicator(
                          color: primaryRed,
                        ),
                      );
                    }

                    final double withdrawnValue =
                        _calculateWithdrawalTotal(
                      withdrawalSnapshot.data!.docs,
                    );

                    double availableBalance =
                        completedRentalValue -
                            withdrawnValue;

                    if (availableBalance < 0) {
                      availableBalance = 0;
                    }

                    return _buildContent(
                      availableBalance:
                          availableBalance,
                      completedRentalValue:
                          completedRentalValue,
                      withdrawnValue:
                          withdrawnValue,
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // =========================================================
  // MAIN CONTENT
  // =========================================================
  Widget _buildContent({
    required double availableBalance,
    required double completedRentalValue,
    required double withdrawnValue,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        20,
        18,
        20,
        30,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          // =================================================
          // HEADER
          // =================================================
          Row(
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

              const SizedBox(
                width: 14,
              ),

              const Expanded(
                child: Text(
                  'Withdraw Funds',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
              ),

              // HISTORY BUTTON
              IconButton(
                tooltip: 'Withdrawal History',
                onPressed:
                    _openWithdrawalHistory,
                icon: const Icon(
                  Icons.history,
                  size: 26,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 30,
          ),

          // =================================================
          // BALANCE CARD
          // =================================================
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(
              22,
            ),
            decoration: BoxDecoration(
              color: primaryRed,
              borderRadius:
                  BorderRadius.circular(
                18,
              ),
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Available Balance to Withdraw',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(
                  height: 10,
                ),

                Text(
                  'Rs. ${_formatPrice(availableBalance)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),

                const SizedBox(
                  height: 15,
                ),

                Text(
                  'Completed rentals: '
                  'Rs. ${_formatPrice(completedRentalValue)}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(
                  height: 4,
                ),

                Text(
                  'Withdrawals: '
                  'Rs. ${_formatPrice(withdrawnValue)}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 28,
          ),

          // =================================================
          // WITHDRAWAL AMOUNT
          // =================================================
          const Text(
            'Enter Withdrawal Amount',
            style: TextStyle(
              fontSize: 15,
              fontWeight:
                  FontWeight.w700,
            ),
          ),

          const SizedBox(
            height: 10,
          ),

          TextField(
            controller:
                amountController,
            keyboardType:
                const TextInputType
                    .numberWithOptions(
              decimal: true,
            ),
            decoration: InputDecoration(
              hintText: 'Enter amount',
              prefixText: 'Rs. ',

              suffixIcon: TextButton(
                onPressed: () {
                  _setMaxAmount(
                    availableBalance,
                  );
                },
                child: const Text(
                  'MAX',
                  style: TextStyle(
                    color: primaryRed,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
              ),

              filled: true,
              fillColor: Colors.white,

              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(
                  12,
                ),
                borderSide:
                    const BorderSide(
                  color:
                      Color(0xFFDDDDDD),
                ),
              ),

              enabledBorder:
                  OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(
                  12,
                ),
                borderSide:
                    const BorderSide(
                  color:
                      Color(0xFFDDDDDD),
                ),
              ),

              focusedBorder:
                  OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(
                  12,
                ),
                borderSide:
                    const BorderSide(
                  color: primaryRed,
                  width: 1.5,
                ),
              ),
            ),
          ),

          const SizedBox(
            height: 28,
          ),

          // =================================================
          // BANK ACCOUNT TITLE
          // =================================================
          const Text(
            'Select Bank Account',
            style: TextStyle(
              fontSize: 15,
              fontWeight:
                  FontWeight.w700,
            ),
          ),

          const SizedBox(
            height: 10,
          ),

          // =================================================
          // BANK ACCOUNTS
          // =================================================
          StreamBuilder<
              QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('bank_accounts')
                .where(
                  'providerId',
                  isEqualTo:
                      AuthService.providerId,
                )
                .snapshots(),
            builder: (
              context,
              bankSnapshot,
            ) {
              if (bankSnapshot.hasError) {
                return const Text(
                  'Failed to load bank accounts.',
                  style: TextStyle(
                    color: Colors.red,
                  ),
                );
              }

              if (!bankSnapshot.hasData) {
                return const Center(
                  child:
                      CircularProgressIndicator(
                    color: primaryRed,
                  ),
                );
              }

              final bankDocuments =
                  bankSnapshot.data!.docs;

              return Column(
                children: [
                  if (bankDocuments.isEmpty)
                    _emptyBankCard()
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics:
                          const NeverScrollableScrollPhysics(),
                      itemCount:
                          bankDocuments.length,
                      separatorBuilder: (
                        context,
                        index,
                      ) {
                        return const SizedBox(
                          height: 10,
                        );
                      },
                      itemBuilder: (
                        context,
                        index,
                      ) {
                        final document =
                            bankDocuments[index];

                        final data =
                            document.data();

                        final String bankName =
                            data['bankName']
                                    ?.toString() ??
                                'Bank';

                        final String
                            accountHolder =
                            data['accountHolderName']
                                    ?.toString() ??
                                '';

                        final String
                            accountNumber =
                            data['accountNumber']
                                    ?.toString() ??
                                '';

                        final String branch =
                            data['branch']
                                    ?.toString() ??
                                '';

                        final String
                            effectiveSelectedId =
                            selectedBankId ??
                                bankDocuments
                                    .first.id;

                        return _bankCard(
                          documentId:
                              document.id,
                          bankName:
                              bankName,
                          accountHolder:
                              accountHolder,
                          accountNumber:
                              accountNumber,
                          branch: branch,
                          isSelected:
                              document.id ==
                                  effectiveSelectedId,
                        );
                      },
                    ),

                  const SizedBox(
                    height: 15,
                  ),

                  // ADD BANK ACCOUNT
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child:
                        OutlinedButton.icon(
                      onPressed:
                          _openAddBankAccount,
                      icon: const Icon(
                        Icons.add,
                      ),
                      label: const Text(
                        'Add Bank Account',
                      ),
                      style:
                          OutlinedButton
                              .styleFrom(
                        foregroundColor:
                            Colors.black,
                        side:
                            const BorderSide(
                          color: Color(
                            0xFFDDDDDD,
                          ),
                        ),
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            10,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 30,
                  ),

                  // CONFIRM WITHDRAWAL
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child:
                        ElevatedButton(
                      onPressed:
                          isSubmitting
                              ? null
                              : () {
                                  _confirmWithdrawal(
                                    availableBalance:
                                        availableBalance,
                                    bankDocuments:
                                        bankDocuments,
                                  );
                                },
                      style:
                          ElevatedButton
                              .styleFrom(
                        backgroundColor:
                            primaryRed,
                        foregroundColor:
                            Colors.white,
                        disabledBackgroundColor:
                            primaryRed
                                .withValues(
                          alpha: 0.6,
                        ),
                        elevation: 0,
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            10,
                          ),
                        ),
                      ),
                      child:
                          isSubmitting
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth:
                                        2,
                                    color:
                                        Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Confirm Withdrawal',
                                  style:
                                      TextStyle(
                                    fontSize:
                                        16,
                                    fontWeight:
                                        FontWeight
                                            .w800,
                                  ),
                                ),
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(
            height: 16,
          ),

          const Center(
            child: Text(
              'Withdrawal requests will be processed using the selected bank account.',
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color:
                    Color(0xFF888888),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // BANK CARD
  // =========================================================
  Widget _bankCard({
    required String documentId,
    required String bankName,
    required String accountHolder,
    required String accountNumber,
    required String branch,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () {
        setState(() {
          selectedBankId =
              documentId;
        });
      },
      borderRadius:
          BorderRadius.circular(
        14,
      ),
      child: Container(
        width: double.infinity,
        padding:
            const EdgeInsets.all(
          16,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(
            14,
          ),
          border: Border.all(
            color: isSelected
                ? primaryRed
                : const Color(
                    0xFFDDDDDD,
                  ),
            width:
                isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration:
                  BoxDecoration(
                color:
                    const Color(
                  0xFFF2F2F2,
                ),
                borderRadius:
                    BorderRadius
                        .circular(
                  12,
                ),
              ),
              child: const Icon(
                Icons.account_balance,
                color: primaryRed,
              ),
            ),

            const SizedBox(
              width: 14,
            ),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    bankName,
                    style:
                        const TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),

                  const SizedBox(
                    height: 5,
                  ),

                  Text(
                    '${_maskAccountNumber(accountNumber)}'
                    '${accountHolder.isNotEmpty ? ' - $accountHolder' : ''}',
                    style:
                        const TextStyle(
                      fontSize: 13,
                      color: Color(
                        0xFF777777,
                      ),
                    ),
                  ),

                  if (branch.isNotEmpty) ...[
                    const SizedBox(
                      height: 4,
                    ),

                    Text(
                      branch,
                      style:
                          const TextStyle(
                        fontSize: 11,
                        color:
                            Colors.grey,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: primaryRed,
              ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // EMPTY BANK CARD
  // =========================================================
  Widget _emptyBankCard() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(
        22,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(
          14,
        ),
        border: Border.all(
          color:
              const Color(
            0xFFDDDDDD,
          ),
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons
                .account_balance_outlined,
            size: 38,
            color: Colors.grey,
          ),

          SizedBox(
            height: 10,
          ),

          Text(
            'No bank account added',
            style: TextStyle(
              fontSize: 15,
              fontWeight:
                  FontWeight.w700,
            ),
          ),

          SizedBox(
            height: 5,
          ),

          Text(
            'Add a bank account to withdraw your earnings.',
            textAlign:
                TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // ERROR
  // =========================================================
  Widget _errorScreen(
    String message,
  ) {
    return Center(
      child: Text(
        message,
        style: const TextStyle(
          color: Colors.red,
        ),
      ),
    );
  }

  // =========================================================
  // ACCOUNT NUMBER MASK
  // =========================================================
  static String _maskAccountNumber(
    String accountNumber,
  ) {
    if (accountNumber.isEmpty) {
      return '••••';
    }

    return '•••• ${_getLastFour(accountNumber)}';
  }

  // =========================================================
  // LAST 4 DIGITS
  // =========================================================
  static String _getLastFour(
    String accountNumber,
  ) {
    if (accountNumber.length <= 4) {
      return accountNumber;
    }

    return accountNumber.substring(
      accountNumber.length - 4,
    );
  }

  // =========================================================
  // PRICE FORMAT
  // =========================================================
  static String _formatPrice(
    double value,
  ) {
    if (value ==
        value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(2);
  }
}