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
  final Color Function(BuildContext) colorBuilder;

  const ResultTypeData({
    required this.label,
    required this.icon,
    required this.colorBuilder,
  });

  Color getColor(BuildContext context) => colorBuilder(context);

  static final Map<ResultType, ResultTypeData> typeData = {
    ResultType.nextPeriod: ResultTypeData(
      label: 'Next Period',
      icon: Icons.calendar_month,
      colorBuilder: (context) => Theme.of(context).colorScheme.primary,
    ),
    ResultType.ovulation: ResultTypeData(
      label: 'Ovulation',
      icon: Icons.water_drop,
      colorBuilder: (context) => Theme.of(context).colorScheme.tertiary,
    ),
    ResultType.unsafeDates: ResultTypeData(
      label: 'Unsafe Dates',
      icon: Icons.warning,
      colorBuilder: (context) => Theme.of(context).colorScheme.error,
    ),
    ResultType.safeDates: ResultTypeData(
      label: 'Safe Dates',
      icon: Icons.check_circle,
      colorBuilder: (context) => Theme.of(context).colorScheme.secondary,
    ),
  };
}