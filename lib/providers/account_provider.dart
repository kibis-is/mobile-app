import 'package:algorand_dart/algorand_dart.dart';
import 'package:convert/convert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/providers/accounts_list_provider.dart';
import 'package:kibisis/providers/algorand_provider.dart';
import 'package:kibisis/providers/authentication_provider.dart';
import 'package:kibisis/providers/error_provider.dart';
import 'package:kibisis/providers/storage_provider.dart';
import 'package:kibisis/providers/temporary_account_provider.dart';

final accountProvider =
    StateNotifierProvider<AccountNotifier, AccountState>((ref) {
  final algorand = ref.watch(algorandProvider);
  final storageService = ref.read(storageProvider);
  return AccountNotifier(ref, algorand, storageService);
});

class AccountState {
  final Account? account;
  final String? accountName;
  final String? accountId;
  final String? privateKey;
  final String? seedPhrase;
  final String? error;

  AccountState({
    this.account,
    this.accountName,
    this.accountId,
    this.privateKey,
    this.seedPhrase,
    this.error,
  });

  AccountState copyWith({
    Account? account,
    String? accountName,
    String? accountId,
    String? privateKey,
    String? seedPhrase,
    String? error,
  }) {
    return AccountState(
      account: account ?? this.account,
      accountName: accountName ?? this.accountName,
      accountId: accountId ?? this.accountId,
      privateKey: privateKey ?? this.privateKey,
      seedPhrase: seedPhrase ?? this.seedPhrase,
      error: error ?? this.error,
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
    final activeAccountId = storageService.getActiveAccount();
    if (activeAccountId == null) {
      state = state.copyWith(error: 'No active account found');
      return;
    }

    try {
      final accountName =
          await storageService.getAccountData(activeAccountId, 'accountName');
      final privateKey =
          await storageService.getAccountData(activeAccountId, 'privateKey');

      if (privateKey != null) {
        final account = await algorand.loadAccountFromPrivateKey(privateKey);
        state = state.copyWith(
          accountId: activeAccountId,
          accountName: accountName,
          account: account,
        );
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to initialize account: $e');
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

  Future<void> updateAccountName(String newAccountName) async {
    final activeAccountId = state.accountId;
    if (activeAccountId == null) {
      throw Exception('No active account to update');
    }

    await storageService.setAccountData(
        activeAccountId, 'accountName', newAccountName);
    state = state.copyWith(accountName: newAccountName);
  }

  Future<void> deleteAccount(String accountId) async {
    try {
      final accounts = await storageService.getAccounts();
      if (accounts == null || !accounts.containsKey(accountId)) {
        throw Exception('Account not found');
      }

      if (state.accountId == accountId) {
        final otherAccounts =
            accounts.keys.where((id) => id != accountId).toList();
        if (otherAccounts.isNotEmpty) {
          await storageService.setActiveAccount(otherAccounts.first);
          final accountData = await storageService.getAccountData(
              otherAccounts.first, 'accountName');
          state = state.copyWith(
            accountId: otherAccounts.first,
            accountName: accountData,
          );
        } else {
          state = AccountState();
        }
      }

      await storageService.deleteAccount(accountId);
      await ref.read(accountsListProvider.notifier).loadAccounts();
    } catch (e) {
      state = state.copyWith(error: 'Failed to delete account: $e');
    }
  }

  Future<void> restoreAccountFromSeedPhrase(
      List<String> seedPhrase, String accountName) async {
    try {
      final account = await algorand.restoreAccount(seedPhrase);
      final privateKeyBytes = await account.keyPair.extractPrivateKeyBytes();
      final encodedPrivateKey = hex.encode(privateKeyBytes);
      final seedPhraseString = seedPhrase.join(' ');
      final accountId = await storageService.generateNextAccountId();

      await storageService.setAccountData(
          accountId, 'accountName', accountName);
      await storageService.setAccountData(
          accountId, 'privateKey', encodedPrivateKey);
      await storageService.setAccountData(
          accountId, 'seedPhrase', seedPhraseString);
      await storageService.setActiveAccount(accountId);

      state = state.copyWith(
        accountId: accountId,
        accountName: accountName,
        privateKey: encodedPrivateKey,
        seedPhrase: seedPhraseString,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(error: 'Failed to restore account: $e');
      throw Exception('Failed to restore account: $e');
    }
  }

  Future<void> loadAccountFromPrivateKey() async {
    try {
      final activeAccountId = storageService.getActiveAccount();
      if (activeAccountId == null) {
        throw Exception('No active account found');
      }

      final privateKey =
          await storageService.getAccountData(activeAccountId, 'privateKey');
      final accountName =
          await storageService.getAccountData(activeAccountId, 'accountName');
      if (privateKey == null || accountName == null) {
        throw Exception('Missing account data for the active account');
      }

      final account = await algorand.loadAccountFromPrivateKey(privateKey);
      final seedPhrase = await account.seedPhrase;

      state = state.copyWith(
        accountId: activeAccountId,
        accountName: accountName,
        account: account,
        privateKey: privateKey,
        seedPhrase: seedPhrase.join(' '),
        error: null,
      );
    } catch (e) {
      state =
          state.copyWith(error: 'Failed to load account from private key: $e');
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

  Future<String?> getAccountId() async {
    return state.accountId;
  }

  Future<void> finalizeAccountCreation(String accountName) async {
    try {
      final tempAccountState = ref.read(temporaryAccountProvider);

      if (tempAccountState.account == null ||
          tempAccountState.privateKey == null ||
          tempAccountState.seedPhrase == null) {
        throw Exception('Incomplete temporary account data');
      }

      ref.read(isAuthenticatedProvider.notifier).state = true;

      final accountId = await storageService.generateNextAccountId();
      await storageService.setAccountData(
          accountId, 'accountName', accountName);
      await storageService.setAccountData(
          accountId, 'privateKey', tempAccountState.privateKey!);
      await storageService.setAccountData(
          accountId, 'seedPhrase', tempAccountState.seedPhrase!);
      await storageService.setActiveAccount(accountId);

      state = state.copyWith(
        accountId: accountId,
        accountName: accountName,
        privateKey: tempAccountState.privateKey,
        seedPhrase: tempAccountState.seedPhrase,
        error: null,
      );

      ref.read(temporaryAccountProvider.notifier).clear();
    } catch (e) {
      state = state.copyWith(error: 'Failed to finalize account creation: $e');
    }
  }

  void clearAccountState() {
    state = AccountState();
  }
}
