import 'dart:async';

import 'package:flutter/foundation.dart';

/// One auth subscription and one user-scoped listener shared by mounted badges.
class UnreadNotificationCount extends ValueNotifier<int> {
  UnreadNotificationCount({required this.userIds, required this.watchCount})
    : super(0);
  final Stream<String?> userIds;
  final Stream<int> Function(String uid) watchCount;
  StreamSubscription<String?>? _authSubscription;
  StreamSubscription<int>? _countSubscription;
  int _references = 0;
  int _generation = 0;

  void retain() {
    if (_references++ > 0) return;
    _authSubscription = userIds.distinct().listen(
      _switchUser,
      onError: (Object error) => _switchUser(null),
    );
  }

  void _switchUser(String? uid) {
    final generation = ++_generation;
    _countSubscription?.cancel();
    _countSubscription = null;
    value = 0;
    if (uid == null) return;
    try {
      _countSubscription = watchCount(uid).listen(
        (count) {
          if (generation == _generation) value = count < 0 ? 0 : count;
        },
        onError: (Object error) {
          if (generation == _generation) value = 0;
        },
      );
    } catch (_) {
      value = 0;
    }
  }

  void release() {
    if (_references == 0 || --_references > 0) return;
    ++_generation;
    _authSubscription?.cancel();
    _countSubscription?.cancel();
    _authSubscription = null;
    _countSubscription = null;
    value = 0;
  }

  @override
  void dispose() {
    ++_generation;
    _authSubscription?.cancel();
    _countSubscription?.cancel();
    super.dispose();
  }
}

int unreadNotificationCount(
  Iterable<Map<String, dynamic>> notifications,
  String uid,
) => notifications
    .where((data) => data['userId'] == uid && data['isRead'] != true)
    .length;
