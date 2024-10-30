import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/providers/storage_provider.dart';

final pinLockStateAdapter = StateProvider<bool>((ref) {
  return ref.watch(pinLockProvider);
});

final pinLockProvider =
    StateNotifierProvider<PinLockStateNotifier, bool>((ref) {
  return PinLockStateNotifier(ref);
});

class PinLockStateNotifier extends StateNotifier<bool> {
  final Ref ref;
  PinLockStateNotifier(this.ref) : super(true) {
    loadInitialState();
  }

  void loadInitialState() {
    final storageService = ref.read(storageProvider);
    state = storageService.getTimeoutEnabled() ?? true;
  }

  void setPasswordLock(bool isEnabled) {
    state = isEnabled;
    final storageService = ref.read(storageProvider);
    storageService.setTimeoutEnabled(isEnabled);
  }
}
