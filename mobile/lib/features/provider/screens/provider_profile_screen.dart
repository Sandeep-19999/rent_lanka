import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../exchange_messaging_profile/screens/edit_profile_screen.dart';
import '../../exchange_messaging_profile/screens/privacy_security_screen.dart';
import '../../user_discovery/screens/auth/login_screen.dart';
import '../../user_discovery/screens/auth/forgot_password_screen.dart';

class ProviderProfileScreen extends StatefulWidget {
  const ProviderProfileScreen({super.key});

  @override
  State<ProviderProfileScreen> createState() => _ProviderProfileScreenState();
}

class _ProviderProfileScreenState extends State<ProviderProfileScreen> {
  static const _red = Color(0xFFED1235);
  late final _user = FirebaseAuth.instance.currentUser;
  late final Stream<DocumentSnapshot<Map<String, dynamic>>>? _profile =
      _user == null ? null : FirebaseFirestore.instance
          .collection('users').doc(_user.uid).snapshots();
  bool _loggingOut = false;

  void _open(Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('Log out of your provider account?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true),
              child: const Text('Log Out')),
        ],
      ),
    );
    if (!mounted || confirmed != true || _loggingOut) return;
    setState(() => _loggingOut = true);
    try {
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to log out. Please try again.')),
      );
    } finally {
      if (mounted) setState(() => _loggingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FA),
      appBar: AppBar(title: const Text('Provider Profile', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          backgroundColor: Colors.white, surfaceTintColor: Colors.white),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream: _profile,
                  builder: (context, snapshot) {
                    final data = snapshot.data?.data() ?? {};
                    final savedName = data['name']?.toString().trim() ?? '';
                    final authName = _user?.displayName?.trim() ?? '';
                    final name = savedName.isNotEmpty ? savedName
                        : authName.isNotEmpty ? authName : 'Provider';
                    final photo = data['photoUrl']?.toString() ?? '';
                    final missing = <String>[
                      if (savedName.isEmpty && authName.isEmpty) 'name',
                      if (photo.isEmpty) 'photo',
                      if ((data['phone']?.toString().trim() ?? '').isEmpty) 'phone',
                      if ((data['location']?.toString().trim() ?? '').isEmpty) 'location',
                    ];
                    return Column(children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFB90D32), Color(0xFFFF365B)],
                            begin: Alignment.topLeft, end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(26),
                        ),
                        child: Column(children: [
                          Row(children: [
                            const Expanded(child: Text('YOUR PROVIDER ACCOUNT',
                              style: TextStyle(color: Colors.white70, fontSize: 11,
                                fontWeight: FontWeight.w700, letterSpacing: 1.4))),
                            IconButton(
                              tooltip: 'Edit profile',
                              onPressed: () => _open(const EditProfileScreen()),
                              icon: const Icon(Icons.edit_outlined, color: Colors.white),
                            ),
                          ]),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(shape: BoxShape.circle,
                              border: Border.all(color: Colors.white54, width: 2)),
                            child: ClipOval(child: photo.isEmpty ? _avatar()
                              : Image.network(photo, width: 88, height: 88,
                                fit: BoxFit.cover,
                                errorBuilder: (_, error, stack) => _avatar())),
                          ),
                          const SizedBox(height: 16),
                          Text(name, textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 26, color: Colors.white,
                              fontWeight: FontWeight.w800)),
                          const SizedBox(height: 6),
                          Text(_user?.email ?? '', textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white70, fontSize: 13)),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(color: Colors.white.withValues(alpha: .16),
                              borderRadius: BorderRadius.circular(24)),
                            child: const Text('Equipment Provider',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                          ),
                          if ((data['location']?.toString().trim() ?? '').isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Text(data['location'].toString(), textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white70)),
                          ],
                        ]),
                      ),
                      const SizedBox(height: 16),
                      if (snapshot.hasError)
                        const Text('Unable to load current profile details.')
                      else if (!snapshot.hasData)
                        const LinearProgressIndicator(color: _red)
                      else
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: _panel(),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Row(children: [
                              const Expanded(child: Text('Profile completeness',
                                style: TextStyle(fontWeight: FontWeight.w700))),
                              Text('${((4 - missing.length) / 4 * 100).round()}%',
                                style: const TextStyle(color: _red, fontWeight: FontWeight.w800)),
                            ]),
                            const SizedBox(height: 12),
                            ClipRRect(borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(value: (4 - missing.length) / 4,
                                minHeight: 6, color: _red, backgroundColor: const Color(0xFFFFE7ED))),
                            const SizedBox(height: 10),
                            Text(missing.isEmpty ? 'Your profile is ready.'
                              : 'Add your ${missing.join(', ')} to complete your profile.',
                              style: const TextStyle(fontSize: 12, color: Colors.black54)),
                            if (missing.isNotEmpty)
                              TextButton(onPressed: () => _open(const EditProfileScreen()),
                                child: const Text('Complete profile →', style: TextStyle(color: _red))),
                          ]),
                        ),
                    ]);
                  },
                ),
                _heading('Provider account'),
                _tile(Icons.person_outline, 'Edit Profile',
                    'Update your name, photo and contact details',
                    const EditProfileScreen()),
                _tile(Icons.lock_outline, 'Password & Security',
                    'Manage your account security', const PrivacySecurityScreen()),
                _tile(Icons.mark_email_read_outlined, 'Reset Password',
                    'Get a password reset link by email',
                    const ForgotPasswordScreen(fromProfile: true)),
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: _loggingOut ? null : _logout,
                  icon: const Icon(Icons.logout),
                  label: Text(_loggingOut ? 'Logging out…' : 'Log Out'),
                  style: OutlinedButton.styleFrom(foregroundColor: _red,
                      padding: const EdgeInsets.all(16)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _panel() => BoxDecoration(color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: const Color(0xFFEBEBEF)));

  Widget _avatar() => const CircleAvatar(radius: 44,
      backgroundColor: Color(0xFFFFEEF1),
      child: Icon(Icons.storefront_outlined, size: 44, color: _red));

  Widget _heading(String text) => Padding(
      padding: const EdgeInsets.fromLTRB(4, 24, 4, 10),
      child: Text(text, style: const TextStyle(fontSize: 17,
          fontWeight: FontWeight.w800)));

  Widget _tile(IconData icon, String title, String subtitle, Widget screen) {
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xFFEBEBEF))),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: const Color(0xFFFFEEF1),
            borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: _red, size: 22)),
        title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        subtitle: Padding(padding: const EdgeInsets.only(top: 4),
          child: Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF85858F), height: 1.4))),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _open(screen),
      ),
    );
  }
}
