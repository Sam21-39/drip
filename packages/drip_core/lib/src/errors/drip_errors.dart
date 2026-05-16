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

/// Thrown when one or more disposables in a [DripScope] throw during disposal.
///
/// Disposal of ALL registered resources is always attempted before this error
/// is thrown — no resource is skipped because an earlier one failed.
class DripDisposalError extends Error {
  /// Every error thrown by a disposable, in disposal order.
  final List<Object> errors;

  /// Stack traces corresponding to each entry in [errors].
  final List<StackTrace> stackTraces;

  /// The [DripScope.debugName] of the scope that failed to fully dispose.
  final String? scopeDebugName;

  DripDisposalError({
    required this.errors,
    required this.stackTraces,
    this.scopeDebugName,
  }) : assert(errors.length == stackTraces.length);

  @override
  String toString() {
    final scope = scopeDebugName != null ? ' in scope "$scopeDebugName"' : '';
    final lines = StringBuffer(
      'DripDisposalError: ${errors.length} disposal(s) failed$scope.\n',
    );
    for (var i = 0; i < errors.length; i++) {
      lines
        ..writeln('  [${i + 1}] ${errors[i].runtimeType}: ${errors[i]}')
        ..writeln(
            '      ${stackTraces[i].toString().split('\n').first.trim()}');
    }
    return lines.toString();
  }
}

/// Thrown (debug mode only) when a type violates the Dart equality/hashCode
/// contract — i.e., `a == b` is true but `a.hashCode != b.hashCode`.
///
/// DRIP's deduplication logic depends on this contract holding. A violation
/// causes silent wrong results in the reactive graph.
///
/// Fix: ensure your type satisfies:
///   if `a == b` then `a.hashCode == b.hashCode`.
class DripEqualityViolationError extends Error {
  /// The Dart [Type] of the violating value.
  final Type valueType;

  /// Hash code of the first value.
  final int hashCodeA;

  /// Hash code of the second value.
  final int hashCodeB;

  DripEqualityViolationError({
    required this.valueType,
    required this.hashCodeA,
    required this.hashCodeB,
  });

  @override
  String toString() =>
      'DripEqualityViolationError: Type "$valueType" violates the '
      'equality/hashCode contract.\n'
      '  a == b evaluated to true, but:\n'
      '    a.hashCode = $hashCodeA\n'
      '    b.hashCode = $hashCodeB\n'
      '  Fix: override hashCode consistently with your == implementation.';
}
