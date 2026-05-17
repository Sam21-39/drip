import 'package:drip_core/drip_core.dart';

void main() {
  final parent = DripScope();

  const numResources = 10000;
  var disposeCount = 0;

  final stopwatch = Stopwatch()..start();

  for (var i = 0; i < numResources; i++) {
    final child = DripScope(parent: parent);
    child.registerDisposal(() {
      disposeCount++;
    });
  }

  stopwatch.stop();
  final setupMs = stopwatch.elapsedMilliseconds;
  print('Setup of $numResources resources took ${setupMs}ms');

  final disposeStopwatch = Stopwatch()..start();
  parent.dispose();
  disposeStopwatch.stop();

  final disposeMs = disposeStopwatch.elapsedMilliseconds;
  print('Disposal of $numResources resources took ${disposeMs}ms');

  if (disposeCount != numResources) {
    throw StateError(
        'Disposal completeness failed: expected $numResources disposals, got $disposeCount');
  }

  print('SUCCESS: Scope disposal completeness verified.');
}
