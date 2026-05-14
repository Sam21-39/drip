import 'package:flutter/material.dart';
import 'package:drip_core/drip_core.dart';
import 'package:drip_flutter/drip_flutter.dart';

void main() {
  runApp(const ExampleApp());
}

// 1. Define DripState
final counter = dripState(0);

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('drip_flutter Example')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('You have pushed the button this many times:'),
              // 2. Use DripText to bind the state directly to RenderParagraph
              // This widget will update with ZERO build() calls when counter changes!
              DripText(
                DripComputed(
                  () => 'Number of pushes: ${counter.value}',
                ) as DripState<String>,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => counter.write(counter.value + 1),
          tooltip: 'Increment',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
