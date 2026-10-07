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

  static const Color greyText = Color(0xFF929292);

  final TextEditingController _searchController = TextEditingController();

  final SupportService _supportService = SupportService();

  String _searchQuery = '';

  final List<Map<String, String>> _faqItems = [
    {
      'question': 'How do I rent sports equipment?',
      'answer': 'Browse available equipment, select the item you need, choose your rental dates, and continue with the booking process.',
    },
    {
      'question': 'What are the payment methods?',
      'answer': 'Available payment methods are shown during the booking and payment process.',
    },
    {
      'question': 'How to cancel or change a booking?',
      'answer': 'Open your bookings, select the relevant booking, and use the available change or cancellation option based on its current status.',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, String>> get _filteredFaqItems {
    final String query = _searchQuery.trim().toLowerCase();

    if (query.isEmpty) {
      return _faqItems;
    }

    return _faqItems.where((item) {
      final String question = item['question']?.toLowerCase() ?? '';

      final String answer = item['answer']?.toLowerCase() ?? '';

      return question.contains(query) || answer.contains(query);
    }).toList();
  }

  Future<void> _showFaqAnswer(Map<String, String> item) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(item['question'] ?? ''),
          content: Text(item['answer'] ?? ''),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showReportProblemDialog() async {
    final TextEditingController problemController = TextEditingController();

    String selectedCategory = 'General issue';

    bool isSubmitting = false;

    await showDialog<void>(
      context: context,
      barrierDismissible: !isSubmitting,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> submitProblem() async {
              final String message = problemController.text.trim();

              if (message.isEmpty) {
                ScaffoldMessenger.of(this.context).showSnackBar(
                  const SnackBar(
                    content: Text('Please describe your problem.'),
                  ),
                );

                return;
              }

              setDialogState(() {
                isSubmitting = true;
              });

              try {
                final String reportId = await _supportService.submitReport(
                  category: selectedCategory,
                  message: message,
                );

                if (!mounted) {
                  return;
                }

                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(this.context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Problem reported successfully. Reference: $reportId',
                    ),
                    backgroundColor: const Color(0xFF2E9B50),
                  ),
                );
              } catch (error) {
                if (!mounted) {
                  return;
                }

                setDialogState(() {
                  isSubmitting = false;
                });

                ScaffoldMessenger.of(this.context).showSnackBar(
                  SnackBar(content: Text('Unable to submit report: $error')),
                );
              }
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              title: const Text(
                'Report a problem',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Category',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: darkText,
                      ),
                    ),

                    const SizedBox(height: 8),

                    DropdownButtonFormField<String>(
                      initialValue: selectedCategory,
                      isExpanded: true,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 13,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: primaryRed),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'General issue',
                          child: Text('General issue'),
                        ),
                        DropdownMenuItem(
                          value: 'Booking issue',
                          child: Text('Booking issue'),
                        ),
                        DropdownMenuItem(
                          value: 'Payment issue',
                          child: Text('Payment issue'),
                        ),
                        DropdownMenuItem(
                          value: 'Exchange issue',
                          child: Text('Exchange issue'),
                        ),
                        DropdownMenuItem(
                          value: 'Messaging issue',
                          child: Text('Messaging issue'),
                        ),
                        DropdownMenuItem(
                          value: 'Account issue',
                          child: Text('Account issue'),
                        ),
                      ],
                      onChanged: isSubmitting
                          ? null
                          : (value) {
                              if (value == null) {
                                return;
                              }

                              selectedCategory = value;
                            },
                    ),

                    const SizedBox(height: 18),

                    const Text(
                      'Describe your problem',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: darkText,
                      ),
                    ),

                    const SizedBox(height: 8),

                    TextField(
                      controller: problemController,
                      enabled: !isSubmitting,
                      maxLines: 5,
                      maxLength: 500,
                      decoration: InputDecoration(
                        hintText: 'Tell us what happened...',
                        hintStyle: const TextStyle(color: greyText),
                        filled: true,
                        fillColor: const Color(0xFFF8F9FB),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFE1E1E1),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFE1E1E1),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: primaryRed),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting
                      ? null
                      : () {
                          Navigator.pop(dialogContext);
                        },
                  child: const Text('Cancel'),
                ),

                ElevatedButton(
                  onPressed: isSubmitting ? null : submitProblem,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryRed,
                    foregroundColor: Colors.white,
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Submit'),
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
    final filteredFaqs = _filteredFaqItems;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),

                  const SizedBox(height: 30),

                  _buildSearchBox(),

                  const SizedBox(height: 32),

                  const Text(
                    'Frequently asked questions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: darkText,
                    ),
                  ),

                  const SizedBox(height: 14),

                  if (filteredFaqs.isEmpty)
                    _buildNoResults()
                  else
                    ...filteredFaqs.map((item) => _buildFaqTile(item)),

                  const SizedBox(height: 35),

                  const Divider(color: Color(0xFFE7E7E7)),

                  const SizedBox(height: 26),

                  const Text(
                    'Still need help?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: darkText,
                    ),
                  ),

                  const SizedBox(height: 7),

                  const Text(
                    'Tell us about the problem and our support team can review it.',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: greyText,
                    ),
                  ),

                  const SizedBox(height: 18),

                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: _showReportProblemDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryRed,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      icon: const Icon(Icons.report_problem_outlined),
                      label: const Text(
                        'Report a problem',
                        style: TextStyle(
                          fontSize: 15,
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

        const SizedBox(width: 28),

        const Text(
          'Help & Support',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: darkText,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBox() {
    return TextField(
      controller: _searchController,
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
      },
      decoration: InputDecoration(
        hintText: 'Search help topics',
        hintStyle: const TextStyle(color: Color(0xFF999999)),
        prefixIcon: const Icon(Icons.search, color: Color(0xFF888888)),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                onPressed: () {
                  _searchController.clear();

                  setState(() {
                    _searchQuery = '';
                  });
                },
                icon: const Icon(Icons.close),
              )
            : null,
        filled: true,
        fillColor: const Color(0xFFF6F7F9),
        contentPadding: const EdgeInsets.symmetric(vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildFaqTile(Map<String, String> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE6E6E6)),
      ),
      child: ListTile(
        onTap: () {
          _showFaqAnswer(item);
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: Text(
          item['question'] ?? '',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: darkText,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: Color(0xFFB5B5B5)),
      ),
    );
  }

  Widget _buildNoResults() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 30),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.search_off, size: 46, color: Color(0xFFB5B5B5)),

            SizedBox(height: 10),

            Text(
              'No matching help topics',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: darkText,
              ),
            ),

            SizedBox(height: 4),

            Text(
              'Try another search term.',
              style: TextStyle(fontSize: 13, color: greyText),
            ),
          ],
        ),
      ),
    );
  }
}
