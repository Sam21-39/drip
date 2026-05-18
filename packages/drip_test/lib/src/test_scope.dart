import 'package:drip_core/drip_core.dart';
import 'package:flutter_test/flutter_test.dart';

/// Creates an isolated [DripScope] for tests and auto-disposes it with teardown.
DripScope createDripTestScope({String debugName = 'drip-test-scope'}) {
  final scope = DripScope(debugName: debugName);
  addTearDown(scope.dispose);
  return scope;
}
