import 'package:flutter/material.dart';
import '../services/rebuild_tracker.dart';

class ActiveStats extends StatelessWidget {
  const ActiveStats({super.key});

  @override
  Widget build(BuildContext context) {
    const brandColor = Color(0xFF00D1FF);

    return StreamBuilder<void>(
      stream: RebuildTracker.instance.stream,
      builder: (_, __) {
        final t = RebuildTracker.instance;

        return Container(
          padding: const EdgeInsets.all(16),
          color: const Color(0xFF141417),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.activeId.toUpperCase(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: brandColor,
                        ),
                      ),
                      const Text(
                        'ACTIVE SOLUTION',
                        style: TextStyle(
                            fontSize: 8,
                            color: Colors.white24,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: _Sparkline(data: t.sparkline, color: brandColor),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _Stat('WIDGET BUILDS', '${t.totalWidgets}'),
                  _Stat('FRAME BUILDS', '${t.totalFrames}'),
                  _Stat('EFFICIENCY', '${t.efficiency.toStringAsFixed(1)}%'),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _Stat('BUILDS / FRAME', '${t.widgetsPerFrame}'),
                  _Stat('BUILDS / SEC', t.rebuildsPerSec.toStringAsFixed(0)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  const _Stat(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
              fontSize: 9, color: Colors.white38, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }
}

class _Sparkline extends StatelessWidget {
  final List<int> data;
  final Color color;
  const _Sparkline({required this.data, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: CustomPaint(
          painter: _SparklinePainter(data, color),
        ),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<int> data;
  final Color color;
  _SparklinePainter(this.data, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.fill;

    final barWidth = size.width / 60;
    final maxVal = data.fold<int>(0, (m, v) => v > m ? v : m).toDouble();
    if (maxVal == 0) return;

    for (int i = 0; i < data.length; i++) {
      final h = (data[i] / maxVal) * size.height;
      canvas.drawRect(
        Rect.fromLTWH(i * barWidth, size.height - h, barWidth - 1, h),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
