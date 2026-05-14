import 'package:flutter/material.dart';
import '../services/rebuild_tracker.dart';

class StatsRow extends StatelessWidget {
  final String id;
  const StatsRow({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<void>(
      stream: RebuildTracker.instance.stream,
      builder: (_, __) {
        final t = RebuildTracker.instance;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _Stat('rebuilds', '${t.total(id)}'),
            _Stat('wasted', '${t.wasted(id)}'),
            _Stat('efficiency', '${t.efficiency(id).toStringAsFixed(0)}%'),
            _Stat('builds/sec', t.rebuildsPerSec(id).toStringAsFixed(1)),
          ],
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
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontFamily: 'monospace',
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
