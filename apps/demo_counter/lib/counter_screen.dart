import 'package:flutter/material.dart';
import 'package:drip_flutter/drip_flutter.dart';
import 'counter_node.dart';

class CounterScreen extends StatelessWidget {
  const CounterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DripNodeProvider<CounterNode>(
      create: () => CounterNode(),
      builder: (context, node) {
        return Scaffold(
          appBar: AppBar(title: const Text('DRIP Counter Node')),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DripText(
                  node.displayText,
                  style: const TextStyle(
                      fontSize: 48, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    DripOpacity(
                      opacity: node.opacity,
                      child: ElevatedButton(
                        onPressed: node.decrement,
                        child: const Icon(Icons.remove),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: node.increment,
                      child: const Icon(Icons.add),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: node.reset,
                  child: const Text('RESET'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
