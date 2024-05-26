import 'dart:async';
import 'dart:ui';

class Debouncer {
  Timer? _timer;

  void run(VoidCallback action, {int milliseconds = 500}) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}
