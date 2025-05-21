import 'package:flutter/material.dart';

enum ResultType {
  nextPeriod,
  ovulation,
  unsafeDates,
  safeDates,
}

class ResultTypeData {
  final String label;
  final IconData icon;
  final Color color;

  const ResultTypeData({
    required this.label,
    required this.icon,
    required this.color,
  });

  static final Map<ResultType, ResultTypeData> typeData = {
    ResultType.nextPeriod: ResultTypeData(
      label: 'Next Period',
      icon: Icons.calendar_month,
      color: Colors.pinkAccent,
    ),
    ResultType.ovulation: ResultTypeData(
      label: 'Ovulation',
      icon: Icons.water_drop,
      color: Colors.blue,
    ),
    ResultType.unsafeDates: ResultTypeData(
      label: 'Unsafe Dates',
      icon: Icons.warning,
      color: Colors.red,
    ),
    ResultType.safeDates: ResultTypeData(
      label: 'Safe Dates',
      icon: Icons.check_circle,
      color: Colors.green,
    ),
  };
}