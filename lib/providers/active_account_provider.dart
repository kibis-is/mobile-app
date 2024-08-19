import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/providers/storage_provider.dart';

final activeAccountProvider =
    StateNotifierProvider<ActiveAccountNotifier, String?>((ref) {
  final storageService = ref.watch(storageProvider);
  return ActiveAccountNotifier(storageService);
});

class ActiveAccountNotifier extends StateNotifier<String?> {
  final StorageService storageService;

  ActiveAccountNotifier(this.storageService) : super(null) {
    _loadActiveAccount();
  }

  String getActiveAccountId() {
    return storageService.getActiveAccount() ?? '';
  }

  Future<void> _loadActiveAccount() async {
    try {
      state = getActiveAccountId();
    } catch (e) {
      state = null;
      // Handle error if needed
    }
  }

  Future<void> setActiveAccount(String accountId) async {
    try {
      await storageService.setActiveAccount(accountId);
      state = accountId;
    } catch (e) {
      // Handle error if needed
    }
  }

  Future<void> reset() async {
    try {
      await storageService.setActiveAccount('');
      state = null;
    } catch (e) {
      // Handle error if needed
    }
  }
}
