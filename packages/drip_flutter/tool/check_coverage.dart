import 'dart:io';

void main() {
  final lcovFile = File('coverage/lcov.info');
  if (!lcovFile.existsSync()) {
    print('Error: coverage/lcov.info not found.');
    print('Run flutter test --coverage before checking coverage.');
    exit(1);
  }

  final lines = lcovFile.readAsLinesSync();
  var totalLinesFound = 0;
  var totalLinesHit = 0;

  String? currentFile;
  var currentLinesFound = 0;
  var currentLinesHit = 0;

  final fileCoverages = <String, double>{};
  const strictFileThresholds = <String, double>{
    'src/widgets/drip_item_builder.dart': 100.0,
  };

  for (final line in lines) {
    if (line.startsWith('SF:')) {
      currentFile = line.substring(3);
      currentLinesFound = 0;
      currentLinesHit = 0;
    } else if (line.startsWith('LF:')) {
      currentLinesFound = int.parse(line.substring(3).trim());
    } else if (line.startsWith('LH:')) {
      currentLinesHit = int.parse(line.substring(3).trim());
    } else if (line == 'end_of_record') {
      final file = currentFile;
      if (file != null &&
          (file.startsWith('lib/') || file.contains('/lib/')) &&
          !file.contains('/test/') &&
          !file.contains('\\test\\')) {
        totalLinesFound += currentLinesFound;
        totalLinesHit += currentLinesHit;
        final percentage = currentLinesFound == 0
            ? 100.0
            : (currentLinesHit / currentLinesFound) * 100.0;
        fileCoverages[file.split('lib/').last] = percentage;
      }
      currentFile = null;
    }
  }

  print('===================================================');
  print('            drip_flutter Coverage Report          ');
  print('===================================================');
  fileCoverages.forEach((file, pct) {
    print('${file.padRight(40)} : ${pct.toStringAsFixed(1)}%');
  });
  print('---------------------------------------------------');

  if (totalLinesFound == 0) {
    print('No lib/ lines found for coverage analysis.');
    exit(1);
  }

  final totalPercentage = (totalLinesHit / totalLinesFound) * 100.0;
  print(
      'TOTAL LINE COVERAGE                      : ${totalPercentage.toStringAsFixed(2)}%');
  print('Lines hit: $totalLinesHit / Total lines: $totalLinesFound');
  print('===================================================');

  const threshold = 90.0;
  if (totalPercentage < threshold) {
    print(
        'FAIL: Total coverage is ${totalPercentage.toStringAsFixed(2)}%, below $threshold%.');
    exit(1);
  }

  for (final entry in strictFileThresholds.entries) {
    final file = entry.key;
    final min = entry.value;
    final actual = fileCoverages[file];
    if (actual == null) {
      print('FAIL: Required coverage file not found in report: $file');
      exit(1);
    }
    if (actual < min) {
      print(
          'FAIL: $file coverage is ${actual.toStringAsFixed(2)}%, below required ${min.toStringAsFixed(2)}%.');
      exit(1);
    }
  }

  print(
      'SUCCESS: Coverage threshold passed (${totalPercentage.toStringAsFixed(2)}% >= $threshold%).');
}
