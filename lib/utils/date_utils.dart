class DateUtils {
  static String monthName(int month) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month];
  }

  static String formatDate(String dateStr) {
    final parts = dateStr.split('-');
    if (parts.length == 3) {
      final day = parts[0];
      final month = monthName(int.parse(parts[1]));
      final year = parts[2];
      return '$day $month $year';
    }
    return dateStr;
  }

  static String formatDateRange(String range) {
    if (!range.contains(' to ')) return range;
    final dates = range.split(' to ');
    return '${formatDate(dates[0])} - ${formatDate(dates[1])}';
  }

  static String formatSafeDateRanges(String ranges) {
    if (!ranges.contains(' and ')) {
      return formatDateRange(ranges);
    }
    final parts = ranges.split(' and ');
    return '${formatDateRange(parts[0])}\n${formatDateRange(parts[1])}';
  }

  static bool isSameDay(DateTime a, DateTime b) => 
      a.year == b.year && a.month == b.month && a.day == b.day;
}