abstract class SolutionController {
  void onValue(int v); // called by isolate listener
  void reset();
  int get currentValue;
}
