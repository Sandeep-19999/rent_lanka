import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/notification_service.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  static const Color primaryRed = Color(0xFFED1235);

  static const Color darkText = Color(0xFF242424);

  static const Color greyText = Color(0xFF929292);

  @override
  Widget build(BuildContext context) {
    final NotificationService service = NotificationService();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              children: [
                _buildHeader(context),

                const SizedBox(height: 14),

                Expanded(
                  child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: service.watchMyNotifications(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              'Unable to load notifications.\n${snapshot.error}',
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

                      final notifications = [...?snapshot.data?.docs];

                      notifications.sort((first, second) {
                        final DateTime firstDate = _getDate(
                          first.data()['createdAt'],
                        );

                        final DateTime secondDate = _getDate(
                          second.data()['createdAt'],
                        );

                        return secondDate.compareTo(firstDate);
                      });

                      if (notifications.isEmpty) {
                        return _buildEmptyState();
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                        itemCount: notifications.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final document = notifications[index];

                          final data = document.data();

                          return _buildNotificationCard(
                            context: context,
                            service: service,
                            notificationId: document.id,
                            data: data,
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
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
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
            'Notifications',
            style: TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.w800,
              color: darkText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard({
    required BuildContext context,
    required NotificationService service,
    required String notificationId,
    required Map<String, dynamic> data,
  }) {
    final String title = data['title']?.toString() ?? 'Notification';

    final String message = data['message']?.toString() ?? '';

    final String type = data['type']?.toString().toLowerCase() ?? 'general';

    final bool isRead = data['isRead'] == true;

    final DateTime createdAt = _getDate(data['createdAt']);

    return Dismissible(
      key: ValueKey(notificationId),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: primaryRed,
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      onDismissed: (_) async {
        try {
          await service.deleteNotification(notificationId);
        } catch (_) {}
      },
      child: Material(
        color: isRead ? Colors.white : const Color(0xFFFFF1F3),
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () async {
            if (!isRead) {
              try {
                await service.markAsRead(notificationId);
              } catch (_) {}
            }
          },
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: isRead
                    ? const Color(0xFFE8E8E8)
                    : const Color(0xFFFFCBD3),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _iconBackground(type),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(
                    _iconForType(type),
                    color: _iconColor(type),
                    size: 24,
                  ),
                ),

                const SizedBox(width: 13),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: isRead
                                    ? FontWeight.w600
                                    : FontWeight.w800,
                                color: darkText,
                              ),
                            ),
                          ),

                          if (!isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: primaryRed,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 5),

                      Text(
                        message,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.35,
                          color: greyText,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        _formatTime(createdAt),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFFAAAAAA),
                        ),
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

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.notifications_none, size: 58, color: Color(0xFFB5B5B5)),

            SizedBox(height: 14),

            Text(
              'No notifications yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: darkText,
              ),
            ),

            SizedBox(height: 6),

            Text(
              'Booking, exchange and message updates will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: greyText),
            ),
          ],
        ),
      ),
    );
  }

  static DateTime _getDate(dynamic value) {
    if (value is Timestamp) {
      return value.toDate().toLocal();
    }

    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  static String _formatTime(DateTime date) {
    if (date.millisecondsSinceEpoch == 0) {
      return '';
    }

    final DateTime now = DateTime.now();

    final DateTime today = DateTime(now.year, now.month, now.day);

    final DateTime itemDate = DateTime(date.year, date.month, date.day);

    final int days = today.difference(itemDate).inDays;

    if (days == 0) {
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

    if (days == 1) {
      return 'Yesterday';
    }

    return '${date.day}/${date.month}/${date.year}';
  }

  static IconData _iconForType(String type) {
    switch (type) {
      case 'exchange':
        return Icons.swap_horiz_rounded;

      case 'message':
        return Icons.chat_bubble_outline;

      case 'booking':
        return Icons.calendar_month_outlined;

      case 'payment':
        return Icons.payments_outlined;

      case 'review':
        return Icons.star_outline;

      default:
        return Icons.notifications_none;
    }
  }

  static Color _iconColor(String type) {
    switch (type) {
      case 'exchange':
        return primaryRed;

      case 'message':
        return const Color(0xFF1565FF);

      case 'booking':
        return const Color(0xFF8A3FFC);

      case 'payment':
        return const Color(0xFF00A86B);

      case 'review':
        return const Color(0xFFFFA000);

      default:
        return primaryRed;
    }
  }

  static Color _iconBackground(String type) {
    switch (type) {
      case 'exchange':
        return const Color(0xFFFFEDF0);

      case 'message':
        return const Color(0xFFEAF1FF);

      case 'booking':
        return const Color(0xFFF1E9FF);

      case 'payment':
        return const Color(0xFFE5F8EF);

      case 'review':
        return const Color(0xFFFFF4DC);

      default:
        return const Color(0xFFFFEDF0);
    }
  }
}
