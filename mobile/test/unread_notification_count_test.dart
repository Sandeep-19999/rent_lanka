import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rent_lanka_mobile/features/exchange_messaging_profile/services/unread_notification_count.dart';
import 'package:rent_lanka_mobile/features/exchange_messaging_profile/widgets/notification_icon_with_badge.dart';

void main() {
  test(
    'unread calculation isolates user and preserves legacy missing read state',
    () {
      final rows = <Map<String, dynamic>>[
        {'userId': 'player', 'isRead': false},
        {'userId': 'player', 'isRead': true},
        {'userId': 'provider', 'isRead': false},
        {'userId': 'player'},
      ];
      expect(unreadNotificationCount(rows, 'player'), 2);
      rows[0]['isRead'] = true;
      expect(unreadNotificationCount(rows, 'player'), 1);
      rows[3]['isRead'] = true;
      expect(unreadNotificationCount(rows, 'player'), 0);
      expect(unreadNotificationCount(rows, 'provider'), 1);
    },
  );
  test(
    'shared source switches users, hides errors, and detaches last listener',
    () async {
      final auth = StreamController<String?>();
      final player = StreamController<int>();
      final provider = StreamController<int>();
      var calls = 0;
      final source = UnreadNotificationCount(
        userIds: auth.stream,
        watchCount: (uid) {
          calls++;
          return uid == 'player' ? player.stream : provider.stream;
        },
      );
      source.retain();
      source.retain();
      auth.add('player');
      await Future<void>.delayed(Duration.zero);
      player.add(5);
      await Future<void>.delayed(Duration.zero);
      expect(source.value, 5);
      expect(calls, 1);
      source.release();
      expect(player.hasListener, true);
      auth.add('provider');
      await Future<void>.delayed(Duration.zero);
      expect(source.value, 0);
      expect(player.hasListener, false);
      provider.add(3);
      await Future<void>.delayed(Duration.zero);
      expect(source.value, 3);
      provider.addError(StateError('offline'));
      await Future<void>.delayed(Duration.zero);
      expect(source.value, 0);
      provider.add(1);
      await Future<void>.delayed(Duration.zero);
      expect(source.value, 1);
      auth.add(null);
      await Future<void>.delayed(Duration.zero);
      expect(source.value, 0);
      source.release();
      expect(auth.hasListener, false);
      source.dispose();
      await auth.close();
      await player.close();
      await provider.close();
    },
  );
  for (final count in [0, 1, 5, 12, 100]) {
    testWidgets('badge renders count $count with preserved button tap', (
      tester,
    ) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IconButton(
              onPressed: () => tapped = true,
              icon: NotificationIconWithBadge(unreadCount: count),
            ),
          ),
        ),
      );
      if (count == 0) {
        expect(find.byType(Text), findsNothing);
      } else {
        expect(find.text(count > 99 ? '99+' : '$count'), findsOneWidget);
      }
      await tester.tap(find.byType(IconButton));
      expect(tapped, true);
    });
  }
  testWidgets(
    'Home dot follows unread stream and preserves notification navigation',
    (tester) async {
      final auth = StreamController<String?>();
      final counts = StreamController<int>();
      final source = UnreadNotificationCount(
        userIds: auth.stream,
        watchCount: (_) => counts.stream,
      );
      const dot = ValueKey('notification-unread-dot');
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: IconButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        const Scaffold(body: Text('Notifications destination')),
                  ),
                ),
                icon: NotificationIconWithBadge(
                  dotOnly: true,
                  badgeColor: const Color(0xFFED1C24),
                  size: 22,
                  countSource: source,
                ),
              ),
            ),
          ),
        ),
      );
      expect(find.byKey(dot), findsNothing);
      final initialButtonRect = tester.getRect(find.byType(IconButton));
      final initialBellRect = tester.getRect(
        find.byIcon(Icons.notifications_none_rounded),
      );
      auth.add('player');
      await tester.pumpAndSettle();
      counts.add(0);
      await tester.pumpAndSettle();
      expect(find.byKey(dot), findsNothing);
      counts.add(2);
      await tester.pumpAndSettle();
      expect(find.byKey(dot), findsOneWidget);
      expect(find.text('2'), findsNothing);
      expect(tester.getRect(find.byType(IconButton)), initialButtonRect);
      expect(
        tester.getRect(find.byIcon(Icons.notifications_none_rounded)),
        initialBellRect,
      );
      expect(
        tester.widget<Icon>(find.byIcon(Icons.notifications_none_rounded)).size,
        22,
      );
      final container = tester.widget<Container>(find.byKey(dot));
      expect(
        (container.decoration as BoxDecoration).color,
        const Color(0xFFED1C24),
      );
      expect(tester.getSize(find.byKey(dot)), const Size(8, 8));
      counts.add(1);
      await tester.pumpAndSettle();
      expect(find.byKey(dot), findsOneWidget);
      counts.add(0);
      await tester.pumpAndSettle();
      expect(find.byKey(dot), findsNothing);
      counts.add(1);
      await tester.pumpAndSettle();
      expect(find.byKey(dot), findsOneWidget);
      counts.addError(StateError('offline'));
      await tester.pumpAndSettle();
      expect(find.byKey(dot), findsNothing);
      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();
      expect(find.text('Notifications destination'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      source.dispose();
      await tester.runAsync(() async {
        await auth.close();
        await counts.close();
      });
    },
  );
  testWidgets('initial unread snapshot displays Home dot before any bell tap', (
    tester,
  ) async {
    var tapped = false;
    final source = UnreadNotificationCount(
      userIds: Stream.value('current-user'),
      watchCount: (_) => Stream.value(3),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: IconButton(
            onPressed: () => tapped = true,
            icon: NotificationIconWithBadge(
              dotOnly: true,
              size: 22,
              countSource: source,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tapped, false);
    expect(
      find.byKey(const ValueKey('notification-unread-dot')),
      findsOneWidget,
    );
    expect(find.text('3'), findsNothing);
    final position = tester.widget<Positioned>(find.byType(Positioned));
    expect(position.top, -4);
    expect(position.right, -3);
    await tester.pumpWidget(const SizedBox());
    source.dispose();
  });
  testWidgets('multiple player/provider badges share and update one listener', (
    tester,
  ) async {
    final auth = StreamController<String?>();
    final counts = StreamController<int>();
    var calls = 0;
    final source = UnreadNotificationCount(
      userIds: auth.stream,
      watchCount: (_) {
        calls++;
        return counts.stream;
      },
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Row(
          children: [
            NotificationIconWithBadge(countSource: source),
            NotificationIconWithBadge(countSource: source),
          ],
        ),
      ),
    );
    auth.add('same-user');
    await tester.pumpAndSettle();
    counts.add(4);
    await tester.pumpAndSettle();
    expect(calls, 1);
    expect(find.text('4'), findsNWidgets(2));
    counts.add(3);
    await tester.pumpAndSettle();
    expect(find.text('3'), findsNWidgets(2));
    counts.add(0);
    await tester.pumpAndSettle();
    expect(find.text('3'), findsNothing);
    await tester.pumpWidget(const SizedBox());
    expect(auth.hasListener, false);
    source.dispose();
    await tester.runAsync(() async {
      await auth.close();
      await counts.close();
    });
  });
}
