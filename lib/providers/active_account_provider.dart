import 'package:flutter/material.dart';
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
      debugPrint("_loadActiveAccount error: $e");
      state = null;
    }
  }

  Future<void> setActiveAccount(String accountId) async {
    try {
      await storageService.setActiveAccount(accountId);
      state = accountId;
    } catch (e) {
      debugPrint("setActiveAccount error: $e");
      state = null;
    }
  }

  Future<void> reset() async {
    try {
      await storageService.setActiveAccount('');
      state = null;
    } catch (e) {
      debugPrint("reset error: $e");
      state = null;
    }
  }
}
