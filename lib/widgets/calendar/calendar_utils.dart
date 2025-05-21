import 'package:flutter/material.dart';
import 'package:period_tracker_flutter/utils/date_utils.dart' as utils;

class CalendarUtils {
  static const weekDays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  static List<DateTime> getCalendarDates(DateTime startDate, int cycleLength) {
    final nextPeriod = startDate.add(Duration(days: cycleLength - 1));
    final ovulation = startDate.add(Duration(days: cycleLength - 14));
    final unsafeStart = ovulation.subtract(const Duration(days: 5));
    final unsafeEnd = ovulation.add(const Duration(days: 5));
    final safe1Start = startDate;
    final safe1End = unsafeStart.subtract(const Duration(days: 1));
    final safe2Start = unsafeEnd.add(const Duration(days: 1));
    final safe2End = nextPeriod;

    return [
      startDate,
      nextPeriod,
      ovulation,
      unsafeStart,
      unsafeEnd,
      safe1Start,
      safe1End,
      safe2Start,
      safe2End,
    ];
  }

  static Set<DateTime> getUnsafeDates(DateTime ovulation, DateTime unsafeStart, DateTime unsafeEnd) {
    Set<DateTime> dates = {};
    for (int i = 0; i <= unsafeEnd.difference(unsafeStart).inDays; i++) {
      final d = unsafeStart.add(Duration(days: i));
      if (!utils.DateUtils.isSameDay(d, ovulation)) dates.add(d);
    }
    return dates;
  }

  static Set<DateTime> getSafeDates(
    DateTime startDate,
    DateTime safe1End,
    DateTime safe2Start,
    DateTime safe2End,
  ) {
    Set<DateTime> dates = {};
    for (int i = 0; i <= safe1End.difference(startDate).inDays; i++) {
      dates.add(startDate.add(Duration(days: i)));
    }
    for (int i = 0; i <= safe2End.difference(safe2Start).inDays; i++) {
      dates.add(safe2Start.add(Duration(days: i)));
    }
    dates.add(startDate); // period start is always safe
    return dates;
  }

  static Widget buildLegendBox(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.black26),
          ),
        ),
        const SizedBox(width: 4),
        Text(label),
      ],
    );
  }
}