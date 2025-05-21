import 'package:flutter/material.dart';
import 'package:period_tracker_flutter/widgets/result_card/result_row.dart';
import 'package:period_tracker_flutter/widgets/result_card/result_types.dart';
import 'package:period_tracker_flutter/utils/date_utils.dart' as utils;

class ResultCard extends StatelessWidget {
  final String resultData;

  const ResultCard({
    super.key,
    required this.resultData,
  });

  String _extractResult(String label) {
    final lines = resultData.split('\n');
    switch(label) {
      case 'Next Expected Period':
        return lines.isNotEmpty ? lines[0] : '';
      case 'Expected Ovulation':
        return lines.length > 1 ? lines[1] : '';
      case 'Unsafe Date Range':
        return lines.length > 2 ? lines[2] : '';
      case 'Safe Date Range':
        return lines.length > 3 ? lines[3] : '';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ResultRow(
          icon: ResultTypeData.typeData[ResultType.nextPeriod]!.icon,
          label: ResultTypeData.typeData[ResultType.nextPeriod]!.label,
          value: utils.DateUtils.formatDate(_extractResult('Next Expected Period')),
          iconColor: ResultTypeData.typeData[ResultType.nextPeriod]!.color,
        ),
        const Divider(height: 28, thickness: 1), // Add divider
        ResultRow(
          icon: ResultTypeData.typeData[ResultType.ovulation]!.icon,
          label: ResultTypeData.typeData[ResultType.ovulation]!.label,
          value: utils.DateUtils.formatDate(_extractResult('Expected Ovulation')),
          iconColor: ResultTypeData.typeData[ResultType.ovulation]!.color,
        ),
        const Divider(height: 28, thickness: 1), // Add divider
        ResultRow(
          icon: ResultTypeData.typeData[ResultType.safeDates]!.icon,
          label: ResultTypeData.typeData[ResultType.safeDates]!.label,
          value: utils.DateUtils.formatSafeDateRanges(_extractResult('Safe Date Range')),
          iconColor: ResultTypeData.typeData[ResultType.safeDates]!.color,
        ),
        const Divider(height: 28, thickness: 1), // Add divider
        ResultRow(
          icon: ResultTypeData.typeData[ResultType.unsafeDates]!.icon,
          label: ResultTypeData.typeData[ResultType.unsafeDates]!.label,
          value: utils.DateUtils.formatDateRange(_extractResult('Unsafe Date Range')),
          iconColor: ResultTypeData.typeData[ResultType.unsafeDates]!.color,
        ),
      ],
    );
  }
}
