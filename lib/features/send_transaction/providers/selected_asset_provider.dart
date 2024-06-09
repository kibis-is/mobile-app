import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/providers/storage_provider.dart';

// Provider for managing lock timeout in seconds
final lockTimeoutProvider =
    StateNotifierProvider<LockTimeoutNotifier, int>((ref) {
  final storageService = ref.watch(storageProvider);
  return LockTimeoutNotifier(storageService);
});

class LockTimeoutNotifier extends StateNotifier<int> {
  final StorageService _storageService;
  static const int defaultTimeout = 60;

  LockTimeoutNotifier(this._storageService) : super(defaultTimeout) {
    _loadTimeout();
  }

  // Load the timeout value from storage or use the default
  void _loadTimeout() async {
    final int timeoutSeconds =
        _storageService.getLockTimeout() ?? defaultTimeout;
    state = timeoutSeconds;
  }

  // Set a new timeout value and save it to storage
  void setTimeout(int seconds) {
    state = seconds;
    _storageService.setLockTimeout(seconds);
  }
}
