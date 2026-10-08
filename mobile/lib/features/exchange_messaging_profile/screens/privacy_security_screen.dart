import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../provider/screens/provider_dashboard.dart';
import '../../user_discovery/screens/auth/login_screen.dart';
import '../../user_discovery/screens/home/home_screen.dart';
import '../../user_discovery/screens/role/role_selection_screen.dart';
import '../../user_discovery/services/user_service.dart';

import '../widgets/change_password_dialog.dart';

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
      backgroundColor: const Color(0xFFF8F8FA),
      appBar: AppBar(
        title: const Text('Password & Security', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        backgroundColor: Colors.white, surfaceTintColor: Colors.white,
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(color: const Color(0xFFFFEEF1),
                      borderRadius: BorderRadius.circular(22)),
                    child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Icon(Icons.shield_outlined, color: primaryRed, size: 34),
                      SizedBox(height: 14),
                      Text('Your account, protected', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                      SizedBox(height: 8),
                      Text('Manage your password and account security in one place.',
                        style: TextStyle(color: Colors.black54, height: 1.5)),
                    ]),
                  ),
                  const SizedBox(height: 28),

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

  Widget _buildNavigationTile({
    required IconData icon,
    required Color iconColor,
    required Color background,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEBEBEF))),
      child: InkWell(
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
    final updated = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const ChangePasswordDialog(),
    );

    if (!mounted || updated != true) return;
    await _navigateAfterPasswordChange();
  }

  Future<void> _navigateAfterPasswordChange() async {
    Widget destination;
    try {
      if (FirebaseAuth.instance.currentUser == null) {
        destination = const LoginScreen();
      } else {
        final role = (await UserService().getCurrentUserRole() ?? '')
            .trim()
            .toLowerCase();
        destination = switch (role) {
          'provider' => const ProviderDashboard(),
          'player' => const HomeScreen(),
          '' => const RoleSelectionScreen(),
          _ => throw StateError('Unknown account role'),
        };
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Password updated, but your account role could not be loaded.',
          ),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: _navigateAfterPasswordChange,
          ),
        ),
      );
      return;
    }

    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => destination),
      (route) => false,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password updated successfully.')),
    );
  }
}
