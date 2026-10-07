import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/chat_service.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String chatName;
  final String otherUserId;

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.chatName,
    required this.otherUserId,
  });

  @override
  State<ChatScreen> createState() =>
      _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  static const Color primaryRed =
      Color(0xFFED1235);

  static const Color darkText =
      Color(0xFF242424);

  static const Color greyText =
      Color(0xFF7D7D7D);

  static const Color incomingBubble =
      Color(0xFFF1F1F3);

  static const Color backgroundColor =
      Color(0xFFF8F8F8);

  final ChatService _chatService =
      ChatService();

  final TextEditingController
      _messageController =
      TextEditingController();

  final ScrollController _scrollController =
      ScrollController();

  bool _isSending = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      _markAsRead();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _markAsRead() async {
    try {
      await _chatService.markChatAsRead(
        widget.chatId,
      );
    } catch (_) {}
  }

  Future<void> _sendMessage() async {
    final String text =
        _messageController.text.trim();

    if (text.isEmpty || _isSending) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isSending = true;
    });

    try {
      await _chatService.sendMessage(
        chatId: widget.chatId,
        receiverId: widget.otherUserId,
        receiverName: widget.chatName,
        text: text,
      );

      _messageController.clear();

      _scrollToBottom();
    } on FirebaseException catch (error) {
      if (!mounted) return;

      _showMessage(
        error.message ??
            'Unable to send message.',
      );
    } catch (error) {
      if (!mounted) return;

      _showMessage(
        error
            .toString()
            .replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }

      _scrollController.animateTo(
        _scrollController
            .position.maxScrollExtent,
        duration:
            const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () =>
              Navigator.maybePop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: darkText,
          ),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            _buildAvatar(),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.chatName,
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: darkText,
                      fontSize: 16,
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Rent Lanka chat',
                    style: TextStyle(
                      color: greyText,
                      fontSize: 11,
                      fontWeight:
                          FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(
              maxWidth: 500,
            ),
            child: Column(
              children: [
                Expanded(
                  child: _buildMessages(),
                ),
                _buildMessageInput(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    final String cleanName =
        widget.chatName.trim();

    final String letter =
        cleanName.isEmpty
            ? '?'
            : cleanName[0].toUpperCase();

    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: Color(0xFFFFE9ED),
        shape: BoxShape.circle,
      ),
      child: Text(
        letter,
        style: const TextStyle(
          color: primaryRed,
          fontSize: 16,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildMessages() {
    return StreamBuilder<
        QuerySnapshot<Map<String, dynamic>>>(
      stream: _chatService.watchMessages(
        widget.chatId,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorState();
        }

        if (snapshot.connectionState ==
                ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(
              color: primaryRed,
            ),
          );
        }

        final messages =
            snapshot.data?.docs ?? [];

        if (messages.isEmpty) {
          return _buildEmptyState();
        }

        _markAsRead();
        _scrollToBottom();

        return ListView.builder(
          controller: _scrollController,
          keyboardDismissBehavior:
              ScrollViewKeyboardDismissBehavior
                  .onDrag,
          padding:
              const EdgeInsets.fromLTRB(
            18,
            20,
            18,
            16,
          ),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final document =
                messages[index];

            final data = document.data();

            final String senderId =
                data['senderId']
                        ?.toString() ??
                    '';

            final String text =
                data['text']
                        ?.toString() ??
                    '';

            final bool isMine =
                senderId ==
                    _chatService
                        .currentUserId;

            final DateTime? sentAt =
                data['sentAt'] is Timestamp
                    ? (data['sentAt']
                            as Timestamp)
                        .toDate()
                        .toLocal()
                    : null;

            final bool isRead =
                data['isRead'] == true;

            final DateTime? previousDate =
                index > 0
                    ? _getMessageDate(
                        messages[index - 1]
                            .data()['sentAt'],
                      )
                    : null;

            final bool showDateDivider =
                _shouldShowDateDivider(
              previousDate,
              sentAt,
            );

            return Column(
              children: [
                if (showDateDivider)
                  _buildDateDivider(sentAt),
                _buildMessageBubble(
                  text: text,
                  isMine: isMine,
                  sentAt: sentAt,
                  isRead: isRead,
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDateDivider(
    DateTime? date,
  ) {
    if (date == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 14,
      ),
      child: Row(
        children: [
          const Expanded(
            child: Divider(
              color: Color(0xFFE5E5E5),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 12,
            ),
            child: Text(
              _formatDateLabel(date),
              style: const TextStyle(
                color: greyText,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Expanded(
            child: Divider(
              color: Color(0xFFE5E5E5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble({
    required String text,
    required bool isMine,
    required DateTime? sentAt,
    required bool isRead,
  }) {
    return Align(
      alignment: isMine
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        constraints:
            const BoxConstraints(
          maxWidth: 290,
        ),
        margin:
            const EdgeInsets.only(
          bottom: 10,
        ),
        padding:
            const EdgeInsets.fromLTRB(
          14,
          11,
          12,
          8,
        ),
        decoration: BoxDecoration(
          color: isMine
              ? primaryRed
              : incomingBubble,
          borderRadius:
              BorderRadius.only(
            topLeft:
                const Radius.circular(18),
            topRight:
                const Radius.circular(18),
            bottomLeft: Radius.circular(
              isMine ? 18 : 5,
            ),
            bottomRight:
                Radius.circular(
              isMine ? 5 : 18,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.end,
          children: [
            Align(
              alignment:
                  Alignment.centerLeft,
              child: Text(
                text,
                style: TextStyle(
                  color: isMine
                      ? Colors.white
                      : darkText,
                  fontSize: 14,
                  height: 1.35,
                ),
              ),
            ),
            if (sentAt != null) ...[
              const SizedBox(height: 5),
              Row(
                mainAxisSize:
                    MainAxisSize.min,
                children: [
                  Text(
                    _formatClockTime(
                      sentAt,
                    ),
                    style: TextStyle(
                      color: isMine
                          ? Colors.white
                              .withValues(
                                alpha: 0.78,
                              )
                          : greyText,
                      fontSize: 9,
                    ),
                  ),
                  if (isMine) ...[
                    const SizedBox(
                      width: 4,
                    ),
                    Icon(
                      isRead
                          ? Icons.done_all_rounded
                          : Icons
                              .done_rounded,
                      size: 14,
                      color: Colors.white
                          .withValues(
                            alpha: 0.8,
                          ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(30),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration:
                  const BoxDecoration(
                color:
                    Color(0xFFFFEEF1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons
                    .chat_bubble_outline_rounded,
                size: 34,
                color: primaryRed,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Start a conversation',
              style: TextStyle(
                color: darkText,
                fontSize: 18,
                fontWeight:
                    FontWeight.w800,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              'Send a message to ${widget.chatName}.',
              textAlign:
                  TextAlign.center,
              style: const TextStyle(
                color: greyText,
                fontSize: 13,
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
        padding: EdgeInsets.all(30),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: primaryRed,
              size: 50,
            ),
            SizedBox(height: 14),
            Text(
              'Unable to load messages',
              style: TextStyle(
                color: darkText,
                fontSize: 17,
                fontWeight:
                    FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      color: Colors.white,
      padding:
          const EdgeInsets.fromLTRB(
        14,
        10,
        14,
        12,
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller:
                    _messageController,
                minLines: 1,
                maxLines: 4,
                textCapitalization:
                    TextCapitalization
                        .sentences,
                textInputAction:
                    TextInputAction.send,
                onSubmitted: (_) {
                  _sendMessage();
                },
                decoration:
                    InputDecoration(
                  hintText:
                      'Type a message...',
                  hintStyle:
                      const TextStyle(
                    color:
                        Color(0xFF999999),
                    fontSize: 14,
                  ),
                  filled: true,
                  fillColor:
                      const Color(
                    0xFFF3F3F5,
                  ),
                  contentPadding:
                      const EdgeInsets
                          .symmetric(
                    horizontal: 17,
                    vertical: 13,
                  ),
                  border:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius
                            .circular(24),
                    borderSide:
                        BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 9),
            InkWell(
              onTap: _isSending
                  ? null
                  : _sendMessage,
              borderRadius:
                  BorderRadius.circular(
                50,
              ),
              child: Container(
                width: 46,
                height: 46,
                alignment:
                    Alignment.center,
                decoration:
                    BoxDecoration(
                  color: _isSending
                      ? primaryRed
                          .withValues(
                            alpha: 0.55,
                          )
                      : primaryRed,
                  shape: BoxShape.circle,
                ),
                child: _isSending
                    ? const SizedBox(
                        width: 19,
                        height: 19,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                          color:
                              Colors.white,
                        ),
                      )
                    : const Icon(
                        Icons
                            .send_rounded,
                        color:
                            Colors.white,
                        size: 21,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  DateTime? _getMessageDate(
    dynamic value,
  ) {
    if (value is Timestamp) {
      return value
          .toDate()
          .toLocal();
    }

    return null;
  }

  bool _shouldShowDateDivider(
    DateTime? previous,
    DateTime? current,
  ) {
    if (current == null) {
      return false;
    }

    if (previous == null) {
      return true;
    }

    return previous.year !=
            current.year ||
        previous.month !=
            current.month ||
        previous.day !=
            current.day;
  }

  String _formatDateLabel(
    DateTime date,
  ) {
    final DateTime now =
        DateTime.now();

    final DateTime today =
        DateTime(
      now.year,
      now.month,
      now.day,
    );

    final DateTime target =
        DateTime(
      date.year,
      date.month,
      date.day,
    );

    final int difference =
        today.difference(target).inDays;

    if (difference == 0) {
      return 'Today';
    }

    if (difference == 1) {
      return 'Yesterday';
    }

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatClockTime(
    DateTime date,
  ) {
    int hour = date.hour;

    final String period =
        hour >= 12 ? 'PM' : 'AM';

    if (hour == 0) {
      hour = 12;
    } else if (hour > 12) {
      hour -= 12;
    }

    final String minute =
        date.minute
            .toString()
            .padLeft(2, '0');

    return '$hour:$minute $period';
  }
}