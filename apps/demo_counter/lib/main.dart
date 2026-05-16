import 'package:drip_flutter/drip_flutter.dart';
import 'package:flutter/material.dart';
import 'counter_screen.dart';

void main() {
  DripFlutterBinding.ensureInitialized();
  runApp(const DemoCounterApp());
}

class DemoCounterApp extends StatelessWidget {
  const DemoCounterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DRIP Demo Counter',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const CounterScreen(),
    );
  }
}
