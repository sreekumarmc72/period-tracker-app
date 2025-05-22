import 'package:flutter/material.dart';

class ResultRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color Function(BuildContext) colorBuilder;

  const ResultRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.colorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    String cleanValue = value;
    if (cleanValue.contains(':')) {
      cleanValue = cleanValue.split(':')[1].trim();
    }
    if (cleanValue.contains('(excluding ovulation day)')) {
      cleanValue = cleanValue.replaceAll('(excluding ovulation day)', '').trim();
    }
    
    final iconColor = colorBuilder(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(8),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: cleanValue.split('\n').map((line) => Text(
                    line,
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  )).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
