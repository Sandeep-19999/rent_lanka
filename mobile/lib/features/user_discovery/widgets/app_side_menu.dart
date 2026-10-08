
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rent_lanka_mobile/features/booking_payment/screens/booking/my_bookings_screen.dart';

import 'package:rent_lanka_mobile/features/user_discovery/screens/auth/login_screen.dart';
import 'package:rent_lanka_mobile/features/user_discovery/screens/search/category_equipment_screen.dart';

class AppSideMenu extends StatelessWidget {
  const AppSideMenu({super.key});

  static const Color primaryRed = Color(0xFFED1C24);
  static const Color darkText = Color(0xFF171717);

  // =========================================================
  // LOG OUT
  // =========================================================

  Future<void> _logout(BuildContext context) async {
    try {
      // Sign out from Firebase Authentication
      await FirebaseAuth.instance.signOut();

      if (!context.mounted) return;

      // Navigate to Login Screen and remove previous screens
      Navigator.of(
        context,
        rootNavigator: true,
      ).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Logout failed: ${e.message ?? "Please try again."}',
          ),
          backgroundColor: primaryRed,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Something went wrong. Please try again.',
          ),
        ),
      );
    }
  }

  // =========================================================
  // BUILD DRAWER
  // =========================================================

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    String name = user?.displayName?.trim() ?? '';

    if (name.isEmpty && user?.email != null) {
      name = user!.email!.split('@').first;
    }

    if (name.isEmpty) {
      name = 'Player';
    }

    return Drawer(
      width: 280,
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // Scrollable Menu
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildHeader(name),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      18,
                      16,
                      12,
                      8,
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Menu',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: darkText,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(
                            Icons.close_rounded,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Home
                  _buildMenuItem(
                    title: 'Home',
                    selected: true,
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),

                  _buildMenuItem(
                    title: 'My Bookings',
                    trailing: Icons.event_note_outlined,
                    onTap: () {
                      final navigator = Navigator.of(context);
                      if (FirebaseAuth.instance.currentUser == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please log in to view bookings.')),
                        );
                        return;
                      }
                      navigator.pop();
                      navigator.push(MaterialPageRoute(
                        builder: (_) => const MyBookingsScreen(),
                      ));
                    },
                  ),

                  // Sports Categories
                  ...[
                    'Cricket',
                    'Football',
                    'Volleyball',
                    'Cycling',
                    'Swimming',
                    'Hockey',
                  ].map(
                    (category) => _buildMenuItem(
                      title: category,
                      trailing: Icons.add_rounded,
                      onTap: () {
                        Navigator.pop(context);

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                CategoryEquipmentScreen(
                              category: category,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // =================================================
            // LOG OUT BUTTON
            // =================================================

            const Divider(
              indent: 18,
              endIndent: 18,
            ),

            ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              leading: const Icon(
                Icons.logout_rounded,
                color: primaryRed,
              ),
              title: const Text(
                'Log out',
                style: TextStyle(
                  color: primaryRed,
                  fontWeight: FontWeight.w700,
                ),
              ),
              onTap: () {
                _logout(context);
              },
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // HEADER
  // =========================================================

  Widget _buildHeader(String name) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        18,
        20,
        18,
        16,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFFFF0F1),
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(22),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 23,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.person_rounded,
              color: primaryRed,
              size: 25,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Hi, $name!',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: darkText,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // MENU ITEM
  // =========================================================

  Widget _buildMenuItem({
    required String title,
    required VoidCallback onTap,
    bool selected = false,
    IconData? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 2,
      ),
      child: ListTile(
        dense: true,
        visualDensity: VisualDensity.compact,
        selected: selected,
        selectedTileColor: const Color(0xFFFFF0F1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(9),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: selected ? primaryRed : darkText,
          ),
        ),
        trailing: trailing == null
            ? null
            : Icon(
                trailing,
                size: 17,
                color: const Color(0xFF777777),
              ),
        onTap: onTap,
      ),
    );
  }
}
