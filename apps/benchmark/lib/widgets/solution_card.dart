import 'package:flutter/material.dart';
import 'stats_row.dart';

class SolutionCard extends StatelessWidget {
  final String id;
  final Widget counter;
  final Widget progressBar;
  final bool isRunning;
  final int? rank;

  const SolutionCard({
    super.key,
    required this.id,
    required this.counter,
    required this.progressBar,
    required this.isRunning,
    this.rank,
  });

  @override
  Widget build(BuildContext context) {
    final Color brandColor = id == 'drip' ? Colors.blue : Colors.grey[800]!;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: id == 'drip'
            ? Border.all(color: brandColor, width: 1.5)
            : Border.all(color: Colors.grey[200]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _getDisplayName(id),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    if (rank != null) _RankBadge(rank: rank!),
                    if (isRunning) ...[
                      const SizedBox(width: 8),
                      _StatusBadge(label: 'running', color: Colors.orange),
                    ],
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            counter,
            const SizedBox(height: 20),
            progressBar,
            const SizedBox(height: 20),
            StatsRow(id: id),
          ],
        ),
      ),
    );
  }

  String _getDisplayName(String id) {
    switch (id) {
      case 'drip':
        return 'DRIP';
      case 'getx':
        return 'GetX';
      case 'riverpod':
        return 'Riverpod';
      case 'bloc':
        return 'BLoC';
      case 'provider':
        return 'Provider';
      case 'setstate':
        return 'setState';
      default:
        return id.toUpperCase();
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _RankBadge extends StatelessWidget {
  final int rank;
  const _RankBadge({required this.rank});

  @override
  Widget build(BuildContext context) {
    final color =
        rank == 1 ? Colors.green : (rank == 6 ? Colors.red : Colors.blueGrey);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '#$rank',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
