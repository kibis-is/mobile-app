import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/providers/storage_provider.dart';

final accountsListProvider =
    StateNotifierProvider<AccountsListNotifier, AccountsListState>((ref) {
  return AccountsListNotifier(ref);
});

class AccountsListState {
  final List<Map<String, String>> accounts;
  final bool isLoading;
  final String? error;

  AccountsListState({
    required this.accounts,
    required this.isLoading,
    this.error,
  });

  AccountsListState copyWith({
    List<Map<String, String>>? accounts,
    bool? isLoading,
    String? error,
  }) {
    return AccountsListState(
      accounts: accounts ?? this.accounts,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class AccountsListNotifier extends StateNotifier<AccountsListState> {
  final Ref ref;

  AccountsListNotifier(this.ref)
      : super(AccountsListState(accounts: [], isLoading: true)) {
    loadAccounts();
  }

  Future<void> loadAccounts() async {
    try {
      final storageService = ref.read(storageProvider);
      final accountsMap = await storageService.getAccounts();

      if (accountsMap == null) {
        state = state.copyWith(accounts: [], isLoading: false);
        return;
      }

      final accountsList =
          await Future.wait(accountsMap.entries.map((entry) async {
        final accountId = entry.key;
        final accountData = entry.value;
        final publicKey = accountData['publicKey'] ?? 'No Public Key';
        return {
          'accountId': accountId,
          'accountName': accountData['accountName'] ?? 'Unnamed Account',
          'publicKey': publicKey,
        };
      }).toList());

      state = state.copyWith(accounts: accountsList, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> loadAccountsWithPrivateKeys() async {
    try {
      final storageService = ref.read(storageProvider);
      final accountsMap = await storageService.getAccounts();
      if (accountsMap == null) {
        state = state.copyWith(accounts: [], isLoading: false);
        return;
      }

      // Map accounts and fetch private keys
      final accountsList =
          await Future.wait(accountsMap.entries.map((entry) async {
        final accountId = entry.key;
        final accountData = entry.value;
        final publicKey = accountData['publicKey'] ?? 'No Public Key';
        final privateKey =
            await storageService.getPrivateKey(accountId) ?? 'No Private Key';
        return {
          'accountId': accountId,
          'accountName': accountData['accountName'] ?? 'Unnamed Account',
          'publicKey': publicKey,
          'privateKey': privateKey, // Including private keys now
        };
      }).toList());

      state = state.copyWith(accounts: accountsList, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> updateAccountName(String accountId, String accountName) async {
    final storageService = ref.read(storageProvider);
    await storageService.setAccountData(accountId, 'accountName', accountName);
    await loadAccounts(); // Trigger reload
  }

  List<Map<String, String>> getAccountsExcludingActive(String? activeAccount) {
    return state.accounts
        .where((account) => account['accountId'] != activeAccount)
        .toList();
  }
}