import 'package:flutter/material.dart';
import 'grid_demo.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DemoGridApp());
}

class DemoGridApp extends StatelessWidget {
  const DemoGridApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DRIP — Zero Rebuild Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const GridDemoScreen(),
    );
  }
}
