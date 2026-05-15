import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:drip_core/drip_core.dart';
import 'package:drip_flutter/drip_flutter.dart';

class TestAsyncNode extends DripNode with DripAsyncNode {
  late DripAsync<int> plainAsync;
  late DripAsync<int> futureAsync;
  late DripAsync<int> streamAsync;
  
  final Completer<int> futureCompleter = Completer<int>();
  final StreamController<int> streamController = StreamController<int>();

  @override
  void onInit() {
    plainAsync = asyncState<int>();
    futureAsync = asyncFromFuture(() => futureCompleter.future);
    streamAsync = asyncFromStream(streamController.stream);
  }
}

void main() {
  group('DripAsyncNode', () {
    test('AN-1.1: asyncState<T>() returns DripAsync<T> in loading state', () {
      final node = TestAsyncNode();
      expect(node.plainAsync.value, isA<DripLoading<int>>());
    });

    test('AN-1.2: asyncState<T>() disposed when node disposed', () {
      final node = TestAsyncNode();
      expect(node.plainAsync.subscribers.isEmpty, true);
      
      // Simulate adding a subscriber
      node.plainAsync.subscribe(TestListener());
      expect(node.plainAsync.subscribers.isNotEmpty, true);
      
      node.dispose();
      expect(node.plainAsync.subscribers.isEmpty, true);
    });

    test('AN-1.3 & AN-1.4: asyncFromFuture() transitions to data on completion', () async {
      final node = TestAsyncNode();
      expect(node.futureAsync.value, isA<DripLoading<int>>());
      
      node.futureCompleter.complete(42);
      await Future.microtask(() {}); // let run finish
      
      expect(node.futureAsync.value, isA<DripData<int>>());
      expect(node.futureAsync.value.dataOrNull, 42);
    });

    test('AN-1.4: asyncFromFuture() transitions to error on failure', () async {
      final node = TestAsyncNode();
      node.futureCompleter.completeError(Exception('failed'));
      
      await Future.microtask(() {}); // let run finish
      expect(node.futureAsync.value, isA<DripError<int>>());
    });

    test('AN-1.5: asyncFromStream() transitions through states', () async {
      final node = TestAsyncNode();
      expect(node.streamAsync.value, isA<DripLoading<int>>());
      
      node.streamController.add(1);
      await Future.microtask(() {});
      expect(node.streamAsync.value, isA<DripData<int>>());
      expect(node.streamAsync.value.dataOrNull, 1);
      
      node.streamController.addError(Exception('error'));
      await Future.microtask(() {});
      expect(node.streamAsync.value, isA<DripError<int>>());
    });

    test('AN-1.6: asyncFromStream() stream subscription cancelled on dispose()', () async {
      final node = TestAsyncNode();
      expect(node.streamController.hasListener, true);
      
      node.dispose();
      expect(node.streamController.hasListener, false);
    });
  });
}

class TestListener implements DripListener {
  @override
  void onStateChanged() {}
}
