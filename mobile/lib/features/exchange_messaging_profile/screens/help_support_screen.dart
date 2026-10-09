import 'package:flutter/material.dart';

import '../services/support_service.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  static const Color primaryRed = Color(0xFFED1235);
  static const Color darkText = Color(0xFF242424);
  static const Color greyText = Color(0xFF7D7D7D);
  static const Color borderColor = Color(0xFFE7E7E7);
  static const Color backgroundColor = Color(0xFFF8F8F8);

  final TextEditingController _searchController =
      TextEditingController();

  final SupportService _supportService =
      SupportService();

  String _searchQuery = '';

  final List<Map<String, String>> _faqItems = [
    {
      'question': 'How do I rent sports equipment?',
      'answer':
          'Browse available equipment, open the equipment details, choose your rental dates and continue with the booking and payment process.',
    },
    {
      'question': 'How do I send an exchange request?',
      'answer':
          'Open an equipment item that supports exchange, select your equipment to offer, add a message and send the exchange request.',
    },
    {
      'question': 'How can I contact a provider?',
      'answer':
          'You can contact the provider using the Messages feature. Open your conversation and send a message directly through Rent Lanka.',
    },
    {
      'question': 'How can I cancel or change a booking?',
      'answer':
          'Open My Bookings, choose the relevant booking and use the available edit or cancellation option depending on the booking status.',
    },
    {
      'question': 'What payment methods are available?',
      'answer':
          'Available payment methods are displayed during the booking and payment process.',
    },
    {
      'question': 'When can I leave a review?',
      'answer':
          'You can rate and review equipment after the rental has been completed.',
    },
    {
      'question': 'How do I update my profile?',
      'answer':
          'Open Profile, select Edit Profile, update your personal details and tap Save Changes.',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, String>> get _filteredFaqItems {
    final String query =
        _searchQuery.trim().toLowerCase();

    if (query.isEmpty) {
      return _faqItems;
    }

    return _faqItems.where((item) {
      final String question =
          item['question']?.toLowerCase() ?? '';

      final String answer =
          item['answer']?.toLowerCase() ?? '';

      return question.contains(query) ||
          answer.contains(query);
    }).toList();
  }

  Future<void> _showReportProblemDialog() async {
    final TextEditingController
        problemController =
        TextEditingController();

    String selectedCategory =
        'General issue';

    bool isSubmitting = false;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
            dialogContext,
            setDialogState,
          ) {
            Future<void> submitProblem() async {
              final String message =
                  problemController.text.trim();

              if (message.isEmpty) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Please describe your problem.',
                    ),
                  ),
                );

                return;
              }

              if (message.length < 10) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Please provide a little more detail.',
                    ),
                  ),
                );

                return;
              }

              setDialogState(() {
                isSubmitting = true;
              });

              try {
                final String reportId =
                    await _supportService
                        .submitReport(
                  category: selectedCategory,
                  message: message,
                );

                if (!mounted) return;

                Navigator.pop(
                  dialogContext,
                );

                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  SnackBar(
                    content: Text(
                      'Problem reported successfully. Reference: $reportId',
                    ),
                    backgroundColor:
                        const Color(
                      0xFF2E9B50,
                    ),
                  ),
                );
              } catch (error) {
                if (!mounted) return;

                setDialogState(() {
                  isSubmitting = false;
                });

                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  SnackBar(
                    content: Text(
                      'Unable to submit report: $error',
                    ),
                  ),
                );
              }
            }

            return AlertDialog(
              backgroundColor:
                  Colors.white,
              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(
                  20,
                ),
              ),
              titlePadding:
                  const EdgeInsets.fromLTRB(
                20,
                20,
                20,
                4,
              ),
              contentPadding:
                  const EdgeInsets.fromLTRB(
                20,
                12,
                20,
                0,
              ),
              actionsPadding:
                  const EdgeInsets.fromLTRB(
                14,
                8,
                14,
                14,
              ),
              title: const Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor:
                        Color(0xFFFFEEF1),
                    child: Icon(
                      Icons
                          .report_problem_outlined,
                      color: primaryRed,
                      size: 21,
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Report a Problem',
                    style: TextStyle(
                      color: darkText,
                      fontSize: 19,
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),
                ],
              ),
              content:
                  SingleChildScrollView(
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min,
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    const Text(
                      'Select category',
                      style: TextStyle(
                        color: darkText,
                        fontSize: 13,
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    DropdownButtonFormField<
                        String>(
                      initialValue:
                          selectedCategory,
                      isExpanded: true,
                      decoration:
                          InputDecoration(
                        filled: true,
                        fillColor:
                            const Color(
                          0xFFF8F8F8,
                        ),
                        contentPadding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 14,
                          vertical: 13,
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
                                borderColor,
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
                          ),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value:
                              'General issue',
                          child: Text(
                            'General issue',
                          ),
                        ),
                        DropdownMenuItem(
                          value:
                              'Booking issue',
                          child: Text(
                            'Booking issue',
                          ),
                        ),
                        DropdownMenuItem(
                          value:
                              'Payment issue',
                          child: Text(
                            'Payment issue',
                          ),
                        ),
                        DropdownMenuItem(
                          value:
                              'Exchange issue',
                          child: Text(
                            'Exchange issue',
                          ),
                        ),
                        DropdownMenuItem(
                          value:
                              'Messaging issue',
                          child: Text(
                            'Messaging issue',
                          ),
                        ),
                        DropdownMenuItem(
                          value:
                              'Account issue',
                          child: Text(
                            'Account issue',
                          ),
                        ),
                      ],
                      onChanged:
                          isSubmitting
                              ? null
                              : (value) {
                                  if (value ==
                                      null) {
                                    return;
                                  }

                                  selectedCategory =
                                      value;
                                },
                    ),

                    const SizedBox(
                      height: 18,
                    ),

                    const Text(
                      'Describe your problem',
                      style: TextStyle(
                        color: darkText,
                        fontSize: 13,
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    TextField(
                      controller:
                          problemController,
                      enabled:
                          !isSubmitting,
                      minLines: 4,
                      maxLines: 6,
                      maxLength: 500,
                      decoration:
                          InputDecoration(
                        hintText:
                            'Tell us what happened...',
                        hintStyle:
                            const TextStyle(
                          color:
                              Color(
                            0xFFAAAAAA,
                          ),
                          fontSize: 13,
                        ),
                        filled: true,
                        fillColor:
                            const Color(
                          0xFFF8F8F8,
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
                                borderColor,
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
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed:
                      isSubmitting
                          ? null
                          : () {
                              Navigator.pop(
                                dialogContext,
                              );
                            },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: greyText,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed:
                      isSubmitting
                          ? null
                          : submitProblem,
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        primaryRed,
                    foregroundColor:
                        Colors.white,
                    elevation: 0,
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius
                              .circular(
                        11,
                      ),
                    ),
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                            color:
                                Colors.white,
                          ),
                        )
                      : const Text(
                          'Submit Report',
                          style: TextStyle(
                            fontWeight:
                                FontWeight
                                    .w700,
                          ),
                        ),
                ),
              ],
            );
          },
        );
      },
    );

    problemController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredFaqs =
        _filteredFaqItems;

    return Scaffold(
      backgroundColor:
          backgroundColor,
      appBar: AppBar(
        backgroundColor:
            Colors.white,
        surfaceTintColor:
            Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () =>
              Navigator.maybePop(
            context,
          ),
          icon: const Icon(
            Icons
                .arrow_back_ios_new_rounded,
            size: 20,
            color: darkText,
          ),
        ),
        titleSpacing: 0,
        title: const Text(
          'Help & Support',
          style: TextStyle(
            color: darkText,
            fontSize: 20,
            fontWeight:
                FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Align(
          alignment:
              Alignment.topCenter,
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(
              maxWidth: 500,
            ),
            child:
                SingleChildScrollView(
              padding:
                  const EdgeInsets
                      .fromLTRB(
                18,
                20,
                18,
                32,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  _buildIntroCard(),

                  const SizedBox(
                    height: 22,
                  ),

                  _buildSearchBox(),

                  const SizedBox(
                    height: 26,
                  ),

                  const Text(
                    'Frequently Asked Questions',
                    style: TextStyle(
                      color: darkText,
                      fontSize: 17,
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),

                  const SizedBox(
                    height: 6,
                  ),

                  const Text(
                    'Find answers to common questions about Rent Lanka.',
                    style: TextStyle(
                      color: greyText,
                      fontSize: 12,
                    ),
                  ),

                  const SizedBox(
                    height: 14,
                  ),

                  if (filteredFaqs
                      .isEmpty)
                    _buildNoResults()
                  else
                    ...filteredFaqs
                        .map(
                      (item) =>
                          _buildFaqTile(
                        item,
                      ),
                    ),

                  const SizedBox(
                    height: 26,
                  ),

                  _buildSupportCard(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIntroCard() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color:
            const Color(0xFFFFF1F3),
        borderRadius:
            BorderRadius.circular(18),
      ),
      child: const Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor:
                Colors.white,
            child: Icon(
              Icons
                  .support_agent_rounded,
              color: primaryRed,
              size: 27,
            ),
          ),

          SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'How can we help?',
                  style: TextStyle(
                    color: darkText,
                    fontSize: 18,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Search our help topics or report a problem to the Rent Lanka support team.',
                  style: TextStyle(
                    color: greyText,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBox() {
    return TextField(
      controller:
          _searchController,
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
      },
      decoration:
          InputDecoration(
        hintText:
            'Search help topics',
        hintStyle:
            const TextStyle(
          color:
              Color(0xFF999999),
          fontSize: 14,
        ),
        prefixIcon:
            const Icon(
          Icons.search_rounded,
          color:
              Color(0xFF888888),
        ),
        suffixIcon:
            _searchQuery.isEmpty
                ? null
                : IconButton(
                    onPressed: () {
                      _searchController
                          .clear();

                      setState(() {
                        _searchQuery =
                            '';
                      });
                    },
                    icon:
                        const Icon(
                      Icons.close_rounded,
                      color:
                          Color(
                        0xFF888888,
                      ),
                    ),
                  ),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets
                .symmetric(
          horizontal: 15,
          vertical: 15,
        ),
        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            14,
          ),
          borderSide:
              const BorderSide(
            color: borderColor,
          ),
        ),
        focusedBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            14,
          ),
          borderSide:
              const BorderSide(
            color: primaryRed,
            width: 1.3,
          ),
        ),
      ),
    );
  }

  Widget _buildFaqTile(
    Map<String, String> item,
  ) {
    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(
          16,
        ),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Theme(
        data:
            Theme.of(context).copyWith(
          dividerColor:
              Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding:
              const EdgeInsets
                  .symmetric(
            horizontal: 15,
            vertical: 3,
          ),
          childrenPadding:
              const EdgeInsets
                  .fromLTRB(
            16,
            0,
            16,
            16,
          ),
          iconColor: primaryRed,
          collapsedIconColor:
              const Color(
            0xFF999999,
          ),
          leading: Container(
            width: 42,
            height: 42,
            decoration:
                BoxDecoration(
              color:
                  const Color(
                0xFFFFEEF1,
              ),
              borderRadius:
                  BorderRadius
                      .circular(
                12,
              ),
            ),
            child: const Icon(
              Icons
                  .help_outline_rounded,
              color: primaryRed,
              size: 21,
            ),
          ),
          title: Text(
            item['question'] ??
                '',
            style:
                const TextStyle(
              color: darkText,
              fontSize: 14,
              fontWeight:
                  FontWeight.w700,
            ),
          ),
          children: [
            Align(
              alignment:
                  Alignment.centerLeft,
              child: Text(
                item['answer'] ??
                    '',
                style:
                    const TextStyle(
                  color: greyText,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportCard() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(
          18,
        ),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration:
                const BoxDecoration(
              color:
                  Color(0xFFFFEEF1),
              shape:
                  BoxShape.circle,
            ),
            child: const Icon(
              Icons
                  .support_agent_rounded,
              color: primaryRed,
              size: 29,
            ),
          ),

          const SizedBox(
            height: 12,
          ),

          const Text(
            'Still need help?',
            style: TextStyle(
              color: darkText,
              fontSize: 17,
              fontWeight:
                  FontWeight.w800,
            ),
          ),

          const SizedBox(
            height: 6,
          ),

          const Text(
            'Tell us what went wrong and our support team can review your report.',
            textAlign:
                TextAlign.center,
            style: TextStyle(
              color: greyText,
              fontSize: 12,
              height: 1.5,
            ),
          ),

          const SizedBox(
            height: 18,
          ),

          SizedBox(
            width:
                double.infinity,
            height: 52,
            child:
                ElevatedButton.icon(
              onPressed:
                  _showReportProblemDialog,
              style:
                  ElevatedButton
                      .styleFrom(
                backgroundColor:
                    primaryRed,
                foregroundColor:
                    Colors.white,
                elevation: 0,
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius
                          .circular(
                    14,
                  ),
                ),
              ),
              icon: const Icon(
                Icons
                    .report_problem_outlined,
                size: 20,
              ),
              label: const Text(
                'Report a Problem',
                style:
                    TextStyle(
                  fontSize: 14,
                  fontWeight:
                      FontWeight
                          .w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.symmetric(
        vertical: 42,
        horizontal: 20,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(
          16,
        ),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            color:
                Color(0xFFAAAAAA),
            size: 48,
          ),

          SizedBox(height: 12),

          Text(
            'No matching help topics',
            style: TextStyle(
              color: darkText,
              fontSize: 16,
              fontWeight:
                  FontWeight.w800,
            ),
          ),

          SizedBox(height: 5),

          Text(
            'Try another search term or report your problem below.',
            textAlign:
                TextAlign.center,
            style: TextStyle(
              color: greyText,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}