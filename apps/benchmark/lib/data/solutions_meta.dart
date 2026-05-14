import 'package:flutter/material.dart';

class SolutionMeta {
  final String id;
  final String label;
  final Color color;

  const SolutionMeta({
    required this.id,
    required this.label,
    required this.color,
  });
}

const List<SolutionMeta> solutions = [
  SolutionMeta(id: 'drip', label: 'Drip', color: Color(0xFF00E5FF)), // Using a brand-like cyan for Drip
  SolutionMeta(id: 'getx', label: 'GetX', color: Color(0xFF639922)),
  SolutionMeta(id: 'riverpod', label: 'Riverpod', color: Color(0xFF1D9E75)),
  SolutionMeta(id: 'bloc', label: 'Bloc', color: Color(0xFF378ADD)),
  SolutionMeta(id: 'provider', label: 'Provider', color: Color(0xFFBA7517)),
  SolutionMeta(id: 'setstate', label: 'setState', color: Color(0xFFD85A30)),
];

const Map<String, Color> solutionColors = {
  'drip': Color(0xFF00E5FF),
  'getx': Color(0xFF639922),
  'riverpod': Color(0xFF1D9E75),
  'bloc': Color(0xFF378ADD),
  'provider': Color(0xFFBA7517),
  'setstate': Color(0xFFD85A30),
};
