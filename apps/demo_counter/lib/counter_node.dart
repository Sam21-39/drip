import 'package:drip_core/drip_core.dart';
import 'package:drip_flutter/drip_flutter.dart';
import 'package:flutter/rendering.dart';

abstract class CounterRepository {
  Future<void> sync(int value);
}

class InMemoryCounterRepository implements CounterRepository {
  @override
  Future<void> sync(int value) async {
    // Simulate network sync
    await Future.delayed(const Duration(milliseconds: 100));
    debugPrint('Repo synced count: $value');
  }

  Future<int> fetchPersistedCount() async {
    await Future.delayed(const Duration(seconds: 1));
    return 0; // Simulated saved count
  }
}

class CounterNode extends DripNode with DripAsyncNode {
  late final DripState<int> count;
  late final DripComputed<String> displayText;
  late final DripComputed<double> opacity;
  late final DripComputed<bool> canDecrement;
  late final DripAsync<int> persistedCount;

  @override
  void onInit() {
    register<CounterRepository>(() => InMemoryCounterRepository());

    count = state(0);
    displayText = computed(() => 'Count: ${count.value}');
    opacity = computed(() => count.value > 0 ? 1.0 : 0.3);
    canDecrement = computed(() => count.value > 0);

    final repo = resolve<CounterRepository>() as InMemoryCounterRepository;
    
    // Simulate fetching persisted count using asyncFromFuture
    persistedCount = asyncFromFuture(() => repo.fetchPersistedCount());

    effect(() {
      repo.sync(count.value);
    });
  }

  void increment() {
    count.write(count.value + 1);
  }

  void decrement() {
    if (canDecrement.value) {
      count.write(count.value - 1);
    }
  }

  void reset() {
    count.write(0);
  }
}
