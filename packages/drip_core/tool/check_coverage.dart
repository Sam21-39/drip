import 'dart:io';

void main(List<String> args) {
  final lcovFile = File('coverage/lcov.info');
  if (!lcovFile.existsSync()) {
    print('Error: coverage/lcov.info not found!');
    print(
        'Please run your tests with coverage collection first (e.g. dart test --coverage=coverage && dart run coverage:format_coverage --lcov -i coverage -o coverage/lcov.info).');
    exit(1);
  }

  final lines = lcovFile.readAsLinesSync();
  var totalLinesFound = 0;
  var totalLinesHit = 0;

  String? currentFile;
  var currentLinesFound = 0;
  var currentLinesHit = 0;

  final fileCoverages = <String, double>{};

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
      if (currentFile != null &&
          !currentFile.contains('/test/') &&
          !currentFile.contains('\\test\\')) {
        totalLinesFound += currentLinesFound;
        totalLinesHit += currentLinesHit;
        final percentage = currentLinesFound == 0
            ? 100.0
            : (currentLinesHit / currentLinesFound) * 100.0;
        // Keep relative path or short path for output
        final shortPath = currentFile.split('lib/').last;
        fileCoverages[shortPath] = percentage;
      }
      currentFile = null;
    }
  }

  print('===================================================');
  print('               DRIP Coverage Report               ');
  print('===================================================');
  fileCoverages.forEach((file, pct) {
    print('${file.padRight(40)} : ${pct.toStringAsFixed(1)}%');
  });
  print('---------------------------------------------------');

  if (totalLinesFound == 0) {
    print('No lines found for coverage analysis.');
    exit(1);
  }

  final totalPercentage = (totalLinesHit / totalLinesFound) * 100.0;
  print(
      'TOTAL LINE COVERAGE                      : ${totalPercentage.toStringAsFixed(2)}%');
  print('Lines hit: $totalLinesHit / Total lines: $totalLinesFound');
  print('===================================================');

  const threshold = 95.0;
  if (totalPercentage < threshold) {
    print(
        'FAIL: Total coverage is ${totalPercentage.toStringAsFixed(2)}%, which is below the $threshold% threshold!');
    exit(1);
  } else {
    print(
        'SUCCESS: Coverage threshold passed (${totalPercentage.toStringAsFixed(2)}% >= $threshold%).');
    exit(0);
  }
}
