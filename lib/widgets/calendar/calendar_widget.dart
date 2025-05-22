import 'package:flutter/material.dart';
import 'package:period_tracker_flutter/utils/date_utils.dart' as utils;
import 'package:period_tracker_flutter/widgets/calendar/calendar_utils.dart';

class CalendarWidget extends StatefulWidget {
  final DateTime lastPeriodDate;
  final int cycleLength;

  const CalendarWidget({
    required this.lastPeriodDate,
    required this.cycleLength,
    super.key,
  });

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  late DateTime _focusedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime(widget.lastPeriodDate.year, widget.lastPeriodDate.month, 1); // Start with the month of lastPeriodDate
  }

  @override
  void didUpdateWidget(CalendarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.lastPeriodDate != oldWidget.lastPeriodDate) {
      setState(() {
        _focusedDay = DateTime(widget.lastPeriodDate.year, widget.lastPeriodDate.month, 1);
      });
    }
  }

  void _onPreviousMonth() {
    setState(() {
      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1, 1);
    });
  }

  void _onNextMonth() {
    setState(() {
      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 1);
    });
  }

  Widget _buildMonth(DateTime month, DateTime lastPeriodDate, int cycleLength) {
    final firstDay = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    List<TableRow> rows = [];

    // Calculate dates for coloring
    final dates = CalendarUtils.getCalendarDates(lastPeriodDate, cycleLength);
    final ovulation = dates[2];
    final unsafeDates = CalendarUtils.getUnsafeDates(dates[2], dates[3], dates[4]);
    final safeDates = CalendarUtils.getSafeDates(dates[5], dates[6], dates[7], dates[8]);

    // Header with weekday names
    rows.add(TableRow(
      children: CalendarUtils.weekDays
          .map((d) => Center(
                child: Text(
                  d,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ))
          .toList(),
    ));

    int day = 1;
    int startWeekday = firstDay.weekday % 7; // Adjust for Sunday as first day

    for (int i = 0; i < 6; i++) {
      List<Widget> cells = [];
      for (int j = 0; j < 7; j++) {
        if (i == 0 && j < startWeekday) {
          cells.add(const SizedBox.shrink());
        } else if (day > daysInMonth) {
          cells.add(const SizedBox.shrink());
        } else {
          final thisDate = DateTime(month.year, month.month, day);
          Color? bgColor;
          Color textColor = Theme.of(context).colorScheme.onSurface;

          if (utils.DateUtils.isSameDay(thisDate, lastPeriodDate)) {
            bgColor = Colors.green.withOpacity(0.3);
            textColor = Colors.green;
          } else if (utils.DateUtils.isSameDay(thisDate, ovulation)) {
            bgColor = Colors.blue.withOpacity(0.3);
            textColor = Colors.blue;
          } else if (unsafeDates.any((d) => utils.DateUtils.isSameDay(d, thisDate))) {
            bgColor = Colors.red.withOpacity(0.3);
            textColor = Colors.red;
          } else if (safeDates.any((d) => utils.DateUtils.isSameDay(d, thisDate))) {
            bgColor = Colors.green.withOpacity(0.3);
            textColor = Colors.green;
          }

          cells.add(
            GestureDetector(
              onTap: () {
                // Handle date selection if needed
              },
              child: Container(
                margin: const EdgeInsets.all(4),
                decoration: bgColor != null
                    ? BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: textColor,
                          width: 1.5,
                        ),
                      )
                    : null,
                child: Center(
                  child: Text(
                    '$day',
                    style: TextStyle(
                      fontWeight: utils.DateUtils.isSameDay(thisDate, lastPeriodDate) ? FontWeight.bold : FontWeight.normal,
                      color: textColor,
                    ),
                  ),
                ),
              ),
            ),
          );
          day++;
        }
      }
      rows.add(TableRow(children: cells));
      if (day > daysInMonth) break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              onPressed: _onPreviousMonth,
            ),
            Text(
              '${utils.DateUtils.monthName(month.month)} ${month.year}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.arrow_forward_ios,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              onPressed: _onNextMonth,
            ),
          ],
        ),
        const SizedBox(height: 10),
        Table(
          children: rows,
          defaultColumnWidth: const FlexColumnWidth(1.0),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final month1 = _focusedDay;
    final month2 = DateTime(_focusedDay.year, _focusedDay.month + 1, 1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMonth(month1, widget.lastPeriodDate, widget.cycleLength),
        const SizedBox(height: 20), // Space between months
        _buildMonth(month2, widget.lastPeriodDate, widget.cycleLength),
      ],
    );
  }
}
