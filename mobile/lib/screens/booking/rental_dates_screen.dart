import 'package:flutter/material.dart';

class RentalDatesScreen extends StatefulWidget {
  final String equipmentName;
  final double pricePerDay;
  final DateTimeRange? initialDates;

  const RentalDatesScreen({
    super.key,
    required this.equipmentName,
    required this.pricePerDay,
    this.initialDates,
  });

  @override
  State<RentalDatesScreen> createState() => _RentalDatesScreenState();
}

class _RentalDatesScreenState extends State<RentalDatesScreen> {
  static const primaryRed = Color(0xFFED1235);

  late final DateTime _today;
  late final DateTime _lastDate;
  late DateTime _visibleMonth;

  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    _today = DateTime(now.year, now.month, now.day);
    _lastDate = DateTime(_today.year + 2, _today.month, _today.day);

    final initial = widget.initialDates;

    if (initial != null) {
      final start = DateUtils.dateOnly(initial.start);
      final end = DateUtils.dateOnly(initial.end);

      if (!start.isBefore(_today) &&
          !end.isAfter(_lastDate) &&
          !end.isBefore(start)) {
        _startDate = start;
        _endDate = end;
      }
    }

    final first = _startDate ?? _today;
    _visibleMonth = DateTime(first.year, first.month);
  }

  int get _rentalDays {
    final start = _startDate;
    final end = _endDate;

    if (start == null || end == null) return 0;

    // Inclusive billing: 12th to 18th = 7 rental days.
    return DateTime.utc(end.year, end.month, end.day)
            .difference(DateTime.utc(start.year, start.month, start.day))
            .inDays +
        1;
  }

  String _dateLabel(DateTime? date) {
    if (date == null) return 'Select date';

    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _money(double amount) {
    return amount.toStringAsFixed(
      amount == amount.roundToDouble() ? 0 : 2,
    );
  }

  void _selectDay(DateTime date) {
    setState(() {
      if (_startDate == null || _endDate != null) {
        _startDate = date;
        _endDate = null;
      } else if (date.isBefore(_startDate!)) {
        _startDate = date;
      } else {
        _endDate = date;
      }
    });
  }

  void _changeMonth(int offset) {
    setState(() {
      _visibleMonth = DateTime(
        _visibleMonth.year,
        _visibleMonth.month + offset,
      );
    });
  }

  Widget _dateCard(String title, DateTime? date) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F8FA),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE4E4E8)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 12),
            const Icon(
              Icons.calendar_month_outlined,
              color: primaryRed,
              size: 22,
            ),
            const SizedBox(height: 8),
            Text(
              _dateLabel(date),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _calendar() {
    const monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];

    final firstDay = DateTime(
      _visibleMonth.year,
      _visibleMonth.month,
    );

    final daysInMonth = DateTime(
      _visibleMonth.year,
      _visibleMonth.month + 1,
      0,
    ).day;

    // Monday is the first calendar column.
    final leadingCells = firstDay.weekday - 1;
    final cellCount = ((leadingCells + daysInMonth + 6) ~/ 7) * 7;

    final firstMonth = DateTime(_today.year, _today.month);
    final lastMonth = DateTime(_lastDate.year, _lastDate.month);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE4E4E8)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                tooltip: 'Previous month',
                onPressed: _visibleMonth.isAfter(firstMonth)
                    ? () => _changeMonth(-1)
                    : null,
                icon: const Icon(Icons.chevron_left),
              ),
              Expanded(
                child: Text(
                  '${monthNames[_visibleMonth.month - 1]} '
                  '${_visibleMonth.year}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Next month',
                onPressed: _visibleMonth.isBefore(lastMonth)
                    ? () => _changeMonth(1)
                    : null,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                .map(
                  (day) => Expanded(
                    child: Center(
                      child: Text(
                        day,
                        style: const TextStyle(
                          color: Colors.black45,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: cellCount,
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 6,
              crossAxisSpacing: 4,
            ),
            itemBuilder: (context, index) {
              final day = index - leadingCells + 1;

              if (day < 1 || day > daysInMonth) {
                return const SizedBox.shrink();
              }

              final date = DateTime(
                _visibleMonth.year,
                _visibleMonth.month,
                day,
              );

              final disabled =
                  date.isBefore(_today) || date.isAfter(_lastDate);

              final endpoint = DateUtils.isSameDay(date, _startDate) ||
                  DateUtils.isSameDay(date, _endDate);

              final inRange = _startDate != null &&
                  _endDate != null &&
                  date.isAfter(_startDate!) &&
                  date.isBefore(_endDate!);

              return Semantics(
                label: _dateLabel(date),
                selected: endpoint || inRange,
                button: true,
                enabled: !disabled,
                child: InkWell(
                  onTap: disabled ? null : () => _selectDay(date),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: endpoint
                          ? primaryRed
                          : inRange
                              ? const Color(0xFFFFE8EC)
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$day',
                      style: TextStyle(
                        color: disabled
                            ? Colors.black26
                            : endpoint
                                ? Colors.white
                                : Colors.black87,
                        fontWeight: endpoint || inRange
                            ? FontWeight.w800
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final validPrice =
        widget.pricePerDay.isFinite && widget.pricePerDay > 0;
    final complete = _startDate != null && _endDate != null;
    final rentalFee = validPrice ? widget.pricePerDay * _rentalDays : 0.0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: const Text(
          'Select Rental Dates',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            children: [
              Text(
                widget.equipmentName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                validPrice
                    ? 'Rs. ${_money(widget.pricePerDay)} / day'
                    : 'Rental price unavailable',
                style: const TextStyle(
                  color: primaryRed,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  _dateCard('Start Date', _startDate),
                  const SizedBox(width: 12),
                  _dateCard('End Date', _endDate),
                ],
              ),
              const SizedBox(height: 22),
              Text(
                _startDate == null || _endDate != null
                    ? 'Tap a start date, then tap an end date.'
                    : 'Now select your end date.',
                style: const TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 16),
              _calendar(),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _startDate == null
                      ? null
                      : () {
                          setState(() {
                            _startDate = null;
                            _endDate = null;
                          });
                        },
                  child: const Text(
                    'Clear dates',
                    style: TextStyle(color: primaryRed),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F8FA),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Rental Duration'),
                        Text(
                          complete ? '$_rentalDays days' : '—',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 28),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Rental Fee'),
                        Text(
                          complete && validPrice
                              ? 'Rs. ${_money(rentalFee)}'
                              : '—',
                          style: const TextStyle(
                            color: primaryRed,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Start and end dates are both charged. '
                'Availability will be checked before a booking is submitted.',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: complete && validPrice
                      ? () {
                          Navigator.pop(
                            context,
                            DateTimeRange(
                              start: _startDate!,
                              end: _endDate!,
                            ),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryRed,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Text(
                    'Confirm Dates',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
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