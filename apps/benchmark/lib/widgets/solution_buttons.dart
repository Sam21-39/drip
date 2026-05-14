import 'package:flutter/material.dart';

class SolutionButtons extends StatelessWidget {
  final String activeId;
  final void Function(String id) onSelect;
  final bool isRunning;

  const SolutionButtons({
    super.key,
    required this.activeId,
    required this.onSelect,
    required this.isRunning,
  });

  static const solutions = [
    (id: 'drip', label: 'DRIP'),
    (id: 'getx', label: 'GETX'),
    (id: 'riverpod', label: 'RIVERPOD'),
    (id: 'bloc', label: 'BLOC'),
    (id: 'provider', label: 'PROVIDER'),
    (id: 'setstate', label: 'SETSTATE'),
  ];

  @override
  Widget build(BuildContext context) {
    const brandColor = Color(0xFF00D1FF);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: solutions.map((s) {
        final isActive = s.id == activeId;
        
        return ActionChip(
          label: Text(s.label),
          onPressed: isRunning ? null : () => onSelect(s.id),
          backgroundColor: isActive ? brandColor : Colors.white10,
          labelStyle: TextStyle(
            color: isActive ? Colors.black : Colors.white70,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
          side: BorderSide.none,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        );
      }).toList(),
    );
  }
}
