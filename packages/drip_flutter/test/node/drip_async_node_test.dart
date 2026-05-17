import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:drip_core/drip_core.dart';
import 'package:drip_flutter/drip_flutter.dart';

class TestAsyncNode extends DripNode with DripAsyncNode {
  late DripAsync<int> futureAsync;
  late DripAsync<int> streamAsync;

  final Completer<int> futureCompleter = Completer<int>();
  final StreamController<int> streamController = StreamController<int>();

  @override
  void onInit() {
    futureAsync = runAsync(() => futureCompleter.future);
    streamAsync = watchStream(streamController.stream);
  }
}

void main() {
  group('DripAsyncNode', () {
    test('AN-1.1: runAsync() returns DripAsync<T> in loading state', () {
      final node = TestAsyncNode();
      expect(node.futureAsync.value, isA<DripAsyncLoading<int>>());
    });

    test('AN-1.2: runAsync() disposed when node disposed', () {
      final node = TestAsyncNode();
      expect(node.futureAsync.subscribers.isEmpty, true);

      // Simulate adding a listener
      node.futureAsync.addListener(() {});
      expect(node.futureAsync.subscribers.isNotEmpty, true);

      node.dispose();
      expect(node.futureAsync.subscribers.isEmpty, true);
    });

    test('AN-1.3: runAsync() transitions to data on completion', () async {
      final node = TestAsyncNode();
      expect(node.futureAsync.value, isA<DripAsyncLoading<int>>());

      node.futureCompleter.complete(42);
      await Future.microtask(() {}); // let run finish

      expect(node.futureAsync.value, isA<DripAsyncData<int>>());
      expect(node.futureAsync.value.dataOrNull, 42);
    });

    test('AN-1.4: watchStream() transitions through states', () async {
      final node = TestAsyncNode();
      expect(node.streamAsync.value, isA<DripAsyncLoading<int>>());

      node.streamController.add(1);
      await Future.microtask(() {});
      expect(node.streamAsync.value, isA<DripAsyncData<int>>());
      expect(node.streamAsync.value.dataOrNull, 1);

      node.streamController.addError(Exception('error'));
      await Future.microtask(() {});
      expect(node.streamAsync.value, isA<DripAsyncError<int>>());
    });

    test('AN-1.5: watchStream() subscription cancelled on dispose()', () async {
      final node = TestAsyncNode();
      expect(node.streamController.hasListener, true);

      node.dispose();
      expect(node.streamController.hasListener, false);
    });
  });
}
