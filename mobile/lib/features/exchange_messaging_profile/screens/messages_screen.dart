import '../models/chat_context.dart';
import 'package:rent_lanka_mobile/navigation/player_bottom_navigation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/chat_service.dart';
import 'chat_screen.dart';

class MessagesScreen extends StatefulWidget {
  final Widget? bottomNavigationBar;
  final ChatService? chatService;

  const MessagesScreen({super.key, this.bottomNavigationBar, this.chatService});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  static const Color primaryRed = Color(0xFFED1235);
  static const Color darkText = Color(0xFF242424);
  static const Color greyText = Color(0xFF7D7D7D);
  static const Color borderColor = Color(0xFFE8E8E8);
  static const Color backgroundColor = Color(0xFFF8F8F8);

  late final ChatService _chatService;
  late final String _currentUserId;
  late final Stream<QuerySnapshot<Map<String, dynamic>>> _chats;
  late final Stream<QuerySnapshot<Map<String, dynamic>>> _hiddenConversations;
  final Set<String> _pendingDeletionIds = {};
  final Set<String> _deletingIds = {};
  final TextEditingController _searchController = TextEditingController();

  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _chatService = widget.chatService ?? ChatService();
    _currentUserId = _chatService.currentUserId;
    _chats = _chatService.watchMyChats();
    _hiddenConversations = _chatService.watchMyHiddenConversations();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: widget.bottomNavigationBar ??
          const PlayerBottomNavigation(currentIndex: 3),
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: darkText,
          ),
        ),
        titleSpacing: 0,
        title: const Text(
          'Messages',
          style: TextStyle(
            color: darkText,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              children: [
                _buildSearchBox(),
                Expanded(
                  child: _buildConversationList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBox() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchText = value.trim().toLowerCase();
          });
        },
        decoration: InputDecoration(
          hintText: 'Search conversations',
          hintStyle: const TextStyle(
            color: Color(0xFF999999),
            fontSize: 14,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Color(0xFF888888),
          ),
          suffixIcon: _searchText.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();

                    setState(() {
                      _searchText = '';
                    });
                  },
                  icon: const Icon(
                    Icons.close_rounded,
                    color: Color(0xFF888888),
                  ),
                )
              : null,
          filled: true,
          fillColor: const Color(0xFFF4F4F5),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildConversationList() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _hiddenConversations,
      builder: (context, snapshot) {
        if (snapshot.hasError) return _buildErrorState();
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: primaryRed),
          );
        }
        final hidden = <String, Map<String, dynamic>>{
          for (final document in snapshot.data!.docs)
            if (!document.metadata.hasPendingWrites)
              document.id: document.data(),
        };
        return _buildVisibleConversationList(hidden);
      },
    );
  }

  Widget _buildVisibleConversationList(
    Map<String, Map<String, dynamic>> hidden,
  ) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _chats,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorState();
        }

        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(
              color: primaryRed,
            ),
          );
        }

        final chats = [...?snapshot.data?.docs].where((document) {
          return !ChatService.isConversationHidden(
            document.data(), hidden[document.id],
          );
        }).toList();

        chats.sort((a, b) {
          final DateTime aTime = _dateFromTimestamp(
            a.data()['lastMessageAt'],
          );

          final DateTime bTime = _dateFromTimestamp(
            b.data()['lastMessageAt'],
          );

          return bTime.compareTo(aTime);
        });

        final filteredChats = chats.where((document) {
          final data = document.data();

          final List<String> participants = _getParticipants(
            data['participants'],
          );

          final String otherUserId = participants.firstWhere(
            (id) => id != _currentUserId,
            orElse: () => '',
          );

          final String otherUserName = _getOtherUserName(
            data: data,
            otherUserId: otherUserId,
          );

          final String lastMessage =
              data['lastMessage']?.toString() ?? '';

          if (_searchText.isEmpty) {
            return true;
          }

          return otherUserName.toLowerCase().contains(_searchText) ||
              lastMessage.toLowerCase().contains(_searchText);
        }).toList();

        if (chats.isEmpty) {
          return _buildEmptyState();
        }

        if (filteredChats.isEmpty) {
          return _buildNoSearchResults();
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(
            18,
            18,
            18,
            28,
          ),
          itemCount: filteredChats.length,
          separatorBuilder: (_, _) =>
              const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final document = filteredChats[index];

            final data = document.data();

            final List<String> participants = _getParticipants(
              data['participants'],
            );

            final String otherUserId = participants.firstWhere(
              (id) => id != _currentUserId,
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
              currentUserId: _currentUserId,
            );

            final DateTime lastMessageAt =
                _dateFromTimestamp(
              data['lastMessageAt'],
            );

            return _buildConversationCard(
              chatId: document.id,
              chatContext: ChatContext.fromData(data),
              otherUserId: otherUserId,
              otherUserName: otherUserName,
              lastMessage: lastMessage,
              unreadCount: unreadCount,
              lastMessageAt: lastMessageAt,
            );
          },
        );
      },
    );
  }

  Widget _buildConversationCard({
    required String chatId,
    required ChatContext chatContext,
    required String otherUserId,
    required String otherUserName,
    required String lastMessage,
    required int unreadCount,
    required DateTime lastMessageAt,
  }) {
    final bool hasUnread = unreadCount > 0;

    return Material(
      key: ValueKey('conversation-$chatId'),
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onLongPress: _pendingDeletionIds.contains(chatId)
            ? null
            : () => _showConversationActions(chatId),
        onTap: otherUserId.isEmpty || _pendingDeletionIds.contains(chatId)
            ? null
            : () async {
                try {
                  await _chatService.markChatAsRead(chatId);
                } catch (_) {}

                if (!mounted) return;

                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatScreen(
                      chatId: chatId,
                      chatName: otherUserName,
                      equipmentName: chatContext.equipmentName,
                      contextType: chatContext.contextType,
                      otherUserId: otherUserId,
                    ),
                  ),
                );

                try {
                  await _chatService.markChatAsRead(chatId);
                } catch (_) {}
              },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: hasUnread
                  ? primaryRed.withValues(alpha: 0.25)
                  : borderColor,
            ),
          ),
          child: Row(
            children: [
              _buildAvatar(
                otherUserName,
                hasUnread,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            otherUserName,
                            maxLines: 1,
                            overflow:
                                TextOverflow.ellipsis,
                            style: TextStyle(
                              color: darkText,
                              fontSize: 16,
                              fontWeight: hasUnread
                                  ? FontWeight.w800
                                  : FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (_deletingIds.contains(chatId))
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: primaryRed,
                              strokeWidth: 2,
                            ),
                          )
                        else
                          Text(
                          _formatTime(lastMessageAt),
                          style: TextStyle(
                            color: hasUnread
                                ? primaryRed
                                : greyText,
                            fontSize: 11,
                            fontWeight: hasUnread
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    if (chatContext.label.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        chatContext.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: greyText, fontSize: 12),
                      ),
                    ],
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            lastMessage.isEmpty
                                ? 'Start a conversation'
                                : lastMessage,
                            maxLines: 1,
                            overflow:
                                TextOverflow.ellipsis,
                            style: TextStyle(
                              color: hasUnread
                                  ? darkText
                                  : greyText,
                              fontSize: 13,
                              fontWeight: hasUnread
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ),
                        if (hasUnread) ...[
                          const SizedBox(width: 10),
                          Container(
                            constraints:
                                const BoxConstraints(
                              minWidth: 23,
                              minHeight: 23,
                            ),
                            alignment: Alignment.center,
                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 7,
                            ),
                            decoration:
                                const BoxDecoration(
                              color: primaryRed,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              unreadCount > 99
                                  ? '99+'
                                  : '$unreadCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight:
                                    FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showConversationActions(String chatId) async {
    if (_pendingDeletionIds.contains(chatId)) return;
    setState(() => _pendingDeletionIds.add(chatId));
    try {
      final selected = await showModalBottomSheet<bool>(
        context: context,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
        ),
        builder: (sheetContext) => SafeArea(
          child: ListTile(
            leading: const Icon(Icons.delete_outline_rounded, color: primaryRed),
            title: const Text(
              'Delete Conversation',
              style: TextStyle(color: primaryRed, fontWeight: FontWeight.w700),
            ),
            onTap: () => Navigator.pop(sheetContext, true),
          ),
        ),
      );
      if (selected != true || !mounted) return;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text(
            'Delete Conversation?',
            style: TextStyle(color: darkText, fontWeight: FontWeight.w800),
          ),
          content: const Text(
            'Are you sure you want to delete this conversation from your messages?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel', style: TextStyle(color: darkText)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text(
                'Delete',
                style: TextStyle(color: primaryRed, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      );
      if (confirmed != true || !mounted) return;
      setState(() => _deletingIds.add(chatId));
      await _chatService.deleteConversation(
        chatId, expectedUserId: _currentUserId,
      );
      if (mounted) _showMessage('Conversation deleted.');
    } catch (error) {
      if (!mounted) return;
      _showMessage(switch (error) {
        FirebaseAuthException() =>
          'Please sign in again before deleting conversations.',
        FirebaseException(code: 'permission-denied') =>
          'You do not have permission to delete this conversation.',
        FirebaseException(code: 'not-found') =>
          'This conversation is no longer available.',
        _ => 'Unable to delete conversation. Check your connection and try again.',
      });
    } finally {
      if (mounted) {
        setState(() {
          _pendingDeletionIds.remove(chatId);
          _deletingIds.remove(chatId);
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildAvatar(
    String name,
    bool hasUnread,
  ) {
    return Container(
      width: 54,
      height: 54,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: hasUnread
            ? const Color(0xFFFFE9ED)
            : const Color(0xFFF2F2F3),
        shape: BoxShape.circle,
      ),
      child: Text(
        _firstLetter(name),
        style: TextStyle(
          color: hasUnread ? primaryRed : darkText,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 38,
              backgroundColor: Color(0xFFFFEEF1),
              child: Icon(
                Icons.chat_bubble_outline_rounded,
                size: 34,
                color: primaryRed,
              ),
            ),
            SizedBox(height: 18),
            Text(
              'No conversations yet',
              style: TextStyle(
                color: darkText,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 7),
            Text(
              'When you contact a player or provider, your conversations will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: greyText,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoSearchResults() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 52,
              color: Color(0xFFAAAAAA),
            ),
            SizedBox(height: 14),
            Text(
              'No conversations found',
              style: TextStyle(
                color: darkText,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 50,
              color: primaryRed,
            ),
            SizedBox(height: 14),
            Text(
              'Unable to load conversations',
              style: TextStyle(
                color: darkText,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Please try again in a moment.',
              style: TextStyle(
                color: greyText,
                fontSize: 13,
              ),
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

    return value
        .map((item) => item.toString())
        .toList();
  }

  static String _getOtherUserName({
    required Map<String, dynamic> data,
    required String otherUserId,
  }) {
    final dynamic rawNames =
        data['participantNames'];

    if (rawNames is Map &&
        otherUserId.isNotEmpty) {
      final String name =
          rawNames[otherUserId]
                  ?.toString()
                  .trim() ??
              '';

      if (name.isNotEmpty) {
        return name;
      }
    }

    return 'Rent Lanka User';
  }

  static int _getUnreadCount({
    required Map<String, dynamic> data,
    required String currentUserId,
  }) {
    final dynamic rawCounts =
        data['unreadCounts'];

    if (rawCounts is! Map) {
      return 0;
    }

    final dynamic value =
        rawCounts[currentUserId];

    if (value is num) {
      return value.toInt();
    }

    return 0;
  }

  static DateTime _dateFromTimestamp(
    dynamic value,
  ) {
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

    return clean[0].toUpperCase();
  }

  static String _formatTime(DateTime date) {
    if (date.millisecondsSinceEpoch == 0) {
      return '';
    }

    final DateTime now = DateTime.now();

    final DateTime today =
        DateTime(now.year, now.month, now.day);

    final DateTime messageDate =
        DateTime(date.year, date.month, date.day);

    final int difference =
        today.difference(messageDate).inDays;

    if (difference == 0) {
      return _clockTime(date);
    }

    if (difference == 1) {
      return 'Yesterday';
    }

    if (difference < 7) {
      const weekdays = [
        'Mon',
        'Tue',
        'Wed',
        'Thu',
        'Fri',
        'Sat',
        'Sun',
      ];

      return weekdays[date.weekday - 1];
    }

    return '${date.day}/${date.month}/${date.year}';
  }

  static String _clockTime(DateTime date) {
    int hour = date.hour;

    final String period =
        hour >= 12 ? 'PM' : 'AM';

    if (hour == 0) {
      hour = 12;
    } else if (hour > 12) {
      hour -= 12;
    }

    final String minute =
        date.minute.toString().padLeft(2, '0');

    return '$hour:$minute $period';
  }
}
