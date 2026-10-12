import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/notification_service.dart';
import '../services/unread_notification_count.dart';

class NotificationIconWithBadge extends StatefulWidget {
  const NotificationIconWithBadge({
    super.key,
    this.icon = Icons.notifications_none_rounded,
    this.color,
    this.size = 24,
    this.unreadCount,
    this.countSource,
    this.dotOnly = false,
    this.badgeColor = const Color(0xFFED1235),
  });
  final bool dotOnly;
  final Color badgeColor;
  final int? unreadCount;
  final IconData icon;
  final Color? color;
  final double size;
  final UnreadNotificationCount? countSource;
  @override
  State<NotificationIconWithBadge> createState() =>
      _NotificationIconWithBadgeState();
}

class _NotificationIconWithBadgeState extends State<NotificationIconWithBadge> {
  static UnreadNotificationCount? _shared;
  UnreadNotificationCount? _source;
  UnreadNotificationCount get _defaultSource =>
      _shared ??= UnreadNotificationCount(
        userIds: FirebaseAuth.instance.authStateChanges().map(
          (user) => user?.uid,
        ),
        watchCount: (_) => NotificationService().watchUnreadNotificationCount(),
      );
  @override
  void initState() {
    super.initState();
    if (widget.unreadCount == null) {
      _source = widget.countSource ?? _defaultSource;
      _source!.retain();
    }
  }

  @override
  void didUpdateWidget(NotificationIconWithBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.countSource != widget.countSource ||
        oldWidget.unreadCount != widget.unreadCount) {
      _source?.release();
      _source = null;
      if (widget.unreadCount == null) {
        _source = widget.countSource ?? _defaultSource;
        _source!.retain();
      }
    }
  }

  @override
  void dispose() {
    _source?.release();
    _source = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.unreadCount != null) return _buildIcon(widget.unreadCount!);
    return ValueListenableBuilder<int>(
      valueListenable: _source!,
      builder: (context, count, child) => _buildIcon(count),
    );
  }

  Widget _buildIcon(int count) => Semantics(
    label: count > 0 ? '$count unread notifications' : 'Notifications',
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(widget.icon, color: widget.color, size: widget.size),
        if (count > 0)
          Positioned(
            top: widget.dotOnly ? -4 : -6,
            right: widget.dotOnly ? -3 : -8,
            child: IgnorePointer(
              child: widget.dotOnly
                  ? Container(
                      key: const ValueKey('notification-unread-dot'),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: widget.badgeColor,
                        shape: BoxShape.circle,
                      ),
                    )
                  : Container(
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: widget.badgeColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        count > 99 ? '99+' : '$count',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          height: 1.2,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
            ),
          ),
      ],
    ),
  );
}
