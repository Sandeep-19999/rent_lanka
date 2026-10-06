import 'package:flutter/material.dart';

import 'chat_screen.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  static const Color primaryRed = Color(0xFFED1235);
  static const Color darkText = Color(0xFF242424);
  static const Color greyText = Color(0xFF929292);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    children: [
                      _buildHeader(context),

                      const SizedBox(height: 28),

                      _buildMessageItem(
                        context: context,
                        chatId: 'demo_chat_kamal_sports',
                        otherUserId: 'demo_kamal_provider',
                        initial: 'K',
                        name: 'Kamal Sports Gear',
                        message: 'Your pickup time is confirmed.',
                        time: '10:30 AM',
                        unreadCount: 0,
                        highlighted: false,
                      ),

                      _buildMessageItem(
                        context: context,
                        chatId: 'demo_chat_city_sports',
                        otherUserId: 'demo_city_provider',
                        initial: 'C',
                        name: 'City Sports Shop',
                        message: 'Exchange request received.',
                        time: 'Yesterday',
                        unreadCount: 1,
                        highlighted: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            _buildBottomNavigation(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 20, 0),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              Navigator.maybePop(context);
            },
            borderRadius: BorderRadius.circular(50),
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.arrow_back_ios_new, size: 24, color: darkText),
            ),
          ),

          const SizedBox(width: 10),

          const Text(
            'Messages',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: darkText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageItem({
    required BuildContext context,
    required String chatId,
    required String otherUserId,
    required String initial,
    required String name,
    required String message,
    required String time,
    required int unreadCount,
    required bool highlighted,
  }) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatScreen(
              chatId: chatId,
              chatName: name,
              otherUserId: otherUserId,
            ),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        color: highlighted ? const Color(0xFFFFF1F3) : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Color(0xFFF7F7F7),
                shape: BoxShape.circle,
              ),
              child: Text(
                initial,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: highlighted ? primaryRed : darkText,
                ),
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: darkText,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    message,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: highlighted
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: highlighted ? darkText : greyText,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: highlighted ? FontWeight.w600 : FontWeight.w400,
                    color: highlighted ? primaryRed : greyText,
                  ),
                ),

                const SizedBox(height: 7),

                if (unreadCount > 0)
                  Container(
                    width: 21,
                    height: 21,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: primaryRed,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      unreadCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                else
                  const SizedBox(width: 21, height: 21),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEAEAEA))),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavigationItem(icon: Icons.home_outlined, label: 'Home'),
          _NavigationItem(icon: Icons.search, label: 'Search'),
          _NavigationItem(
            icon: Icons.file_download_outlined,
            label: 'Bookings',
          ),
          _NavigationItem(
            icon: Icons.chat_bubble,
            label: 'Messages',
            active: true,
          ),
          _NavigationItem(icon: Icons.person_outline, label: 'Profile'),
        ],
      ),
    );
  }
}

class _NavigationItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;

  const _NavigationItem({
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
            size: 25,
            color: active ? primaryRed : const Color(0xFF8E8E8E),
          ),

          const SizedBox(height: 4),

          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: active ? FontWeight.w600 : FontWeight.w400,
              color: active ? primaryRed : const Color(0xFF8E8E8E),
            ),
          ),
        ],
      ),
    );
  }
}
