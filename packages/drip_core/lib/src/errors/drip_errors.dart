/// Thrown when a circular dependency is detected in the reactive graph.
class DripCircularDependencyError extends Error {
  final String? debugName;
  final String message;

  DripCircularDependencyError([this.debugName])
      : message = 'Circular dependency detected' +
            (debugName != null ? ' in "$debugName"' : '') +
            '. A DripComputed cannot read itself during its own computation.';

  @override
  String toString() => 'DripCircularDependencyError: $message';
}

/// Thrown when attempting to use a disposed [DripScope].
class DripDisposedScopeError extends Error {
  final String? debugName;
  final String message;

  DripDisposedScopeError([this.debugName])
      : message = 'Scope' +
            (debugName != null ? ' "$debugName"' : '') +
            ' has been disposed. Cannot register new reactive resources.';

  @override
  String toString() => 'DripDisposedScopeError: $message';
}
