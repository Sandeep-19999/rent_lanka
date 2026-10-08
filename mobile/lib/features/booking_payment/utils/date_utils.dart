/// Date helpers shared by the booking screens.
///
/// Dates are stored in Firestore as `yyyy-MM-dd` keys, the same format the
/// provider Availability screen uses for `unavailableDates`.
class AppDates {
  static const List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  static DateTime dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static String key(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  static DateTime? parseKey(String value) {
    final parsed = DateTime.tryParse(value);
    return parsed == null ? null : dateOnly(parsed);
  }

  /// Every day from [start] to [end], both inclusive.
  static List<DateTime> daysInRange(DateTime start, DateTime end) {
    final days = <DateTime>[];
    var current = dateOnly(start);
    final last = dateOnly(end);
    while (!current.isAfter(last)) {
      days.add(current);
      current = DateTime(current.year, current.month, current.day + 1);
    }
    return days;
  }

  /// Rental days counted inclusively, so a same-day rental is 1 day.
  static int rentalDays(DateTime start, DateTime end) =>
      daysInRange(start, end).length;

  /// e.g. `12 Oct 2026`
  static String pretty(DateTime date) =>
      '${date.day} ${_months[date.month - 1]} ${date.year}';

  /// Formats a stored `yyyy-MM-dd` key for display, falling back to the raw text.
  static String prettyKey(String value) {
    final date = parseKey(value);
    return date == null ? value : pretty(date);
  }

  static String prettyRange(String startKey, String endKey) =>
      startKey == endKey
          ? prettyKey(startKey)
          : '${prettyKey(startKey)} - ${prettyKey(endKey)}';
}

String formatLkr(double amount) => 'Rs. ${amount.toStringAsFixed(2)}';
