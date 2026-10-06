import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/profile_service.dart';
import 'edit_profile_screen.dart';
import 'help_support_screen.dart';
import 'settings_screen.dart';
import 'transaction_history_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const Color primaryRed = Color(0xFFED1235);
  static const Color darkText = Color(0xFF242424);
  static const Color greyText = Color(0xFF929292);

  @override
  Widget build(BuildContext context) {
    final ProfileService profileService = ProfileService();

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
                    padding: const EdgeInsets.fromLTRB(20, 22, 20, 25),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Profile',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: darkText,
                          ),
                        ),

                        const SizedBox(height: 20),

                        StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                          stream: profileService.watchProfile(),
                          builder: (context, snapshot) {
                            final data = snapshot.data?.data();

                            final String name =
                                data?['name']?.toString() ?? 'User';

                            final String location =
                                data?['location']?.toString() ?? 'Sri Lanka';

                            final String photoUrl =
                                data?['photoUrl']?.toString() ?? '';

                            final bool isVerified = data?['isVerified'] == true;

                            return _buildProfileCard(
                              name: name,
                              location: location,
                              photoUrl: photoUrl,
                              isVerified: isVerified,
                            );
                          },
                        ),

                        const SizedBox(height: 28),

                        _buildMenuTile(
                          icon: Icons.edit_outlined,
                          iconColor: const Color(0xFFFF2A86),
                          iconBackground: const Color(0xFFFFEDF5),
                          title: 'Edit profile',
                          subtitle: null,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const EditProfileScreen(),
                              ),
                            );
                          },
                        ),

                        _buildMenuTile(
                          icon: Icons.settings_outlined,
                          iconColor: const Color(0xFF1687D9),
                          iconBackground: const Color(0xFFE8F5FF),
                          title: 'Settings',
                          subtitle: 'Notifications, privacy, payment',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SettingsScreen(),
                              ),
                            );
                          },
                        ),

                        _buildMenuTile(
                          icon: Icons.receipt_long_outlined,
                          iconColor: const Color(0xFF16B95B),
                          iconBackground: const Color(0xFFE8FAEF),
                          title: 'Transaction history',
                          subtitle: 'Payments and refunds',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const TransactionHistoryScreen(),
                              ),
                            );
                          },
                        ),

                        _buildMenuTile(
                          icon: Icons.help_outline_rounded,
                          iconColor: const Color(0xFFFF6A00),
                          iconBackground: const Color(0xFFFFF0E3),
                          title: 'Help & support',
                          subtitle: 'FAQs, report a problem',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const HelpSupportScreen(),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 22),

                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: OutlinedButton(
                            onPressed: () {
                              _showLogoutDialog(context);
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: primaryRed,
                              backgroundColor: const Color(0xFFFFF4F5),
                              side: const BorderSide(
                                color: Color(0xFFFFD4DA),
                                width: 1.2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: const Text(
                              'Log out',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
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

  Widget _buildProfileCard({
    required String name,
    required String location,
    required String photoUrl,
    required bool isVerified,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryRed,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: photoUrl.isEmpty
                ? const Icon(Icons.person, size: 50, color: Color(0xFF666666))
                : Image.network(
                    photoUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      }

                      return const Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: primaryRed,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.person,
                        size: 50,
                        color: Color(0xFF666666),
                      );
                    },
                  ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 5),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isVerified) ...[
                        const Icon(
                          Icons.check_circle,
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                      ],

                      Flexible(
                        child: Text(
                          isVerified ? 'Verified • $location' : location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required Color iconColor,
    required Color iconBackground,
    required String title,
    required String? subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 13),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: iconBackground,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: iconColor, size: 24),
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

                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 12, color: greyText),
                    ),
                  ],
                ],
              ),
            ),

            const Icon(Icons.chevron_right, color: Color(0xFFC5C5C5), size: 27),
          ],
        ),
      ),
    );
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
          _ProfileNavigationItem(icon: Icons.home_outlined, label: 'Home'),
          _ProfileNavigationItem(icon: Icons.search, label: 'Search'),
          _ProfileNavigationItem(
            icon: Icons.file_download_outlined,
            label: 'Bookings',
          ),
          _ProfileNavigationItem(
            icon: Icons.chat_bubble_outline,
            label: 'Messages',
          ),
          _ProfileNavigationItem(
            icon: Icons.person_outline,
            label: 'Profile',
            active: true,
          ),
        ],
      ),
    );
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Log out?'),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Logout will be connected with the authentication module.',
                    ),
                  ),
                );
              },
              child: const Text('Log out', style: TextStyle(color: primaryRed)),
            ),
          ],
        );
      },
    );
  }
}

class _ProfileNavigationItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;

  const _ProfileNavigationItem({
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
