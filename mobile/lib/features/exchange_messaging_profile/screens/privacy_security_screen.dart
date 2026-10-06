import 'package:flutter/material.dart';

class PrivacySecurityScreen extends StatefulWidget {
  const PrivacySecurityScreen({super.key});

  @override
  State<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends State<PrivacySecurityScreen> {
  static const Color primaryRed = Color(0xFFED1235);
  static const Color darkText = Color(0xFF242424);
  static const Color greyText = Color(0xFF929292);

  bool _twoStepVerification = false;

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
                    'SECURITY',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: greyText,
                    ),
                  ),

                  const SizedBox(height: 18),

                  _buildNavigationTile(
                    icon: Icons.lock_outline,
                    iconColor: const Color(0xFF1687D9),
                    background: const Color(0xFFE8F5FF),
                    title: 'Change password',
                    subtitle: 'Update your account password',
                    onTap: _showChangePasswordDialog,
                  ),

                  const SizedBox(height: 22),

                  _buildSwitchTile(
                    icon: Icons.verified_user_outlined,
                    iconColor: const Color(0xFF16B95B),
                    background: const Color(0xFFE8FAEF),
                    title: 'Two-step verification',
                    subtitle: 'Add extra security to your account',
                    value: _twoStepVerification,
                    onChanged: (value) {
                      setState(() {
                        _twoStepVerification = value;
                      });
                    },
                  ),

                  const SizedBox(height: 36),

                  const Text(
                    'VERIFICATION',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: greyText,
                    ),
                  ),

                  const SizedBox(height: 18),

                  _buildNavigationTile(
                    icon: Icons.badge_outlined,
                    iconColor: const Color(0xFF9B3CFF),
                    background: const Color(0xFFF1E5FF),
                    title: 'Identity verification',
                    subtitle: 'Verified account',
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5F8EB),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Verified',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF16A34A),
                        ),
                      ),
                    ),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Your account is verified.'),
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
        const SizedBox(width: 28),
        const Text(
          'Privacy & security',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: darkText,
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationTile({
    required IconData icon,
    required Color iconColor,
    required Color background,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Row(
        children: [
          _iconBox(icon, iconColor, background),
          const SizedBox(width: 14),
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
          trailing ?? const Icon(Icons.chevron_right, color: Color(0xFFC5C5C5)),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required Color iconColor,
    required Color background,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        _iconBox(icon, iconColor, background),
        const SizedBox(width: 14),
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
        Switch(
          value: value,
          activeTrackColor: primaryRed,
          activeThumbColor: Colors.white,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _iconBox(IconData icon, Color iconColor, Color background) {
    return Container(
      width: 50,
      height: 50,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: iconColor),
    );
  }

  Future<void> _showChangePasswordDialog() async {
    final currentController = TextEditingController();

    final newController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Change password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Current password',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: newController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'New password'),
              ),
            ],
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
                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Password update will connect to Firebase Authentication during integration.',
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryRed,
                foregroundColor: Colors.white,
              ),
              child: const Text('Update'),
            ),
          ],
        );
      },
    );

    currentController.dispose();
    newController.dispose();
  }
}
