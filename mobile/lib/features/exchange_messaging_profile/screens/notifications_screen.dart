import '../../../navigation/notification_destination.dart';
import '../../booking_payment/screens/booking/my_bookings_screen.dart';
import '../../provider/screens/request_details_screen.dart';
import '../../booking_payment/screens/booking/booking_details_screen.dart';
import 'transaction_history_screen.dart';
import 'exchange_status_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/chat_context.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/chat_service.dart';
import '../services/notification_service.dart';
import 'chat_screen.dart';
import 'rate_review_screen.dart';
import 'incoming_exchange_request_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState
    extends State<NotificationsScreen> {
  static const Color primaryRed = Color(0xFFED1235);
  static const Color darkText = Color(0xFF242424);
  static const Color greyText = Color(0xFF7D7D7D);
  static const Color borderColor = Color(0xFFE7E7E7);
  static const Color backgroundColor = Color(0xFFF8F8F8);

  final NotificationService _notificationService =
      NotificationService();

  final ChatService _chatService = ChatService();

  bool _isOpeningNotification = false;

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
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: darkText,
          ),
        ),
        titleSpacing: 0,
        title: const Text(
          'Notifications',
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
            constraints: const BoxConstraints(
              maxWidth: 500,
            ),
            child: StreamBuilder<
                QuerySnapshot<Map<String, dynamic>>>(
              stream:
                  _notificationService.watchMyNotifications(),
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

                final notifications = [
                  ...?snapshot.data?.docs,
                ];

                notifications.sort(
                  (first, second) {
                    final DateTime firstDate =
                        _getDate(
                      first.data()['createdAt'],
                    );

                    final DateTime secondDate =
                        _getDate(
                      second.data()['createdAt'],
                    );

                    return secondDate.compareTo(
                      firstDate,
                    );
                  },
                );

                if (notifications.isEmpty) {
                  return _buildEmptyState();
                }

                final int unreadCount =
                    notifications.where(
                  (document) {
                    return document.data()['isRead'] !=
                        true;
                  },
                ).length;

                return Column(
                  children: [
                    _buildSummaryHeader(
                      unreadCount: unreadCount,
                    ),
                    Expanded(
                      child: ListView.separated(
                        padding:
                            const EdgeInsets.fromLTRB(
                          18,
                          16,
                          18,
                          28,
                        ),
                        itemCount:
                            notifications.length,
                        separatorBuilder:
                            (_, __) =>
                                const SizedBox(
                          height: 11,
                        ),
                        itemBuilder:
                            (context, index) {
                          final document =
                              notifications[index];

                          return _buildNotificationCard(
                            notificationId:
                                document.id,
                            data:
                                document.data(),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryHeader({
    required int unreadCount,
  }) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(
        18,
        10,
        18,
        18,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Color(0xFFFFEEF1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              color: primaryRed,
              size: 23,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Activity updates',
                  style: TextStyle(
                    color: darkText,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  unreadCount == 0
                      ? 'You are all caught up'
                      : '$unreadCount unread ${unreadCount == 1 ? 'notification' : 'notifications'}',
                  style: const TextStyle(
                    color: greyText,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (unreadCount > 0)
            Container(
              constraints:
                  const BoxConstraints(
                minWidth: 28,
                minHeight: 28,
              ),
              alignment: Alignment.center,
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 8,
              ),
              decoration: const BoxDecoration(
                color: primaryRed,
                shape: BoxShape.circle,
              ),
              child: Text(
                unreadCount > 99
                    ? '99+'
                    : '$unreadCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard({
    required String notificationId,
    required Map<String, dynamic> data,
  }) {
    final String title =
        data['title']?.toString().trim() ??
            'Notification';

    final String message =
        data['message']?.toString().trim() ?? '';

    final String type =
        data['type']
                ?.toString()
                .toLowerCase()
                .trim() ??
            'general';

    final String referenceId = notificationReference(data);

    final bool isRead =
        data['isRead'] == true;

    final DateTime createdAt =
        _getDate(
      data['createdAt'],
    );

    return Dismissible(
      key: ValueKey(notificationId),
      direction:
          DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding:
            const EdgeInsets.only(
          right: 22,
        ),
        decoration: BoxDecoration(
          color: primaryRed,
          borderRadius:
              BorderRadius.circular(18),
        ),
        child: const Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              Icons.delete_outline_rounded,
              color: Colors.white,
              size: 26,
            ),
            SizedBox(height: 3),
            Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
      onDismissed: (_) async {
        try {
          await _notificationService
              .deleteNotification(
            notificationId,
          );
        } catch (_) {}
      },
      child: Material(
        color: isRead
            ? Colors.white
            : const Color(0xFFFFF4F6),
        borderRadius:
            BorderRadius.circular(18),
        child: InkWell(
          borderRadius:
              BorderRadius.circular(18),
          onTap: _isOpeningNotification
              ? null
              : () => _handleNotificationTap(
                    notificationId:
                        notificationId,
                    data: data,
                  ),
          child: Container(
            padding:
                const EdgeInsets.all(15),
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(18),
              border: Border.all(
                color: isRead
                    ? borderColor
                    : const Color(
                        0xFFFFCCD5,
                      ),
              ),
            ),
            child: Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                _buildTypeIcon(
                  type: type,
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: TextStyle(
                                color: darkText,
                                fontSize: 15,
                                fontWeight:
                                    isRead
                                        ? FontWeight
                                            .w700
                                        : FontWeight
                                            .w800,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          if (!isRead)
                            Container(
                              width: 9,
                              height: 9,
                              margin:
                                  const EdgeInsets.only(
                                top: 5,
                              ),
                              decoration:
                                  const BoxDecoration(
                                color:
                                    primaryRed,
                                shape:
                                    BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      if (message.isNotEmpty) ...[
                        const SizedBox(
                          height: 6,
                        ),
                        Text(
                          message,
                          maxLines: 3,
                          overflow:
                              TextOverflow
                                  .ellipsis,
                          style:
                              const TextStyle(
                            color: greyText,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ],
                      const SizedBox(
                        height: 9,
                      ),
                      Row(
                        children: [
                          Text(
                            _formatTime(
                              createdAt,
                            ),
                            style:
                                const TextStyle(
                              color: Color(
                                0xFFAAAAAA,
                              ),
                              fontSize: 11,
                            ),
                          ),
                          const Spacer(),
                          if (_canOpen(
                            type,
                            referenceId,
                          ))
                            const Row(
                              children: [
                                Text(
                                  'View',
                                  style:
                                      TextStyle(
                                    color:
                                        primaryRed,
                                    fontSize: 11,
                                    fontWeight:
                                        FontWeight
                                            .w700,
                                  ),
                                ),
                                SizedBox(
                                  width: 3,
                                ),
                                Icon(
                                  Icons
                                      .arrow_forward_ios_rounded,
                                  color:
                                      primaryRed,
                                  size: 11,
                                ),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleNotificationTap({
    required String notificationId,
    required Map<String, dynamic> data,
  }) async {
    if (_isOpeningNotification) return;

    setState(() {
      _isOpeningNotification = true;
    });

    final bool isRead =
        data['isRead'] == true;

    final String type =
        data['type']
                ?.toString()
                .toLowerCase()
                .trim() ??
            'general';

    final String referenceId = notificationReference(data);

    try {
      if (!isRead) {
        await _notificationService
            .markAsRead(
          notificationId,
        );
      }

      if (!mounted) return;

      switch (notificationDestination(type, referenceId)) {
        case NotificationDestination.chat:
          if (referenceId.isNotEmpty) {
            await _openChat(
              referenceId,
            );
          }
          break;

        case NotificationDestination.review:
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  RateReviewScreen(initialBookingId: referenceId.isEmpty ? null : referenceId),
            ),
          );
          break;

        case NotificationDestination.exchange:
          if (referenceId.isNotEmpty) {
            final doc = await FirebaseFirestore.instance.collection('exchange_requests')
                .doc(referenceId).get();
            if (!mounted) return;
            final sender = doc.data()?['senderId'];
            await Navigator.push(context, MaterialPageRoute(builder: (_) =>
              sender == FirebaseAuth.instance.currentUser?.uid
                ? ExchangeStatusScreen(exchangeRequestId: referenceId)
                : IncomingExchangeRequestScreen(exchangeRequestId: referenceId),
            ));
          }
          break;
        case NotificationDestination.providerRequest:
          if (referenceId.isNotEmpty) {
            await Navigator.push(context,
              MaterialPageRoute(builder: (_) => RequestDetailsScreen(requestId: referenceId)));
          }
          break;
        case NotificationDestination.booking:
          await Navigator.push(context, MaterialPageRoute(builder: (_) =>
            referenceId.isNotEmpty ? BookingDetailsScreen(bookingId: referenceId)
              : const TransactionHistoryScreen(),
          ));
          break;

        case NotificationDestination.myBookings:
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const MyBookingsScreen()));
          break;
        case NotificationDestination.transactions:
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const TransactionHistoryScreen()));
          break;
        case NotificationDestination.none:
          break;
      }
    } catch (error) {
      if (!mounted) return;

      _showFeatureMessage(
        error
            .toString()
            .replaceFirst(
              'Exception: ',
              '',
            ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isOpeningNotification =
              false;
        });
      }
    }
  }

  Future<void> _openChat(
    String chatId,
  ) async {
    final document =
        await FirebaseFirestore.instance
            .collection('chats')
            .doc(chatId)
            .get();

    if (!document.exists) {
      throw Exception(
        'This conversation is no longer available.',
      );
    }

    final data =
        document.data() ?? {};

    final dynamic rawParticipants =
        data['participants'];

    final List<String> participants =
        rawParticipants is List
            ? rawParticipants
                .map(
                  (item) =>
                      item.toString(),
                )
                .toList()
            : [];

    final String currentUserId =
        _chatService.currentUserId;

    final String otherUserId =
        participants.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );

    if (otherUserId.isEmpty) {
      throw Exception(
        'Chat participant information is missing.',
      );
    }

    String otherUserName =
        'Rent Lanka User';

    final dynamic rawNames =
        data['participantNames'];

    if (rawNames is Map) {
      final String storedName =
          rawNames[otherUserId]
                  ?.toString()
                  .trim() ??
              '';

      if (storedName.isNotEmpty) {
        otherUserName =
            storedName;
      }
    }

    if (otherUserName ==
        'Rent Lanka User') {
      otherUserName =
          await _chatService
              .getUserDisplayName(
        otherUserId,
      );
    }

    if (!mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          chatId: chatId,
          chatName: otherUserName,
          otherUserId: otherUserId,
          equipmentName: ChatContext.fromData(data).equipmentName,
          contextType: ChatContext.fromData(data).contextType,
        ),
      ),
    );
  }

  

  void _showFeatureMessage(
    String message,
  ) {
    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar();

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  Widget _buildTypeIcon({
    required String type,
  }) {
    return Container(
      width: 50,
      height: 50,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color:
            _iconBackground(type),
        borderRadius:
            BorderRadius.circular(14),
      ),
      child: Icon(
        _iconForType(type),
        color: _iconColor(type),
        size: 24,
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 39,
              backgroundColor:
                  Color(0xFFFFEEF1),
              child: Icon(
                Icons
                    .notifications_none_rounded,
                size: 36,
                color: primaryRed,
              ),
            ),
            SizedBox(height: 18),
            Text(
              'No notifications yet',
              style: TextStyle(
                color: darkText,
                fontSize: 18,
                fontWeight:
                    FontWeight.w800,
              ),
            ),
            SizedBox(height: 7),
            Text(
              'Exchange, message, booking and account updates will appear here.',
              textAlign:
                  TextAlign.center,
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

  Widget _buildErrorState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: primaryRed,
              size: 52,
            ),
            SizedBox(height: 14),
            Text(
              'Unable to load notifications',
              style: TextStyle(
                color: darkText,
                fontSize: 17,
                fontWeight:
                    FontWeight.w800,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Please try again in a moment.',
              textAlign:
                  TextAlign.center,
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

  bool _canOpen(String type, String referenceId) =>
      notificationDestination(type, referenceId) != NotificationDestination.none;

  static DateTime _getDate(
    dynamic value,
  ) {
    if (value is Timestamp) {
      return value
          .toDate()
          .toLocal();
    }

    return DateTime
        .fromMillisecondsSinceEpoch(
      0,
    );
  }

  static String _formatTime(
    DateTime date,
  ) {
    if (date.millisecondsSinceEpoch ==
        0) {
      return '';
    }

    final DateTime now =
        DateTime.now();

    final DateTime today =
        DateTime(
      now.year,
      now.month,
      now.day,
    );

    final DateTime itemDate =
        DateTime(
      date.year,
      date.month,
      date.day,
    );

    final int days =
        today
            .difference(itemDate)
            .inDays;

    if (days == 0) {
      return _clockTime(date);
    }

    if (days == 1) {
      return 'Yesterday';
    }

    if (days < 7) {
      const weekdays = [
        'Mon',
        'Tue',
        'Wed',
        'Thu',
        'Fri',
        'Sat',
        'Sun',
      ];

      return weekdays[
          date.weekday - 1];
    }

    return '${date.day}/${date.month}/${date.year}';
  }

  static String _clockTime(
    DateTime date,
  ) {
    int hour = date.hour;

    final String period =
        hour >= 12
            ? 'PM'
            : 'AM';

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

  static IconData _iconForType(
    String type,
  ) {
    switch (type) {
      case 'exchange':
        return Icons
            .swap_horiz_rounded;

      case 'message':
        return Icons
            .chat_bubble_outline_rounded;

      case 'booking':
        return Icons
            .calendar_month_outlined;

      case 'payment':
        return Icons
            .payments_outlined;

      case 'review':
        return Icons
            .star_outline_rounded;

      default:
        return Icons
            .notifications_none_rounded;
    }
  }

  static Color _iconColor(
    String type,
  ) {
    switch (type) {
      case 'exchange':
        return primaryRed;

      case 'message':
        return const Color(
          0xFF3578D4,
        );

      case 'booking':
        return const Color(
          0xFF8454C7,
        );

      case 'payment':
        return const Color(
          0xFF24945E,
        );

      case 'review':
        return const Color(
          0xFFE59B13,
        );

      default:
        return primaryRed;
    }
  }

  static Color _iconBackground(
    String type,
  ) {
    switch (type) {
      case 'exchange':
        return const Color(
          0xFFFFEEF1,
        );

      case 'message':
        return const Color(
          0xFFEDF4FF,
        );

      case 'booking':
        return const Color(
          0xFFF3EDFF,
        );

      case 'payment':
        return const Color(
          0xFFEAF8F1,
        );

      case 'review':
        return const Color(
          0xFFFFF6E5,
        );

      default:
        return const Color(
          0xFFFFEEF1,
        );
    }
  }
}