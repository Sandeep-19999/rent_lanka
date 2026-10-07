import 'package:flutter/material.dart';

import '../services/settings_service.dart';
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
  static const Color greyText = Color(0xFF7D7D7D);
  static const Color borderColor = Color(0xFFE7E7E7);
  static const Color backgroundColor = Color(0xFFF8F8F8);

  final SettingsService _settingsService = SettingsService();

  bool _isUpdatingNotifications = false;

  Future<void> _changeNotificationPreference(bool value) async {
    if (_isUpdatingNotifications) return;

    setState(() {
      _isUpdatingNotifications = true;
    });

    try {
      await _settingsService.updateNotificationPreference(value);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            value
                ? 'Notifications enabled.'
                : 'Notifications disabled.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to update notification setting: $error',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingNotifications = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
          'Settings',
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                18,
                20,
                18,
                32,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildIntroCard(),

                  const SizedBox(height: 26),

                  _buildSectionTitle(
                    'Preferences',
                  ),

                  const SizedBox(height: 10),

                  _buildSettingsContainer(
                    children: [
                      StreamBuilder<bool>(
                        stream: _settingsService
                            .watchNotificationPreference(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                                  ConnectionState.waiting &&
                              !snapshot.hasData) {
                            return const SizedBox(
                              height: 72,
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: primaryRed,
                                  strokeWidth: 2,
                                ),
                              ),
                            );
                          }

                          final bool enabled =
                              snapshot.data ?? true;

                          return _buildNotificationTile(
                            enabled,
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  _buildSectionTitle(
                    'Account & Security',
                  ),

                  const SizedBox(height: 10),

                  _buildSettingsContainer(
                    children: [
                      _buildSettingsTile(
                        icon: Icons.shield_outlined,
                        iconColor: const Color(0xFF24945E),
                        iconBackground:
                            const Color(0xFFEAF8F1),
                        title: 'Privacy & Security',
                        subtitle:
                            'Password, account security and privacy',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const PrivacySecurityScreen(),
                            ),
                          );
                        },
                      ),

                      _divider(),

                      _buildSettingsTile(
                        icon: Icons.credit_card_outlined,
                        iconColor: const Color(0xFF3478C7),
                        iconBackground:
                            const Color(0xFFEDF4FF),
                        title: 'Payment Methods',
                        subtitle:
                            'Manage your saved payment methods',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const PaymentMethodsScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  _buildSectionTitle(
                    'App Preferences',
                  ),

                  const SizedBox(height: 10),

                  _buildSettingsContainer(
                    children: [
                      _buildSettingsTile(
                        icon: Icons.accessibility_new_rounded,
                        iconColor: const Color(0xFF8C52C7),
                        iconBackground:
                            const Color(0xFFF3EDFF),
                        title: 'Accessibility',
                        subtitle:
                            'Display, text size and accessibility',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const AccessibilityScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  _buildSectionTitle(
                    'About',
                  ),

                  const SizedBox(height: 10),

                  _buildSettingsContainer(
                    children: [
                      _buildStaticTile(
                        icon: Icons.info_outline_rounded,
                        title: 'App Version',
                        value: '1.0.0',
                      ),

                      _divider(),

                      _buildStaticTile(
                        icon: Icons.verified_user_outlined,
                        title: 'Platform',
                        value: 'Rent Lanka',
                      ),
                    ],
                  ),
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F3),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.settings_outlined,
              color: primaryRed,
              size: 25,
            ),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Manage your preferences',
                  style: TextStyle(
                    color: darkText,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Control your notifications, security and app preferences.',
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

  Widget _buildSectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: darkText,
        fontSize: 16,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget _buildSettingsContainer({
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildNotificationTile(bool enabled) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF4E5),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              color: Color(0xFFE28B1A),
              size: 23,
            ),
          ),

          const SizedBox(width: 13),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notifications',
                  style: TextStyle(
                    color: darkText,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Receive activity and message alerts',
                  style: TextStyle(
                    color: greyText,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          if (_isUpdatingNotifications)
            const SizedBox(
              width: 48,
              height: 48,
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: primaryRed,
                  ),
                ),
              ),
            )
          else
            Switch(
              value: enabled,
              activeColor: primaryRed,
              onChanged: _changeNotificationPreference,
            ),
        ],
      ),
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 23,
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: darkText,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: greyText,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFFB0B0B0),
                size: 25,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStaticTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: greyText,
              size: 21,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: darkText,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          Text(
            value,
            style: const TextStyle(
              color: greyText,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return const Padding(
      padding: EdgeInsets.only(
        left: 74,
      ),
      child: Divider(
        height: 1,
        color: borderColor,
      ),
    );
  }
}