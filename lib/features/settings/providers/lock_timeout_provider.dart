import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/providers/storage_provider.dart';

final lockTimeoutProvider =
    StateNotifierProvider<LockTimeoutStateNotifier, int>((ref) {
  return LockTimeoutStateNotifier(ref);
});

class LockTimeoutStateNotifier extends StateNotifier<int> {
  final Ref ref;
  LockTimeoutStateNotifier(this.ref) : super(60) {
    loadInitialTimeout();
  }

  void loadInitialTimeout() {
    final storageService = ref.read(storageProvider);
    state = storageService.getLockTimeout() ?? 60;
  }

  void setLockTimeout(int seconds) {
    state = seconds;
    final storageService = ref.read(storageProvider);
    storageService.setLockTimeout(seconds);
  }
}
