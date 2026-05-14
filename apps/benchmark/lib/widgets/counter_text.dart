import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CounterText extends StatelessWidget {
  final int value;
  const CounterText({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return Text(
      NumberFormat('#,###').format(value),
      style: const TextStyle(
        fontFamily: 'monospace',
        fontSize: 28,
        fontWeight: FontWeight.w500,
        color: Color(0xFF1A1C1E),
      ),
    );
  }
}
