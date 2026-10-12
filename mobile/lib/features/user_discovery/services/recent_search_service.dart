import 'package:shared_preferences/shared_preferences.dart';

class RecentSearchService {
  static const storageKey = 'rent_lanka.recent_searches.v1';
  static const maximumItems = 10;
  static final instance = RecentSearchService();
  Future<void> _pendingWrite = Future.value();

  static List<String> normalize(Iterable<String> values) {
    final seen = <String>{};
    return values
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty && seen.add(value.toLowerCase()))
        .take(maximumItems)
        .toList();
  }

  static List<String> add(List<String> current, String query) {
    if (query.trim().isEmpty) return List.of(current);
    return normalize([query, ...current]);
  }

  Future<List<String>> load() async {
    await _pendingWrite;
    final preferences = await SharedPreferences.getInstance();
    return normalize(preferences.getStringList(storageKey) ?? []);
  }

  Future<void> save(List<String> values) {
    final snapshot = normalize(values);
    final write = _pendingWrite.then((_) async {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setStringList(storageKey, snapshot);
    });
    // Keep later writes usable even when one local write fails.
    _pendingWrite = write.catchError((Object error) {});
    return write;
  }
}
