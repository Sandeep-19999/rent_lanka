import 'package:flutter/material.dart';
import 'package:rent_lanka_mobile/features/user_discovery/screens/search/search_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rent_lanka_mobile/features/user_discovery/services/recent_search_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));
  test('new history is empty, without static sample searches', () async {
    expect(await RecentSearchService().load(), isEmpty);
  });
  test('newest first, trimmed, case insensitive duplicates move to top', () {
    var rows = RecentSearchService.add([], 'helmet');
    rows = RecentSearchService.add(rows, 'cycling');
    rows = RecentSearchService.add(rows, ' Helmet ');
    expect(rows, ['Helmet', 'cycling']);
    expect(RecentSearchService.add(rows, '   '), rows);
    expect(RecentSearchService.add(rows, ''), rows);
    expect(
      RecentSearchService.normalize(List.generate(12, (i) => 'query $i'))
          .length,
      10,
    );
  });
  test(
    'saved history loads and removal survives a new service instance',
    () async {
      SharedPreferences.setMockInitialValues({
        RecentSearchService.storageKey: ['helmet', 'cycling', 'HELMET', ' '],
      });
      final service = RecentSearchService();
      expect(await service.load(), ['helmet', 'cycling']);
      await service.save(['cycling']);
      expect(await RecentSearchService().load(), ['cycling']);
    },
  );
  testWidgets(
    'Search loads saved rows and X removal stays removed on reopening',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        RecentSearchService.storageKey: ['helmet', 'cycling'],
      });
      await tester.pumpWidget(const MaterialApp(home: SearchScreen()));
      await tester.pumpAndSettle();
      expect(find.text('helmet'), findsOneWidget);
      expect(find.text('cycling'), findsOneWidget);
      final row = find.ancestor(
        of: find.text('helmet'),
        matching: find.byType(ListTile),
      );
      await tester.tap(
        find.descendant(of: row, matching: find.byType(IconButton)),
      );
      await tester.pumpAndSettle();
      expect(find.text('helmet'), findsNothing);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(const MaterialApp(home: SearchScreen()));
      await tester.pumpAndSettle();
      expect(find.text('helmet'), findsNothing);
      expect(find.text('cycling'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    },
  );
  test('rapid writes persist the latest snapshot in order', () async {
    final service = RecentSearchService();
    await Future.wait([
      service.save(['helmet']),
      service.save(['cycling', 'helmet']),
      service.save(['cycling']),
    ]);
    expect(await RecentSearchService().load(), ['cycling']);
  });
}
