class HistoryItem {
  final DateTime lastPeriodDate;
  final int cycleLength;
  final String result;
  final DateTime savedAt;

  HistoryItem({
    required this.lastPeriodDate,
    required this.cycleLength,
    required this.result,
    required this.savedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'lastPeriodDate': lastPeriodDate.millisecondsSinceEpoch,
      'cycleLength': cycleLength,
      'result': result,
      'savedAt': savedAt.millisecondsSinceEpoch,
    };
  }

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      lastPeriodDate: DateTime.fromMillisecondsSinceEpoch(json['lastPeriodDate']),
      cycleLength: json['cycleLength'],
      result: json['result'],
      savedAt: DateTime.fromMillisecondsSinceEpoch(json['savedAt']),
    );
  }
}