import 'package:flutter/material.dart';

import '../utils/date_utils.dart';
import 'booking_widgets.dart';

const Color _darkRed = Color(0xFFB00D28);
const Color _ink = Color(0xFF1C1C1E);

/// Sport-styled rental period picker shown as a bottom sheet.
///
/// Tap a start day, then an end day (or confirm straight away for a
/// one-day rental). Booked / blocked days are crossed out and a range
/// that would run across them is refused with a message.
Future<DateTimeRange?> showRentalDatePicker({
  required BuildContext context,
  required DateTime firstDate,
  required DateTime lastDate,
  required Set<String> unavailable,
  required int maxDays,
  DateTimeRange? initialRange,
  double? pricePerDay,
  String title = 'Pick your game days',
}) {
  return showModalBottomSheet<DateTimeRange>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _RentalDatePicker(
      firstDate: AppDates.dateOnly(firstDate),
      lastDate: AppDates.dateOnly(lastDate),
      unavailable: unavailable,
      maxDays: maxDays,
      initialRange: initialRange,
      pricePerDay: pricePerDay,
      title: title,
    ),
  );
}

class _RentalDatePicker extends StatefulWidget {
  final DateTime firstDate;
  final DateTime lastDate;
  final Set<String> unavailable;
  final int maxDays;
  final DateTimeRange? initialRange;
  final double? pricePerDay;
  final String title;

  const _RentalDatePicker({
    required this.firstDate,
    required this.lastDate,
    required this.unavailable,
    required this.maxDays,
    required this.initialRange,
    required this.pricePerDay,
    required this.title,
  });

  @override
  State<_RentalDatePicker> createState() => _RentalDatePickerState();
}

class _RentalDatePickerState extends State<_RentalDatePicker> {
  static const _weekdays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
  static const _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June', 'July',
    'August', 'September', 'October', 'November', 'December',
  ];
  static const _dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  DateTime? _start;
  DateTime? _end;
  String? _error;
  late DateTime _month;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialRange;
    if (initial != null) {
      _start = AppDates.dateOnly(initial.start);
      _end = AppDates.dateOnly(initial.end);
    }
    final focus = _start ?? widget.firstDate;
    _month = DateTime(focus.year, focus.month);
  }

  bool _isBlocked(DateTime day) => widget.unavailable.contains(AppDates.key(day));

  bool _isOutside(DateTime day) =>
      day.isBefore(widget.firstDate) || day.isAfter(widget.lastDate);

  bool get _canGoBack => _month.isAfter(
      DateTime(widget.firstDate.year, widget.firstDate.month));

  bool get _canGoForward =>
      !DateTime(_month.year, _month.month + 1).isAfter(widget.lastDate);

  void _changeMonth(int delta) {
    setState(() => _month = DateTime(_month.year, _month.month + delta));
  }

  void _onDayTap(DateTime day) {
    if (_isOutside(day) || _isBlocked(day)) return;

    setState(() {
      _error = null;
      // First tap, a fresh start after a full range, or a day before start.
      if (_start == null || _end != null || day.isBefore(_start!)) {
        _start = day;
        _end = null;
        return;
      }

      final days = AppDates.daysInRange(_start!, day);
      final blocked = days.where(_isBlocked).toList();
      if (blocked.isNotEmpty) {
        _error = '${AppDates.pretty(blocked.first)} is already booked. '
            'Pick dates without crossed-out days.';
        return;
      }
      if (days.length > widget.maxDays) {
        _error = 'Rentals can be at most ${widget.maxDays} days.';
        return;
      }
      _end = day;
    });
  }

  void _clear() => setState(() {
        _start = null;
        _end = null;
        _error = null;
      });

  void _confirm() {
    final start = _start;
    if (start == null) return;
    Navigator.pop(context, DateTimeRange(start: start, end: _end ?? start));
  }

  int get _selectedDays =>
      _start == null ? 0 : AppDates.rentalDays(_start!, _end ?? _start!);

  String get _instruction {
    if (_start == null) return 'Step 1 of 2 · Tap the day you pick up the gear';
    if (_end == null) {
      return 'Step 2 of 2 · Tap the day you return it '
          '(or confirm for a 1-day rental)';
    }
    return 'All set! Check your dates and confirm';
  }

  String _short(DateTime day) =>
      '${_dayNames[day.weekday - 1]}, ${day.day} ${_monthNames[day.month - 1].substring(0, 3)}';

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.94),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _header(),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: Column(
                children: [
                  _legend(),
                  const SizedBox(height: 14),
                  _monthBar(),
                  const SizedBox(height: 10),
                  _weekdayRow(),
                  const SizedBox(height: 6),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: _grid(key: ValueKey(_month)),
                  ),
                ],
              ),
            ),
          ),
          _footer(),
        ],
      ),
    );
  }

  // ---- Header: title, step hint and the START / END "scoreboard" ----

  Widget _header() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryRed, _darkRed],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Faint sport watermarks.
          Positioned(
            right: -18,
            top: -14,
            child: Icon(Icons.sports_soccer,
                size: 120, color: Colors.white.withValues(alpha: 0.10)),
          ),
          Positioned(
            right: 92,
            bottom: -26,
            child: Icon(Icons.sports_cricket,
                size: 84, color: Colors.white.withValues(alpha: 0.08)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 12, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white54,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.event_available, color: Colors.white, size: 26),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Close',
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    _instruction,
                    key: ValueKey(_instruction),
                    style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.3),
                  ),
                ),
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: _ScoreCard(
                          label: 'PICK UP',
                          value: _start == null ? 'Tap a day' : _short(_start!),
                          active: _start == null,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _selectedDays == 0
                                ? '—'
                                : '$_selectedDays ${_selectedDays == 1 ? 'DAY' : 'DAYS'}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: _ScoreCard(
                          label: 'RETURN',
                          value: _end != null
                              ? _short(_end!)
                              : _start != null
                                  ? 'Tap a day'
                                  : '—',
                          active: _start != null && _end == null,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _legend() {
    return Wrap(
      spacing: 14,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: const [
        _LegendItem(kind: _LegendKind.selected, label: 'Your dates'),
        _LegendItem(kind: _LegendKind.range, label: 'Rental days'),
        _LegendItem(kind: _LegendKind.booked, label: 'Booked'),
        _LegendItem(kind: _LegendKind.today, label: 'Today'),
      ],
    );
  }

  Widget _monthBar() {
    return Row(
      children: [
        _RoundIcon(
          icon: Icons.chevron_left,
          tooltip: 'Previous month',
          onTap: _canGoBack ? () => _changeMonth(-1) : null,
        ),
        Expanded(
          child: Text(
            '${_monthNames[_month.month - 1]} ${_month.year}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: _ink),
          ),
        ),
        _RoundIcon(
          icon: Icons.chevron_right,
          tooltip: 'Next month',
          onTap: _canGoForward ? () => _changeMonth(1) : null,
        ),
      ],
    );
  }

  Widget _weekdayRow() {
    return Row(
      children: [
        for (var i = 0; i < 7; i++)
          Expanded(
            child: Text(
              _weekdays[i],
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: i == 0 || i == 6 ? primaryRed : textGrey,
              ),
            ),
          ),
      ],
    );
  }

  Widget _grid({Key? key}) {
    final first = DateTime(_month.year, _month.month);
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    final leading = first.weekday % 7; // Sunday = 0
    final cells = leading + daysInMonth;
    final rows = (cells / 7).ceil();
    final today = AppDates.dateOnly(DateTime.now());
    final end = _end ?? _start;

    return Column(
      key: key,
      children: [
        for (var r = 0; r < rows; r++)
          Row(
            children: [
              for (var c = 0; c < 7; c++)
                Expanded(
                  child: Builder(builder: (_) {
                    final index = r * 7 + c - leading;
                    if (index < 0 || index >= daysInMonth) {
                      return const SizedBox(height: 46);
                    }
                    final day = DateTime(_month.year, _month.month, index + 1);
                    final isStart = _start != null && day == _start;
                    final isEnd = end != null && day == end;
                    final inRange = _start != null &&
                        end != null &&
                        !day.isBefore(_start!) &&
                        !day.isAfter(end);
                    return _DayCell(
                      day: day.day,
                      isStart: isStart,
                      isEnd: isEnd,
                      inRange: inRange,
                      isToday: day == today,
                      isBlocked: _isBlocked(day),
                      isOutside: _isOutside(day),
                      onTap: () => _onDayTap(day),
                    );
                  }),
                ),
            ],
          ),
      ],
    );
  }

  Widget _footer() {
    final price = widget.pricePerDay;
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 12, 20, 12 + MediaQuery.paddingOf(context).bottom),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_error != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: primaryRed.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: primaryRed, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _error!,
                      style: const TextStyle(color: primaryRed, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedDays == 0
                          ? 'No dates yet'
                          : '$_selectedDays day${_selectedDays == 1 ? '' : 's'} selected',
                      style: const TextStyle(fontWeight: FontWeight.w800, color: _ink),
                    ),
                    if (price != null && _selectedDays > 0)
                      Text(
                        '${formatLkr(price * _selectedDays)} rental',
                        style: const TextStyle(color: primaryRed, fontWeight: FontWeight.w700),
                      )
                    else
                      Text(
                        'Up to ${widget.maxDays} days',
                        style: const TextStyle(color: textGrey, fontSize: 12),
                      ),
                  ],
                ),
              ),
              if (_start != null)
                TextButton(
                  onPressed: _clear,
                  style: TextButton.styleFrom(foregroundColor: textGrey),
                  child: const Text('Clear'),
                ),
            ],
          ),
          const SizedBox(height: 10),
          PrimaryButton(
            label: _start == null ? 'Select your dates' : 'Confirm Dates',
            icon: Icons.check_circle_outline,
            onPressed: _start == null ? null : _confirm,
          ),
        ],
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  final String label;
  final String value;
  final bool active;

  const _ScoreCard({required this.label, required this.value, required this.active});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: active ? const Color(0xFFFFD54F) : Colors.white,
          width: 2.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: primaryRed,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: _ink, fontSize: 15, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  final int day;
  final bool isStart;
  final bool isEnd;
  final bool inRange;
  final bool isToday;
  final bool isBlocked;
  final bool isOutside;
  final VoidCallback onTap;

  const _DayCell({
    required this.day,
    required this.isStart,
    required this.isEnd,
    required this.inRange,
    required this.isToday,
    required this.isBlocked,
    required this.isOutside,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final selected = isStart || isEnd;
    final band = primaryRed.withValues(alpha: 0.12);
    final disabled = isOutside || isBlocked;

    Color textColor = _ink;
    if (selected) {
      textColor = Colors.white;
    } else if (isOutside) {
      textColor = Colors.black26;
    } else if (isBlocked) {
      textColor = textGrey;
    } else if (inRange) {
      textColor = _darkRed;
    }

    return Semantics(
      button: !disabled,
      selected: selected,
      label: isBlocked ? '$day, booked' : '$day',
      child: InkWell(
        onTap: disabled ? null : onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          height: 46,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Continuous band behind the rental days.
              if (inRange && !(isStart && isEnd))
                Positioned.fill(
                  top: 5,
                  bottom: 5,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: ColoredBox(color: isStart ? Colors.transparent : band)),
                      Expanded(child: ColoredBox(color: isEnd ? Colors.transparent : band)),
                    ],
                  ),
                ),
              if (isBlocked && !isOutside)
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: softGrey,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? primaryRed : Colors.transparent,
                  border: isToday && !selected
                      ? Border.all(color: primaryRed, width: 1.6)
                      : null,
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: primaryRed.withValues(alpha: 0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  '$day',
                  style: TextStyle(
                    color: textColor,
                    fontWeight: selected || inRange ? FontWeight.w800 : FontWeight.w600,
                    fontSize: 14,
                    decoration: isBlocked && !isOutside ? TextDecoration.lineThrough : null,
                    decorationColor: textGrey,
                    decorationThickness: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _LegendKind { selected, range, booked, today }

class _LegendItem extends StatelessWidget {
  final _LegendKind kind;
  final String label;

  const _LegendItem({required this.kind, required this.label});

  @override
  Widget build(BuildContext context) {
    final Widget swatch;
    switch (kind) {
      case _LegendKind.selected:
        swatch = const CircleAvatar(radius: 7, backgroundColor: primaryRed);
      case _LegendKind.range:
        swatch = Container(
          width: 18,
          height: 12,
          decoration: BoxDecoration(
            color: primaryRed.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(6),
          ),
        );
      case _LegendKind.booked:
        swatch = Container(
          width: 18,
          height: 14,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: softGrey,
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text(
            '7',
            style: TextStyle(
              fontSize: 9,
              color: textGrey,
              decoration: TextDecoration.lineThrough,
              decorationThickness: 2,
            ),
          ),
        );
      case _LegendKind.today:
        swatch = Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: primaryRed, width: 1.6),
          ),
        );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        swatch,
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: textGrey)),
      ],
    );
  }
}

class _RoundIcon extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  const _RoundIcon({required this.icon, required this.tooltip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: onTap == null ? softGrey : primaryRed.withValues(alpha: 0.10),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 38,
            height: 38,
            child: Icon(icon, color: onTap == null ? Colors.black26 : primaryRed),
          ),
        ),
      ),
    );
  }
}
