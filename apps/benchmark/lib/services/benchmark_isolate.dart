import 'dart:isolate';

void benchmarkIsolate(SendPort port) {
  const int target = 100000000;
  const int stepSize = 50000; // send update every 50K

  for (int i = stepSize; i <= target; i += stepSize) {
    port.send(i);
  }
  port.send(target); // guarantee exact final value
  port.send(-1); // sentinel: done
}
