import 'package:flutter/material.dart';
import 'package:drip_core/drip_core.dart';
import 'package:drip_flutter/drip_flutter.dart';

class SelectorDemoNode extends DripNode {
  late final DripState<String> username;
  late final DripState<int> unreadCount;
  late final DripState<int> unrelatedState;

  @override
  void onInit() {
    username = state('User123');
    unreadCount = state(5);
    unrelatedState = state(0);
  }

  void changeUsername() => username.write('User${DateTime.now().millisecond}');
  void incrementUnread() => unreadCount.write(unreadCount.value + 1);
  void incrementUnrelated() => unrelatedState.write(unrelatedState.value + 1);
}

class SelectorDemoScreen extends StatelessWidget {
  const SelectorDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DripNodeProvider<SelectorDemoNode>(
      create: () => SelectorDemoNode(),
      builder: (context, node) {
        return Scaffold(
          appBar: AppBar(title: const Text('DripSelect Demo')),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('DripSelect (Rebuilds only when username or unread changes):'),
                const SizedBox(height: 16),
                DripSelect<(String, int)>(
                  select: () => (node.username.value, node.unreadCount.value),
                  builder: (context, value) {
                    debugPrint('DripSelect rebuilt!');
                    return Card(
                      color: Colors.blue.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          '${value.$1} - ${value.$2} unread messages',
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),
                DripBuilder<int>(
                  value: node.unrelatedState,
                  builder: (context, value) {
                    return Text('Unrelated state (Rebuilds independently): $value');
                  },
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: node.changeUsername,
                  child: const Text('Change Username'),
                ),
                ElevatedButton(
                  onPressed: node.incrementUnread,
                  child: const Text('Increment Unread'),
                ),
                ElevatedButton(
                  onPressed: node.incrementUnrelated,
                  child: const Text('Increment Unrelated'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
