import 'package:flutter/material.dart';

class ResultRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;

  const ResultRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
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
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // Align items to the start vertically
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
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF8B5F6C), // Muted purple
                  ),
                ),
                const Spacer(), // Pushes the date column to the right
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start, // Align text to the left
                  children: cleanValue.split('\n').map((line) => Text(
                    line,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black, // Black color for value
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
