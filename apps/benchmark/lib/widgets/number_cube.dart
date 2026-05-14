import 'package:flutter/material.dart';

class NumberCube extends StatelessWidget {
  final int value;
  final int index;

  const NumberCube({required this.value, required this.index, super.key});

  @override
  Widget build(BuildContext context) {
    const brandColor = Color(0xFF00D1FF);
    // Use opacity based on value for intensity, but same color
    final opacity = (value / 1000.0).clamp(0.2, 1.0);
    final color = brandColor.withValues(alpha: opacity);

    return Container(
      decoration: BoxDecoration(
        color: color,
        border:
            Border.all(color: Colors.black.withValues(alpha: 0.1), width: 0.5),
      ),
      alignment: Alignment.center,
      child: Text(
        '$value',
        style: TextStyle(
          fontSize: 7,
          fontFamily: 'monospace',
          color: opacity > 0.6 ? Colors.black : Colors.white,
          height: 1,
        ),
      ),
    );
  }
}
