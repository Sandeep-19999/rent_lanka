import 'package:flutter/material.dart';

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

  String _searchQuery = '';

  final List<Map<String, dynamic>> _faqItems = [
    {
      'question': 'How do I rent sports equipment?',
      'answer': 'Browse available sports equipment, open the item details, choose your rental dates and continue with the booking process.',
      'icon': Icons.sports_basketball_outlined,
      'iconColor': const Color(0xFF1687D9),
      'background': const Color(0xFFE7F5FF),
    },
    {
      'question': 'What are the payment methods?',
      'answer': 'Available payment methods are handled by the Booking and Payment module of Rent Lanka.',
      'icon': Icons.credit_card_outlined,
      'iconColor': const Color(0xFF16B95B),
      'background': const Color(0xFFE4F9EC),
    },
    {
      'question': 'How to cancel or change a booking?',
      'answer': 'Open your booking details and use the available edit or cancellation options when the booking status allows it.',
      'icon': Icons.calendar_month_outlined,
      'iconColor': const Color(0xFFFF6A00),
      'background': const Color(0xFFFFEEDB),
    },
  ];

  List<Map<String, dynamic>> get _filteredFaqItems {
    if (_searchQuery.trim().isEmpty) {
      return _faqItems;
    }

    final String query = _searchQuery.toLowerCase().trim();

    return _faqItems.where((item) {
      final String question = item['question'].toString().toLowerCase();

      final String answer = item['answer'].toString().toLowerCase();

      return question.contains(query) || answer.contains(query);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = _filteredFaqItems;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 22, 20, 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),

                        const SizedBox(height: 28),

                        _buildSearchBar(),

                        const SizedBox(height: 26),

                        const Text(
                          'Frequently Asked Questions',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: darkText,
                          ),
                        ),

                        const SizedBox(height: 20),

                        if (filteredItems.isEmpty)
                          _buildNoResults()
                        else
                          ...filteredItems.map(
                            (item) => _buildFaqItem(
                              question: item['question'] as String,
                              answer: item['answer'] as String,
                              icon: item['icon'] as IconData,
                              iconColor: item['iconColor'] as Color,
                              background: item['background'] as Color,
                            ),
                          ),

                        const SizedBox(height: 22),

                        const Text(
                          'Get in Touch',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: darkText,
                          ),
                        ),

                        const SizedBox(height: 20),

                        _buildReportProblemTile(),
                      ],
                    ),
                  ),
                ),

                _buildBottomNavigation(),
              ],
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

        const SizedBox(width: 32),

        const Text(
          'Help & support',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: darkText,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,

      onChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
      },

      decoration: InputDecoration(
        hintText: 'Search how we can help...',
        hintStyle: const TextStyle(color: Color(0xFF999999), fontSize: 14),

        prefixIcon: const Icon(Icons.search, color: Color(0xFF929292)),

        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                onPressed: () {
                  _searchController.clear();

                  setState(() {
                    _searchQuery = '';
                  });
                },
                icon: const Icon(Icons.close, color: Color(0xFF929292)),
              )
            : null,

        filled: true,
        fillColor: const Color(0xFFF3F5FA),

        contentPadding: const EdgeInsets.symmetric(vertical: 16),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildNoResults() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: const Column(
        children: [
          Icon(Icons.search_off_rounded, size: 45, color: Color(0xFFB0B0B0)),

          SizedBox(height: 12),

          Text(
            'No results found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: darkText,
            ),
          ),

          SizedBox(height: 5),

          Text(
            'Try another search keyword.',
            style: TextStyle(fontSize: 13, color: greyText),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem({
    required String question,
    required String answer,
    required IconData icon,
    required Color iconColor,
    required Color background,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: InkWell(
        onTap: () {
          _showAnswer(question, answer);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 23),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Text(
                  question,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: darkText,
                  ),
                ),
              ),

              const Icon(
                Icons.chevron_right,
                color: Color(0xFFC3C3C3),
                size: 26,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportProblemTile() {
    return InkWell(
      onTap: _showReportDialog,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFFFEDF1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.report_gmailerrorred_outlined,
                color: primaryRed,
                size: 26,
              ),
            ),

            const SizedBox(width: 14),

            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Report a problem',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: darkText,
                    ),
                  ),

                  SizedBox(height: 3),

                  Text(
                    "Let us know if something isn't working",
                    style: TextStyle(fontSize: 12, color: greyText),
                  ),
                ],
              ),
            ),

            const Icon(Icons.chevron_right, size: 28, color: Color(0xFFC5C5C5)),
          ],
        ),
      ),
    );
  }

  Future<void> _showAnswer(String question, String answer) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(question),
          content: Text(answer),
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

  Future<void> _showReportDialog() async {
    final TextEditingController problemController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Report a problem'),

          content: TextField(
            controller: problemController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Describe the problem...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),

            ElevatedButton(
              onPressed: () {
                final String text = problemController.text.trim();

                if (text.isEmpty) {
                  return;
                }

                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Problem report submitted.'),
                    backgroundColor: Color(0xFF2E9B50),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryRed,
                foregroundColor: Colors.white,
              ),
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );

    problemController.dispose();
  }

  Widget _buildBottomNavigation() {
    return Container(
      height: 78,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE8E8E8))),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _HelpNavigationItem(icon: Icons.home_outlined, label: 'Home'),
          _HelpNavigationItem(icon: Icons.search, label: 'Search'),
          _HelpNavigationItem(
            icon: Icons.file_download_outlined,
            label: 'Bookings',
          ),
          _HelpNavigationItem(
            icon: Icons.chat_bubble_outline,
            label: 'Messages',
          ),
          _HelpNavigationItem(
            icon: Icons.person_outline,
            label: 'Profile',
            active: true,
          ),
        ],
      ),
    );
  }
}

class _HelpNavigationItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;

  const _HelpNavigationItem({
    required this.icon,
    required this.label,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    const Color primaryRed = Color(0xFFED1235);

    return SizedBox(
      width: 65,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 24,
            color: active ? primaryRed : const Color(0xFF929292),
          ),

          const SizedBox(height: 4),

          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: active ? FontWeight.w600 : FontWeight.w400,
              color: active ? primaryRed : const Color(0xFF929292),
            ),
          ),
        ],
      ),
    );
  }
}
