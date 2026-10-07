import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/chat_service.dart';
import 'chat_screen.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  static const Color primaryRed = Color(0xFFED1235);

  static const Color darkText = Color(0xFF242424);

  static const Color greyText = Color(0xFF929292);

  @override
  Widget build(BuildContext context) {
    final ChatService chatService = ChatService();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              children: [
                _buildHeader(context),

                const SizedBox(height: 16),

                Expanded(
                  child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: chatService.watchMyChats(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              'Unable to load conversations.\n${snapshot.error}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: greyText),
                            ),
                          ),
                        );
                      }

                      if (snapshot.connectionState == ConnectionState.waiting &&
                          !snapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(color: primaryRed),
                        );
                      }

                      final chats = [...?snapshot.data?.docs];

                      chats.sort((a, b) {
                        final DateTime aTime = _dateFromTimestamp(
                          a.data()['lastMessageAt'],
                        );

                        final DateTime bTime = _dateFromTimestamp(
                          b.data()['lastMessageAt'],
                        );

                        return bTime.compareTo(aTime);
                      });

                      if (chats.isEmpty) {
                        return _buildEmptyState();
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                        itemCount: chats.length,
                        separatorBuilder: (_, __) =>
                            const Divider(height: 1, color: Color(0xFFEEEEEE)),
                        itemBuilder: (context, index) {
                          final document = chats[index];

                          final data = document.data();

                          final List<String> participants = _getParticipants(
                            data['participants'],
                          );

                          final String otherUserId = participants.firstWhere(
                            (id) => id != chatService.currentUserId,
                            orElse: () => '',
                          );

                          final String otherUserName = _getOtherUserName(
                            data: data,
                            otherUserId: otherUserId,
                          );

                          final String lastMessage =
                              data['lastMessage']?.toString().trim() ?? '';

                          final int unreadCount = _getUnreadCount(
                            data: data,
                            currentUserId: chatService.currentUserId,
                          );

                          final DateTime lastMessageAt = _dateFromTimestamp(
                            data['lastMessageAt'],
                          );

                          return _buildConversationTile(
                            context: context,
                            chatService: chatService,
                            chatId: document.id,
                            otherUserId: otherUserId,
                            otherUserName: otherUserName,
                            lastMessage: lastMessage,
                            lastMessageAt: lastMessageAt,
                            unreadCount: unreadCount,
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              Navigator.maybePop(context);
            },
            borderRadius: BorderRadius.circular(50),
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.arrow_back_ios_new, size: 23, color: darkText),
            ),
          ),

          const SizedBox(width: 18),

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

  Widget _buildConversationTile({
    required BuildContext context,
    required ChatService chatService,
    required String chatId,
    required String otherUserId,
    required String otherUserName,
    required String lastMessage,
    required DateTime lastMessageAt,
    required int unreadCount,
  }) {
    final bool hasUnread = unreadCount > 0;

    return Material(
      color: hasUnread ? const Color(0xFFFFF1F3) : Colors.white,
      child: InkWell(
        onTap: otherUserId.isEmpty
            ? null
            : () async {
                // Clear unread count when
                // the user opens this chat.
                try {
                  await chatService.markChatAsRead(chatId);
                } catch (error) {
                  debugPrint('Unable to mark chat as read: $error');
                }

                if (!context.mounted) {
                  return;
                }

                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatScreen(
                      chatId: chatId,
                      chatName: otherUserName,
                      otherUserId: otherUserId,
                    ),
                  ),
                );

                // Mark again after returning,
                // in case messages arrived while
                // the chat was open.
                try {
                  await chatService.markChatAsRead(chatId);
                } catch (error) {
                  debugPrint(
                    'Unable to mark chat as read after return: $error',
                  );
                }
              },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 6),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Color(0xFFF5F5F6),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  _firstLetter(otherUserName),
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: hasUnread ? primaryRed : darkText,
                  ),
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      otherUserName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: darkText,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      lastMessage.isEmpty
                          ? 'Start a conversation'
                          : lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        color: hasUnread ? darkText : greyText,
                        fontWeight: hasUnread
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatTime(lastMessageAt),
                    style: TextStyle(
                      fontSize: 11,
                      color: hasUnread ? primaryRed : greyText,
                      fontWeight: hasUnread ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),

                  const SizedBox(height: 8),

                  if (hasUnread)
                    Container(
                      constraints: const BoxConstraints(
                        minWidth: 22,
                        minHeight: 22,
                      ),
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: const BoxDecoration(
                        color: primaryRed,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        unreadCount > 99 ? '99+' : '$unreadCount',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    )
                  else
                    const SizedBox(height: 22),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.chat_bubble_outline, size: 56, color: Color(0xFFB5B5B5)),
            SizedBox(height: 14),
            Text(
              'No conversations yet',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: darkText,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Your conversations with players and providers will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: greyText),
            ),
          ],
        ),
      ),
    );
  }

  static List<String> _getParticipants(dynamic value) {
    if (value is! List) {
      return [];
    }

    return value.map((item) => item.toString()).toList();
  }

  static String _getOtherUserName({
    required Map<String, dynamic> data,
    required String otherUserId,
  }) {
    final dynamic rawNames = data['participantNames'];

    if (rawNames is Map && otherUserId.isNotEmpty) {
      final dynamic name = rawNames[otherUserId];

      final String cleanName = name?.toString().trim() ?? '';

      if (cleanName.isNotEmpty) {
        return cleanName;
      }
    }

    final String legacyName = data['otherUserName']?.toString().trim() ?? '';

    if (legacyName.isNotEmpty) {
      return legacyName;
    }

    return 'Provider';
  }

  static int _getUnreadCount({
    required Map<String, dynamic> data,
    required String currentUserId,
  }) {
    final dynamic rawCounts = data['unreadCounts'];

    if (rawCounts is! Map) {
      return 0;
    }

    final dynamic value = rawCounts[currentUserId];

    if (value is num) {
      return value.toInt();
    }

    return 0;
  }

  static DateTime _dateFromTimestamp(dynamic value) {
    if (value is Timestamp) {
      return value.toDate().toLocal();
    }

    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  static String _firstLetter(String value) {
    final String clean = value.trim();

    if (clean.isEmpty) {
      return '?';
    }

    return clean.substring(0, 1).toUpperCase();
  }

  static String _formatTime(DateTime date) {
    if (date.millisecondsSinceEpoch == 0) {
      return '';
    }

    final DateTime now = DateTime.now();

    final DateTime today = DateTime(now.year, now.month, now.day);

    final DateTime messageDate = DateTime(date.year, date.month, date.day);

    final int difference = today.difference(messageDate).inDays;

    if (difference == 0) {
      int hour = date.hour;

      final String period = hour >= 12 ? 'PM' : 'AM';

      if (hour == 0) {
        hour = 12;
      } else if (hour > 12) {
        hour -= 12;
      }

      final String minute = date.minute.toString().padLeft(2, '0');

      return '$hour:$minute $period';
    }

    if (difference == 1) {
      return 'Yesterday';
    }

    return '${date.day}/${date.month}/${date.year}';
  }
}
