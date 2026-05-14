import 'package:flutter/material.dart';

class ProgressBar extends StatelessWidget {
  final int value;
  final Color color;
  const ProgressBar({
    super.key,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    const int target = 100000000;
    final double progress = (value / target).clamp(0.0, 1.0);
    final int percent = (progress * 100).toInt();

    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 35,
          child: Text(
            '$percent%',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
        ),
      ],
    );
  }
}
