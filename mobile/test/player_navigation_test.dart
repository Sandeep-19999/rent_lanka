import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rent_lanka_mobile/navigation/player_bottom_navigation.dart';
import 'package:rent_lanka_mobile/features/user_discovery/screens/home/home_screen.dart';
import 'package:rent_lanka_mobile/features/user_discovery/screens/search/search_screen.dart';
import 'package:rent_lanka_mobile/features/booking_payment/screens/booking/my_bookings_screen.dart';
import 'package:rent_lanka_mobile/features/exchange_messaging_profile/screens/messages_screen.dart';
import 'package:rent_lanka_mobile/features/exchange_messaging_profile/screens/profile_screen.dart';

class RouteTracker extends NavigatorObserver {
  final routes = <Route<dynamic>>[];
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    routes.add(route);
  }
  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    routes.remove(route);
  }
  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    routes.remove(route);
  }
}

void main() {
  test('each tab reuses the existing feature screen', () {
    expect(playerScreenForTab(0), isA<HomeScreen>());
    expect(playerScreenForTab(1), isA<SearchScreen>());
    expect(playerScreenForTab(2), isA<MyBookingsScreen>());
    expect(playerScreenForTab(3), isA<MessagesScreen>());
    expect(playerScreenForTab(4), isA<ProfileScreen>());
    expect(() => playerScreenForTab(5), throwsArgumentError);
  });

  testWidgets('tab selection matches every supplied index', (tester) async {
    for (var index = 0; index < 5; index++) {
      await tester.pumpWidget(MaterialApp(home: Scaffold(
        bottomNavigationBar: PlayerBottomNavigation(currentIndex: index),
      )));
      expect(tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar))
        .currentIndex, index);
    }
  });

  testWidgets('repeated Search taps and Home returns do not grow the stack',
    (tester) async {
      final observer = RouteTracker();
      await tester.pumpWidget(MaterialApp(
        navigatorObservers: [observer],
        home: const Scaffold(
          body: Text('Home root'),
          bottomNavigationBar: PlayerBottomNavigation(currentIndex: 0),
        ),
      ));
      for (var cycle = 0; cycle < 3; cycle++) {
        await tester.tap(find.text('Search').last);
        await tester.pumpAndSettle();
        expect(find.byType(SearchScreen), findsOneWidget);
        expect(observer.routes.length, 2);
        await tester.tap(find.text('Search').last);
        await tester.pumpAndSettle();
        expect(observer.routes.length, 2);
        expect(tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar))
          .currentIndex, 1);
        await tester.tap(find.text('Home').last);
        await tester.pumpAndSettle();
        expect(find.text('Home root'), findsOneWidget);
        expect(observer.routes.length, 1);
      }
    });
}
