import 'package:flutter/material.dart';

class AccessibilityScreen extends StatefulWidget {
  const AccessibilityScreen({super.key});

  @override
  State<AccessibilityScreen> createState() => _AccessibilityScreenState();
}

class _AccessibilityScreenState extends State<AccessibilityScreen> {
  static const Color primaryRed = Color(0xFFED1235);

  static const Color darkText = Color(0xFF242424);

  static const Color greyText = Color(0xFF929292);

  double _textSize = 1;

  bool _highContrast = false;
  bool _reduceMotion = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _highContrast ? Colors.black : Colors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),

                  const SizedBox(height: 38),

                  Text(
                    'DISPLAY',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _secondaryText,
                    ),
                  ),

                  const SizedBox(height: 18),

                  _buildTextSizeControl(),

                  const SizedBox(height: 30),

                  _buildSwitchOption(
                    icon: Icons.contrast,
                    title: 'High contrast',
                    subtitle: 'Increase visual contrast',
                    value: _highContrast,
                    onChanged: (value) {
                      setState(() {
                        _highContrast = value;
                      });
                    },
                  ),

                  const SizedBox(height: 24),

                  _buildSwitchOption(
                    icon: Icons.animation,
                    title: 'Reduce animations',
                    subtitle: 'Reduce screen motion effects',
                    value: _reduceMotion,
                    onChanged: (value) {
                      setState(() {
                        _reduceMotion = value;
                      });
                    },
                  ),

                  const SizedBox(height: 36),

                  Text(
                    'Preview text',
                    style: TextStyle(
                      fontSize: 17 * _textSize,
                      fontWeight: FontWeight.w700,
                      color: _primaryText,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Rent Lanka makes sports equipment rental easier and more accessible.',
                    style: TextStyle(
                      fontSize: 14 * _textSize,
                      height: 1.4,
                      color: _secondaryText,
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

  Color get _primaryText => _highContrast ? Colors.white : darkText;

  Color get _secondaryText =>
      _highContrast ? const Color(0xFFE0E0E0) : greyText;

  Widget _buildHeader() {
    return Row(
      children: [
        InkWell(
          onTap: () {
            Navigator.maybePop(context);
          },
          borderRadius: BorderRadius.circular(50),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Icon(
              Icons.arrow_back_ios_new,
              size: 22,
              color: _primaryText,
            ),
          ),
        ),
        const SizedBox(width: 28),
        Text(
          'Accessibility',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: _primaryText,
          ),
        ),
      ],
    );
  }

  Widget _buildTextSizeControl() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Text size',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: _primaryText,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          'Adjust the size of text',
          style: TextStyle(fontSize: 13, color: _secondaryText),
        ),

        const SizedBox(height: 16),

        Row(
          children: [
            Text('A', style: TextStyle(fontSize: 13, color: _primaryText)),

            Expanded(
              child: Slider(
                value: _textSize,
                min: 0.8,
                max: 1.4,
                divisions: 3,
                activeColor: primaryRed,
                onChanged: (value) {
                  setState(() {
                    _textSize = value;
                  });
                },
              ),
            ),

            Text(
              'A',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: _primaryText,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSwitchOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _highContrast
                ? const Color(0xFF242424)
                : const Color(0xFFF1E5FF),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            color: _highContrast ? Colors.white : const Color(0xFF9B3CFF),
          ),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _primaryText,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                subtitle,
                style: TextStyle(fontSize: 13, color: _secondaryText),
              ),
            ],
          ),
        ),

        Switch(
          value: value,
          activeTrackColor: primaryRed,
          activeThumbColor: Colors.white,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
