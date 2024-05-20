import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/models/app_lifecycle_state.dart';

final appLifecycleProvider =
    StateNotifierProvider<AppLifecycleNotifier, AppLifecycleState>((ref) {
  return AppLifecycleNotifier(
      AppLifecycleState(timeoutDuration: const Duration(minutes: 1)));
});

class AppLifecycleNotifier extends StateNotifier<AppLifecycleState> {
  AppLifecycleNotifier(super.state);

  void updateLastPausedTime(DateTime time) {
    state = state.copyWith(lastPausedTime: time);
  }

  void updateTimeoutDuration(Duration duration) {
    state = state.copyWith(timeoutDuration: duration);
  }
}
