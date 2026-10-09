import 'package:flutter/material.dart';

import '../models/bank_account_model.dart';
import '../services/withdrawal_service.dart';

import 'add_bank_account_screen.dart';
import 'withdrawal_history_screen.dart';

class WithdrawFundsScreen extends StatefulWidget {
  const WithdrawFundsScreen({
    super.key,
  });

  @override
  State<WithdrawFundsScreen> createState() =>
      _WithdrawFundsScreenState();
}

class _WithdrawFundsScreenState
    extends State<WithdrawFundsScreen> {
  static const Color primaryRed =
      Color(0xFFED1235);

  final WithdrawalService _withdrawalService =
      WithdrawalService();

  final TextEditingController amountController =
      TextEditingController();

  String? selectedBankId;

  bool isSubmitting = false;

  @override
  void dispose() {
    amountController.dispose();

    super.dispose();
  }

  Future<void> _openAddBankAccount() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const AddBankAccountScreen(),
      ),
    );
  }

  void _openWithdrawalHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const WithdrawalHistoryScreen(),
      ),
    );
  }

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

  Future<void> _confirmWithdrawal({
    required double availableBalance,
    required List<BankAccountModel>
        bankAccounts,
  }) async {
    if (isSubmitting) {
      return;
    }

    final double? amount =
        double.tryParse(
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

    if (bankAccounts.isEmpty) {
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

    final String bankId =
        selectedBankId ??
        bankAccounts.first.id;

    final bool bankExists =
        bankAccounts.any(
      (account) =>
          account.id == bankId,
    );

    if (!bankExists) {
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

    setState(() {
      isSubmitting = true;
    });

    try {
      await _withdrawalService
          .submitWithdrawal(
        amount: amount,
        bankAccountId: bankId,
      );

      if (!mounted) {
        return;
      }

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
      if (!mounted) {
        return;
      }

      String message =
          error.toString();

      message = message.replaceFirst(
        'Exception: ',
        '',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
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

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF8F8FA),

      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(
              maxWidth: 420,
            ),
            child: StreamBuilder<double>(
              stream: _withdrawalService
                  .watchCompletedRentalTotal(),
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
                    child:
                        CircularProgressIndicator(
                      color: primaryRed,
                    ),
                  );
                }

                final double
                    completedRentalValue =
                    rentalSnapshot.data ?? 0;

                return StreamBuilder<double>(
                  stream: _withdrawalService
                      .watchWithdrawalTotal(),
                  builder: (
                    context,
                    withdrawalSnapshot,
                  ) {
                    if (withdrawalSnapshot
                        .hasError) {
                      return _errorScreen(
                        'Failed to load withdrawals.',
                      );
                    }

                    if (!withdrawalSnapshot
                        .hasData) {
                      return const Center(
                        child:
                            CircularProgressIndicator(
                          color:
                              primaryRed,
                        ),
                      );
                    }

                    final double
                        withdrawnValue =
                        withdrawalSnapshot
                                .data ??
                            0;

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

  Widget _buildContent({
    required double availableBalance,
    required double completedRentalValue,
    required double withdrawnValue,
  }) {
    return SingleChildScrollView(
      padding:
          const EdgeInsets.fromLTRB(
        20,
        18,
        20,
        30,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          // HEADER
          Row(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.pop(
                    context,
                  );
                },
                padding:
                    EdgeInsets.zero,
                constraints:
                    const BoxConstraints(),
                icon: const Icon(
                  Icons
                      .arrow_back_ios_new,
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

              IconButton(
                tooltip:
                    'Withdrawal History',
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

          // BALANCE CARD
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.all(
              22,
            ),
            decoration:
                BoxDecoration(
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
                    color:
                        Colors.white70,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(
                  height: 10,
                ),

                Text(
                  'Rs. ${_formatPrice(availableBalance)}',
                  style:
                      const TextStyle(
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
                  style:
                      const TextStyle(
                    color:
                        Colors.white70,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(
                  height: 4,
                ),

                Text(
                  'Withdrawals: '
                  'Rs. ${_formatPrice(withdrawnValue)}',
                  style:
                      const TextStyle(
                    color:
                        Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 28,
          ),

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
            decoration:
                InputDecoration(
              hintText:
                  'Enter amount',
              prefixText:
                  'Rs. ',
              suffixIcon:
                  TextButton(
                onPressed: () {
                  _setMaxAmount(
                    availableBalance,
                  );
                },
                child:
                    const Text(
                  'MAX',
                  style:
                      TextStyle(
                    color:
                        primaryRed,
                    fontWeight:
                        FontWeight
                            .w800,
                  ),
                ),
              ),
              filled: true,
              fillColor:
                  Colors.white,
              border:
                  OutlineInputBorder(
                borderRadius:
                    BorderRadius
                        .circular(
                  12,
                ),
                borderSide:
                    const BorderSide(
                  color:
                      Color(
                    0xFFDDDDDD,
                  ),
                ),
              ),
              enabledBorder:
                  OutlineInputBorder(
                borderRadius:
                    BorderRadius
                        .circular(
                  12,
                ),
                borderSide:
                    const BorderSide(
                  color:
                      Color(
                    0xFFDDDDDD,
                  ),
                ),
              ),
              focusedBorder:
                  OutlineInputBorder(
                borderRadius:
                    BorderRadius
                        .circular(
                  12,
                ),
                borderSide:
                    const BorderSide(
                  color:
                      primaryRed,
                  width: 1.5,
                ),
              ),
            ),
          ),

          const SizedBox(
            height: 28,
          ),

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

          StreamBuilder<
              List<BankAccountModel>>(
            stream: _withdrawalService
                .watchMyBankAccounts(),
            builder: (
              context,
              snapshot,
            ) {
              if (snapshot.hasError) {
                return const Text(
                  'Failed to load bank accounts.',
                  style: TextStyle(
                    color:
                        Colors.red,
                  ),
                );
              }

              if (!snapshot.hasData) {
                return const Center(
                  child:
                      CircularProgressIndicator(
                    color:
                        primaryRed,
                  ),
                );
              }

              final bankAccounts =
                  snapshot.data ?? [];

              final String?
                  effectiveSelectedId =
                  bankAccounts.isEmpty
                      ? null
                      : selectedBankId !=
                                  null &&
                              bankAccounts.any(
                                (
                                  account,
                                ) =>
                                    account.id ==
                                    selectedBankId,
                              )
                          ? selectedBankId
                          : bankAccounts
                              .first.id;

              return Column(
                children: [
                  if (bankAccounts
                      .isEmpty)
                    _emptyBankCard()
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics:
                          const NeverScrollableScrollPhysics(),
                      itemCount:
                          bankAccounts
                              .length,
                      separatorBuilder:
                          (
                        context,
                        index,
                      ) {
                        return const SizedBox(
                          height: 10,
                        );
                      },
                      itemBuilder:
                          (
                        context,
                        index,
                      ) {
                        final account =
                            bankAccounts[
                                index];

                        return _bankCard(
                          account:
                              account,
                          isSelected:
                              account.id ==
                                  effectiveSelectedId,
                        );
                      },
                    ),

                  const SizedBox(
                    height: 15,
                  ),

                  SizedBox(
                    width:
                        double.infinity,
                    height: 50,
                    child:
                        OutlinedButton
                            .icon(
                      onPressed:
                          _openAddBankAccount,
                      icon:
                          const Icon(
                        Icons.add,
                      ),
                      label:
                          const Text(
                        'Add Bank Account',
                      ),
                      style:
                          OutlinedButton
                              .styleFrom(
                        foregroundColor:
                            Colors.black,
                        side:
                            const BorderSide(
                          color:
                              Color(
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

                  SizedBox(
                    width:
                        double.infinity,
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
                                    bankAccounts:
                                        bankAccounts,
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
                                  width:
                                      22,
                                  height:
                                      22,
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
                    Color(
                  0xFF888888,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bankCard({
    required BankAccountModel account,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () {
        setState(() {
          selectedBankId =
              account.id;
        });
      },
      borderRadius:
          BorderRadius.circular(
        14,
      ),
      child: Container(
        width:
            double.infinity,
        padding:
            const EdgeInsets.all(
          16,
        ),
        decoration:
            BoxDecoration(
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
                isSelected
                    ? 1.5
                    : 1,
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
              child:
                  const Icon(
                Icons
                    .account_balance,
                color:
                    primaryRed,
              ),
            ),

            const SizedBox(
              width: 14,
            ),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  Text(
                    account
                        .bankName,
                    style:
                        const TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight
                              .w800,
                    ),
                  ),

                  const SizedBox(
                    height: 5,
                  ),

                  Text(
                    '${account.maskedAccountNumber}'
                    '${account.accountHolderName.isNotEmpty ? ' - ${account.accountHolderName}' : ''}',
                    style:
                        const TextStyle(
                      fontSize: 13,
                      color:
                          Color(
                        0xFF777777,
                      ),
                    ),
                  ),

                  if (account
                      .branch
                      .isNotEmpty) ...[
                    const SizedBox(
                      height: 4,
                    ),
                    Text(
                      account
                          .branch,
                      style:
                          const TextStyle(
                        fontSize:
                            11,
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
                Icons
                    .check_circle,
                color:
                    primaryRed,
              ),
          ],
        ),
      ),
    );
  }

  Widget _emptyBankCard() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(
        22,
      ),
      decoration:
          BoxDecoration(
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
      child:
          const Column(
        children: [
          Icon(
            Icons
                .account_balance_outlined,
            size: 38,
            color:
                Colors.grey,
          ),

          SizedBox(
            height: 10,
          ),

          Text(
            'No bank account added',
            style:
                TextStyle(
              fontSize: 15,
              fontWeight:
                  FontWeight
                      .w700,
            ),
          ),

          SizedBox(
            height: 5,
          ),

          Text(
            'Add a bank account to withdraw your earnings.',
            textAlign:
                TextAlign.center,
            style:
                TextStyle(
              fontSize: 12,
              color:
                  Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorScreen(
    String message,
  ) {
    return Center(
      child: Text(
        message,
        style:
            const TextStyle(
          color: Colors.red,
        ),
      ),
    );
  }

  static String _formatPrice(
    double value,
  ) {
    if (value ==
        value.roundToDouble()) {
      return value
          .toInt()
          .toString();
    }

    return value.toStringAsFixed(
      2,
    );
  }
}