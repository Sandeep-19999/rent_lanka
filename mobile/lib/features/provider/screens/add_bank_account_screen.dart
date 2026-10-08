import 'package:flutter/material.dart';

import '../services/withdrawal_service.dart';

class AddBankAccountScreen extends StatefulWidget {
  const AddBankAccountScreen({
    super.key,
  });

  @override
  State<AddBankAccountScreen> createState() =>
      _AddBankAccountScreenState();
}

class _AddBankAccountScreenState
    extends State<AddBankAccountScreen> {
  static const Color primaryRed =
      Color(0xFFED1235);

  final WithdrawalService _withdrawalService =
      WithdrawalService();

  final TextEditingController
      accountHolderController =
      TextEditingController();

  final TextEditingController
      accountNumberController =
      TextEditingController();

  final TextEditingController
      branchController =
      TextEditingController();

  String? selectedBank;

  bool isSaving = false;

  final List<String> banks = [
    'Commercial Bank',
    'Bank of Ceylon',
    'People\'s Bank',
    'Sampath Bank',
    'HNB',
    'Nations Trust Bank',
    'NDB Bank',
    'DFCC Bank',
    'Seylan Bank',
  ];

  @override
  void dispose() {
    accountHolderController.dispose();
    accountNumberController.dispose();
    branchController.dispose();

    super.dispose();
  }

  Future<void> _saveBankAccount() async {
    final String accountHolder =
        accountHolderController.text.trim();

    final String accountNumber =
        accountNumberController.text.trim();

    final String branch =
        branchController.text.trim();

    if (selectedBank == null ||
        accountHolder.isEmpty ||
        accountNumber.isEmpty ||
        branch.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please complete all bank account details.',
          ),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    if (accountNumber.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter a valid account number.',
          ),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      await _withdrawalService.addBankAccount(
        bankName: selectedBank!,
        accountHolderName: accountHolder,
        accountNumber: accountNumber,
        branch: branch,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Bank account added successfully.',
          ),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to add bank account: $error',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
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
            child:
                SingleChildScrollView(
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
                  // Header
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
                        icon:
                            const Icon(
                          Icons
                              .arrow_back_ios_new,
                          size: 22,
                        ),
                      ),

                      const SizedBox(
                        width: 14,
                      ),

                      const Text(
                        'Add Bank Account',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight:
                              FontWeight.w800,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 30,
                  ),

                  const Text(
                    'Bank',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  DropdownButtonFormField<String>(
                    initialValue: selectedBank,
                    hint: const Text(
                      'Select bank',
                    ),
                    items: banks.map(
                      (bank) {
                        return DropdownMenuItem<
                            String>(
                          value: bank,
                          child: Text(
                            bank,
                          ),
                        );
                      },
                    ).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedBank =
                            value;
                      });
                    },
                    decoration:
                        _inputDecoration(),
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  const Text(
                    'Account Holder Name',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  TextField(
                    controller:
                        accountHolderController,
                    decoration:
                        _inputDecoration(
                      hint:
                          'Enter account holder name',
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  const Text(
                    'Account Number',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  TextField(
                    controller:
                        accountNumberController,
                    keyboardType:
                        TextInputType.number,
                    decoration:
                        _inputDecoration(
                      hint:
                          'Enter account number',
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  const Text(
                    'Branch',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  TextField(
                    controller:
                        branchController,
                    decoration:
                        _inputDecoration(
                      hint:
                          'Enter branch name',
                    ),
                  ),

                  const SizedBox(
                    height: 32,
                  ),

                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child:
                        ElevatedButton(
                      onPressed:
                          isSaving
                              ? null
                              : _saveBankAccount,
                      style:
                          ElevatedButton
                              .styleFrom(
                        backgroundColor:
                            primaryRed,
                        foregroundColor:
                            Colors.white,
                        elevation: 0,
                        disabledBackgroundColor:
                            primaryRed
                                .withValues(
                          alpha: 0.6,
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
                      child: isSaving
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
                              'Save Bank Account',
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
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    String? hint,
  }) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding:
          const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(12),
        borderSide:
            const BorderSide(
          color: Color(0xFFDDDDDD),
        ),
      ),
      enabledBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(12),
        borderSide:
            const BorderSide(
          color: Color(0xFFDDDDDD),
        ),
      ),
      focusedBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(12),
        borderSide:
            const BorderSide(
          color: primaryRed,
          width: 1.5,
        ),
      ),
    );
  }
}