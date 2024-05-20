import 'package:algorand_dart/algorand_dart.dart';
import 'package:convert/convert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/providers/algorand_provider.dart';
import 'package:kibisis/providers/error_provider.dart';
import 'package:kibisis/utils/storage_service.dart';
// Ensure this import is correct

final accountProvider =
    StateNotifierProvider<AccountNotifier, AccountState>((ref) {
  final algorand = ref.watch(algorandProvider);
  final storageService = ref.read(storageProvider);
  return AccountNotifier(ref, algorand, storageService);
});

class AccountState {
  final Account? account;
  final String? accountName;

  AccountState({this.account, this.accountName});

  AccountState copyWith({Account? account, String? accountName}) {
    return AccountState(
      account: account ?? this.account,
      accountName: accountName ?? this.accountName,
    );
  }
}

class AccountNotifier extends StateNotifier<AccountState> {
  final StateNotifierProviderRef<AccountNotifier, AccountState> ref;
  final Algorand algorand;
  final StorageService storageService;

  AccountNotifier(this.ref, this.algorand, this.storageService)
      : super(AccountState()) {
    _initializeAccountFromStorage();
  }

  Future<void> _initializeAccountFromStorage() async {
    try {
      final accountName = storageService.getAccountName();
      if (accountName != null) {
        state = state.copyWith(accountName: accountName);
      }
    } catch (e) {
      ref.read(errorProvider.notifier).state =
          'Failed to initialize account name from storage: $e';
    }
  }

  Future<void> setAccountName(String accountName) async {
    try {
      state = state.copyWith(accountName: accountName);
    } catch (e) {
      ref.read(errorProvider.notifier).state =
          'Failed to create account name: $e';
    }
  }

  Future<void> createAccount() async {
    try {
      final account = await algorand.createAccount();
      state = state.copyWith(account: account);
    } catch (e) {
      ref.read(errorProvider.notifier).state = 'Failed to create account: $e';
    }
  }

  Future<void> restoreAccountFromSeedPhrase(
      List<String> seedPhrase, String accountName) async {
    try {
      final account = await algorand.restoreAccount(seedPhrase);
      state = state.copyWith(account: account, accountName: accountName);
    } catch (e) {
      ref.read(errorProvider.notifier).state = 'Failed to restore account: $e';
    }
  }

  Future<void> loadAccountFromPrivateKey() async {
    try {
      final privateKey = await storageService.getPrivateKey();
      // final privateKey = await getPrivateKey();
      if (privateKey != null) {
        final account = await algorand.loadAccountFromPrivateKey(privateKey);
        final accountName = ref.read(storageProvider).getAccountName();
        state = state.copyWith(account: account, accountName: accountName);
      }
    } catch (e) {
      ref.read(errorProvider.notifier).state = 'Failed to restore account: $e';
    }
  }

  Future<String> getPrivateKey() async {
    if (state.account?.keyPair == null) {
      Future.microtask(() => ref.read(errorProvider.notifier).state =
          'Private key is not available.');
      return '';
    }

    final privateKeyBytes =
        await state.account!.keyPair.extractPrivateKeyBytes();
    final encodedPrivateKey = hex.encode(privateKeyBytes);
    debugPrint('Encoded Private Key: $encodedPrivateKey');
    return encodedPrivateKey;
  }

  Future<String> getPublicAddress() async {
    if (state.account == null) {
      Future.microtask(() => ref.read(errorProvider.notifier).state =
          'Public address is not available.');
      return '';
    }
    return state.account!.publicAddress.toString();
  }

  Future<String> getSeedPhraseAsString() async {
    if (state.account?.seedPhrase == null) {
      Future.microtask(() => ref.read(errorProvider.notifier).state =
          'Seed phrase is not available.');

      return '';
    }
    List<String> seedPhrase = await state.account!.seedPhrase;
    return seedPhrase.join(' ');
  }

  Future<List<String>> getSeedPhraseAsList() async {
    if (state.account?.seedPhrase == null) {
      Future.microtask(() => ref.read(errorProvider.notifier).state =
          'Seed phrase is not available.');
      return [];
    }
    return state.account!.seedPhrase;
  }

  void clearAccountState() {
    state = AccountState();
  }
}
