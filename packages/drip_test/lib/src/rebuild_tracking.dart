typedef BuildCounterRead = int Function();

Future<void> expectZeroRebuilds({
  required BuildCounterRead readCount,
  required Future<void> Function() act,
}) async {
  final before = readCount();
  await act();
  final after = readCount();
  if (after != before) {
    throw StateError(
      'Expected zero rebuilds, but count changed from $before to $after.',
    );
  }
}
