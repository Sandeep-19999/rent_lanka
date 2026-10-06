import 'package:flutter/material.dart';

import 'accessibility_screen.dart';
import 'payment_methods_screen.dart';
import 'privacy_security_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const Color primaryRed = Color(0xFFED1235);

  static const Color darkText = Color(0xFF242424);

  static const Color greyText = Color(0xFF929292);

  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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

                  const SizedBox(height: 36),

                  const Text(
                    'PREFERENCES',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF8A8A8A),
                    ),
                  ),

                  const SizedBox(height: 18),

                  _buildNotificationTile(),

                  const SizedBox(height: 34),

                  const Text(
                    'ACCOUNT',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF8A8A8A),
                    ),
                  ),

                  const SizedBox(height: 16),

                  _buildSettingsTile(
                    icon: Icons.shield_outlined,
                    iconColor: const Color(0xFF00B96B),
                    iconBackground: const Color(0xFFE5F9EF),
                    title: 'Privacy & security',
                    subtitle: 'Password, verification',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PrivacySecurityScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  _buildSettingsTile(
                    icon: Icons.credit_card_outlined,
                    iconColor: const Color(0xFF1565FF),
                    iconBackground: const Color(0xFFE7F0FF),
                    title: 'Payment methods',
                    subtitle: 'Manage saved cards',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PaymentMethodsScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  _buildSettingsTile(
                    icon: Icons.visibility_outlined,
                    iconColor: const Color(0xFF9B3CFF),
                    iconBackground: const Color(0xFFF1E5FF),
                    title: 'Accessibility',
                    subtitle: 'Display & text size',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AccessibilityScreen(),
                        ),
                      );
                    },
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
        const SizedBox(width: 34),
        const Text(
          'Settings',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: darkText,
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationTile() {
    return Row(
      children: [
        _buildIconBox(
          icon: Icons.notifications_none,
          iconColor: const Color(0xFFFF8A00),
          backgroundColor: const Color(0xFFFFF0DF),
        ),

        const SizedBox(width: 15),

        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Notifications',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: darkText,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Alerts & push messages',
                style: TextStyle(fontSize: 13, color: greyText),
              ),
            ],
          ),
        ),

        Switch(
          value: _notificationsEnabled,
          activeThumbColor: Colors.white,
          activeTrackColor: primaryRed,
          inactiveThumbColor: Colors.white,
          inactiveTrackColor: const Color(0xFFD9D9D9),
          onChanged: (value) {
            setState(() {
              _notificationsEnabled = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required Color iconColor,
    required Color iconBackground,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Row(
        children: [
          _buildIconBox(
            icon: icon,
            iconColor: iconColor,
            backgroundColor: iconBackground,
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: darkText,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 13, color: greyText),
                ),
              ],
            ),
          ),

          const Icon(Icons.chevron_right, size: 28, color: Color(0xFFC8C8C8)),
        ],
      ),
    );
  }

  Widget _buildIconBox({
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
  }) {
    return Container(
      width: 50,
      height: 50,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, size: 25, color: iconColor),
    );
  }
}
