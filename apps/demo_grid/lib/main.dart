import 'package:flutter/material.dart';
import 'grid_demo.dart';

void main() {
  runApp(const DripBenchmarkApp());
}

class DripBenchmarkApp extends StatelessWidget {
  const DripBenchmarkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DRIP Demo Grid',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),
      home: const GridDemo(),
    );
  }
}
