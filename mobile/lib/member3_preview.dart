import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'features/exchange_messaging_profile/models/review_equipment_option.dart';

import 'firebase_options.dart';

import 'features/exchange_messaging_profile/screens/chat_screen.dart';
import 'features/exchange_messaging_profile/screens/edit_profile_screen.dart';
import 'features/exchange_messaging_profile/screens/exchange_request_screen.dart';
import 'features/exchange_messaging_profile/screens/help_support_screen.dart';
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
      ),
      home: const Member3PreviewHome(),
    );
  }
}

class Member3PreviewHome extends StatelessWidget {
  const Member3PreviewHome({super.key});

  static const Color primaryRed = Color(0xFFED1235);
  static const Color darkText = Color(0xFF242424);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: const Text(
          'Member 3 UI Preview',
          style: TextStyle(fontWeight: FontWeight.w800, color: darkText),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 30),
        children: [
          const Text(
            'Exchange',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF888888),
            ),
          ),

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
                    requestedProviderId: 'demo_target_provider',
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 22),

          const Text(
            'Messaging',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF888888),
            ),
          ),

          const SizedBox(height: 8),

          _PreviewTile(
            icon: Icons.message_outlined,
            title: 'Messages',
            subtitle: 'Conversation list',
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

          const Text(
            'Notifications & Reviews',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF888888),
            ),
          ),

          const SizedBox(height: 8),

          _PreviewTile(
            icon: Icons.notifications_none,
            title: 'Notifications',
            subtitle: 'Activity notifications',
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
            subtitle: 'Submit or update a review',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const RateReviewScreen(
                    equipmentId: 'demo_ss_cricket_bat',
                    providerId: 'demo_provider_001',
                    bookingId: 'demo_booking_001',
                    equipmentName: 'SS Cricket Bat',
                    rentedDate: '15 Sep',
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 22),

          const Text(
            'Profile',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF888888),
            ),
          ),

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
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
