import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  static const Color greyText = Color(0xFF7D7D7D);
  static const Color borderColor = Color(0xFFE7E7E7);
  static const Color backgroundColor = Color(0xFFF8F8F8);

  @override
  Widget build(BuildContext context) {
    final ProfileService profileService = ProfileService();

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: darkText,
            fontSize: 21,
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
            child: StreamBuilder<
                DocumentSnapshot<Map<String, dynamic>>>(
              stream: profileService.watchProfile(),
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                        ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: primaryRed,
                    ),
                  );
                }

                final data = snapshot.data?.data() ?? {};

                final String name =
                    data['name']?.toString().trim() ?? '';

                final String email =
                    data['email']?.toString().trim() ??
                        FirebaseAuth.instance.currentUser?.email ??
                        '';

                final String phone =
                    data['phone']?.toString().trim() ?? '';

                final String location =
                    data['location']?.toString().trim() ?? '';

                final String photoUrl =
                    data['photoUrl']?.toString().trim() ?? '';

                final bool isVerified =
                    data['isVerified'] == true;

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    18,
                    20,
                    18,
                    32,
                  ),
                  child: Column(
                    children: [
                      _buildProfileHeader(
                        name: name.isEmpty
                            ? 'Rent Lanka User'
                            : name,
                        email: email,
                        location: location,
                        photoUrl: photoUrl,
                        isVerified: isVerified,
                      ),

                      const SizedBox(height: 18),

                      _buildContactCard(
                        email: email,
                        phone: phone,
                        location: location,
                      ),

                      const SizedBox(height: 24),

                      _buildSectionTitle(
                        'Account',
                      ),

                      const SizedBox(height: 10),

                      _buildMenuContainer(
                        children: [
                          _buildMenuTile(
                            icon: Icons.person_outline_rounded,
                            iconColor: primaryRed,
                            iconBackground:
                                const Color(0xFFFFEEF1),
                            title: 'Edit Profile',
                            subtitle:
                                'Update your personal information',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const EditProfileScreen(),
                                ),
                              );
                            },
                          ),
                          _divider(),
                          _buildMenuTile(
                            icon: Icons.settings_outlined,
                            iconColor:
                                const Color(0xFF3478C7),
                            iconBackground:
                                const Color(0xFFEDF4FF),
                            title: 'Settings',
                            subtitle:
                                'Privacy, notifications and preferences',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const SettingsScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 22),

                      _buildSectionTitle(
                        'Activity & Support',
                      ),

                      const SizedBox(height: 10),

                      _buildMenuContainer(
                        children: [
                          _buildMenuTile(
                            icon: Icons.receipt_long_outlined,
                            iconColor:
                                const Color(0xFF24945E),
                            iconBackground:
                                const Color(0xFFEAF8F1),
                            title: 'Transaction History',
                            subtitle:
                                'Payments, refunds and transactions',
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
                          _divider(),
                          _buildMenuTile(
                            icon: Icons.help_outline_rounded,
                            iconColor:
                                const Color(0xFFE28B1A),
                            iconBackground:
                                const Color(0xFFFFF4E5),
                            title: 'Help & Support',
                            subtitle:
                                'FAQs and report a problem',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const HelpSupportScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 26),

                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            _showLogoutDialog(
                              context,
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: primaryRed,
                            backgroundColor:
                                const Color(0xFFFFF4F5),
                            side: const BorderSide(
                              color: Color(0xFFFFCCD4),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(14),
                            ),
                          ),
                          icon: const Icon(
                            Icons.logout_rounded,
                            size: 20,
                          ),
                          label: const Text(
                            'Log Out',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        'Rent Lanka',
                        style: TextStyle(
                          color: Color(0xFFAAAAAA),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader({
    required String name,
    required String email,
    required String location,
    required String photoUrl,
    required bool isVerified,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 94,
                height: 94,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEEF1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFFFD7DD),
                    width: 3,
                  ),
                ),
                child: photoUrl.isEmpty
                    ? const Icon(
                        Icons.person_rounded,
                        size: 56,
                        color: primaryRed,
                      )
                    : Image.network(
                        photoUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (
                          context,
                          error,
                          stackTrace,
                        ) {
                          return const Icon(
                            Icons.person_rounded,
                            size: 56,
                            color: primaryRed,
                          );
                        },
                      ),
              ),
              if (isVerified)
                Positioned(
                  right: 1,
                  bottom: 3,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E9B50),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 3,
                      ),
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: 15,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 14),

          Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: darkText,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),

          if (email.isNotEmpty) ...[
            const SizedBox(height: 5),
            Text(
              email,
              style: const TextStyle(
                color: greyText,
                fontSize: 13,
              ),
            ),
          ],

          if (location.isNotEmpty) ...[
            const SizedBox(height: 9),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F3F4),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    color: greyText,
                    size: 16,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    location,
                    style: const TextStyle(
                      color: darkText,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContactCard({
    required String email,
    required String phone,
    required String location,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Column(
        children: [
          _buildInfoRow(
            icon: Icons.mail_outline_rounded,
            title: 'Email',
            value: email.isEmpty
                ? 'Not added'
                : email,
          ),
          const SizedBox(height: 15),
          _buildInfoRow(
            icon: Icons.phone_outlined,
            title: 'Phone',
            value: phone.isEmpty
                ? 'Not added'
                : phone,
          ),
          const SizedBox(height: 15),
          _buildInfoRow(
            icon: Icons.location_on_outlined,
            title: 'Location',
            value: location.isEmpty
                ? 'Not added'
                : location,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFFFEEF1),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(
            icon,
            color: primaryRed,
            size: 20,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: greyText,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: darkText,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(
    String text,
  ) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          color: darkText,
          fontSize: 16,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildMenuContainer({
    required List<Widget> children,
  }) {
    return Container(
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

  Widget _buildMenuTile({
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
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
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
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
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

  Future<void> _showLogoutDialog(
    BuildContext context,
  ) async {
    final bool? confirmed =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text(
            'Log out?',
            style: TextStyle(
              color: darkText,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: const Text(
            'Are you sure you want to log out of Rent Lanka?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: darkText,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: const Text(
                'Log Out',
                style: TextStyle(
                  color: primaryRed,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      await FirebaseAuth.instance.signOut();

      if (!context.mounted) {
        return;
      }

      Navigator.of(context).popUntil(
        (route) => route.isFirst,
      );
    } on FirebaseAuthException catch (error) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.message ??
                'Unable to log out.',
          ),
        ),
      );
    }
  }
}