import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/notification_model.dart';
import '../services/notification_service.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  static const Color primaryRed = Color(0xFFED1235);

  static const Color darkText = Color(0xFF242424);

  static const Color greyText = Color(0xFF8F8F8F);

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                  child: _buildHeader(context),
                ),

                const SizedBox(height: 25),

                Expanded(
                  child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: service.watchNotifications(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Center(
                          child: Text('Unable to load notifications.'),
                        );
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(color: primaryRed),
                        );
                      }

                      final documents = snapshot.data?.docs ?? [];

                      final notifications = documents
                          .map(AppNotificationModel.fromDocument)
                          .toList();

                      notifications.sort((a, b) {
                        final aDate = a.createdAt ?? DateTime(1970);

                        final bDate = b.createdAt ?? DateTime(1970);

                        return bDate.compareTo(aDate);
                      });

                      if (notifications.isEmpty) {
                        return const Center(
                          child: Text(
                            'No notifications yet.',
                            style: TextStyle(color: greyText),
                          ),
                        );
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                        itemCount: notifications.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          final notification = notifications[index];

                          return Dismissible(
                            key: ValueKey(notification.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 25),
                              decoration: BoxDecoration(
                                color: primaryRed,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                            onDismissed: (_) {
                              service.deleteNotification(notification.id);
                            },
                            child: _buildNotificationCard(
                              context: context,
                              service: service,
                              notification: notification,
                            ),
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
    return Row(
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
          'Notifications',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w800,
            color: darkText,
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationCard({
    required BuildContext context,
    required NotificationService service,
    required AppNotificationModel notification,
  }) {
    final style = _getNotificationStyle(notification.type);

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () async {
        if (!notification.isRead) {
          await service.markAsRead(notification.id);
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
        decoration: BoxDecoration(
          color: notification.isRead ? Colors.white : const Color(0xFFFFF4F5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: notification.isRead ? const Color(0xFFE0E0E0) : primaryRed,
            width: notification.isRead ? 1.2 : 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: style.backgroundColor,
                shape: BoxShape.circle,
              ),
              child: Icon(style.icon, color: style.iconColor, size: 19),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: darkText,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    notification.message,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.25,
                      color: greyText,
                    ),
                  ),
                ],
              ),
            ),

            if (!notification.isRead) ...[
              const SizedBox(width: 8),
              Container(
                width: 9,
                height: 9,
                decoration: const BoxDecoration(
                  color: primaryRed,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  _NotificationStyle _getNotificationStyle(String type) {
    switch (type) {
      case 'request':
        return const _NotificationStyle(
          icon: Icons.check,
          backgroundColor: Color(0xFFE5F7EA),
          iconColor: Color(0xFF44B663),
        );

      case 'payment':
        return const _NotificationStyle(
          icon: Icons.attach_money_rounded,
          backgroundColor: Color(0xFFE5F7EA),
          iconColor: Color(0xFF44B663),
        );

      case 'return':
        return const _NotificationStyle(
          icon: Icons.access_time_rounded,
          backgroundColor: Color(0xFFFFF6DA),
          iconColor: Color(0xFFFFB400),
        );

      case 'booking':
      default:
        return const _NotificationStyle(
          icon: Icons.check,
          backgroundColor: primaryRed,
          iconColor: Colors.white,
        );
    }
  }
}

class _NotificationStyle {
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;

  const _NotificationStyle({
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
  });
}
