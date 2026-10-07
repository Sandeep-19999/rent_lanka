import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

import 'features/exchange_messaging_profile/screens/chat_screen.dart';
import 'features/exchange_messaging_profile/screens/edit_profile_screen.dart';
import 'features/exchange_messaging_profile/screens/exchange_request_screen.dart';
import 'features/exchange_messaging_profile/screens/help_support_screen.dart';
import 'features/exchange_messaging_profile/screens/member3_login_screen.dart';
import 'features/exchange_messaging_profile/screens/messages_screen.dart';
import 'features/exchange_messaging_profile/screens/notifications_screen.dart';
import 'features/exchange_messaging_profile/screens/profile_screen.dart';
import 'features/exchange_messaging_profile/screens/rate_review_screen.dart';
import 'features/exchange_messaging_profile/screens/settings_screen.dart';
import 'features/exchange_messaging_profile/screens/transaction_history_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const Member3PreviewApp());
}

class Member3PreviewApp extends StatelessWidget {
  const Member3PreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Rent Lanka - Member 3 Preview',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Arial',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFED1235),
          primary: const Color(0xFFED1235),
        ),
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              backgroundColor: Colors.white,
              body: Center(
                child: CircularProgressIndicator(color: Color(0xFFED1235)),
              ),
            );
          }

          if (snapshot.data == null) {
            return const Member3LoginScreen();
          }

          return const Member3PreviewHome();
        },
      ),
    );
  }
}

class Member3PreviewHome extends StatelessWidget {
  const Member3PreviewHome({super.key});

  static const Color primaryRed = Color(0xFFED1235);

  static const Color darkText = Color(0xFF242424);

  static const Color greyText = Color(0xFF888888);

  static const String providerUid = 'dAdkwy1AdhXYkvFURyseUTfvDd43';

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Member 3 UI Preview',
          style: TextStyle(fontWeight: FontWeight.w800, color: darkText),
        ),
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
            icon: const Icon(Icons.logout, color: darkText),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 30),
        children: [
          if (currentUser != null) _buildLoggedInUserCard(currentUser),

          _buildSectionTitle('Exchange'),

          const SizedBox(height: 8),

          _PreviewTile(
            icon: Icons.swap_horiz_rounded,
            title: 'Exchange Request',
            subtitle: 'Send request → then Exchange Status opens',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ExchangeRequestScreen(
                    requestedEquipmentId: 'demo_requested_cricket_bat',
                    requestedEquipmentName: 'Cricket Bat',
                    requestedProviderId: providerUid,
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 22),

          _buildSectionTitle('Messaging'),

          const SizedBox(height: 8),

          _PreviewTile(
            icon: Icons.message_outlined,
            title: 'Messages',
            subtitle: 'Firebase conversation list',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MessagesScreen()),
              );
            },
          ),

          _PreviewTile(
            icon: Icons.chat_bubble_outline,
            title: 'Chat',
            subtitle: 'Player ↔ Provider chat',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ChatScreen(
                    chatId: 'demo_chat_kamal_sports',
                    chatName: 'Kamal Sports Gear',
                    otherUserId: 'demo_kamal_provider',
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 22),

          _buildSectionTitle('Notifications & Reviews'),

          const SizedBox(height: 8),

          _PreviewTile(
            icon: Icons.notifications_none,
            title: 'Notifications',
            subtitle: 'Firebase activity notifications',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              );
            },
          ),

          _PreviewTile(
            icon: Icons.star_outline,
            title: 'Rate & Reviews',
            subtitle: 'Completed rentals from Firebase',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RateReviewScreen()),
              );
            },
          ),

          const SizedBox(height: 22),

          _buildSectionTitle('Profile'),

          const SizedBox(height: 8),

          _PreviewTile(
            icon: Icons.person_outline,
            title: 'Profile',
            subtitle: 'Main profile screen',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),

          _PreviewTile(
            icon: Icons.edit_outlined,
            title: 'Edit Profile',
            subtitle: 'Edit details and profile photo',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              );
            },
          ),

          _PreviewTile(
            icon: Icons.settings_outlined,
            title: 'Settings',
            subtitle: 'Preferences and account',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),

          _PreviewTile(
            icon: Icons.receipt_long_outlined,
            title: 'Transaction History',
            subtitle: 'Payments and refunds',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const TransactionHistoryScreen(),
                ),
              );
            },
          ),

          _PreviewTile(
            icon: Icons.help_outline,
            title: 'Help & Support',
            subtitle: 'FAQs, search and report problem',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HelpSupportScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLoggedInUserCard(User currentUser) {
    return Container(
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 22),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F7F9),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.check_circle, size: 16, color: Color(0xFF22A35A)),
              SizedBox(width: 6),
              Text(
                'Firebase user logged in',
                style: TextStyle(fontSize: 12, color: greyText),
              ),
            ],
          ),

          const SizedBox(height: 6),

          Text(
            currentUser.email ?? 'No email',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: darkText,
            ),
          ),

          const SizedBox(height: 4),

          SelectableText(
            'UID: ${currentUser.uid}',
            style: const TextStyle(fontSize: 11, color: Color(0xFF777777)),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: greyText,
      ),
    );
  }
}

class _PreviewTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _PreviewTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const Color primaryRed = Color(0xFFED1235);

    const Color darkText = Color(0xFF242424);

    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFE4E4E4)),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        leading: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFFFFEDF0),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: primaryRed),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w700, color: darkText),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right, color: Color(0xFF777777)),
      ),
    );
  }
}
