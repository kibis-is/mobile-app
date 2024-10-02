import 'package:algorand_dart/algorand_dart.dart';
import 'package:convert/convert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/constants/constants.dart';
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
  final AccountInformation? account;
  final String? accountName;
  final String? accountId;
  final String? applicationId;
  final String? error;

  AccountState({
    this.account,
    this.accountName,
    this.accountId,
    this.applicationId,
    this.error,
  });

  AccountState copyWith({
    AccountInformation? account,
    String? accountName,
    String? accountId,
    String? applicationId,
    String? error,
  }) {
    return AccountState(
      account: account ?? this.account,
      accountName: accountName ?? this.accountName,
      accountId: accountId ?? this.accountId,
      applicationId: applicationId ?? this.applicationId,
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
    if (activeAccountId == null || activeAccountId.isEmpty) {
      state = state.copyWith(error: 'No active account found');
      return;
    }

    try {
      final accountName =
          await storageService.getAccountData(activeAccountId, 'accountName') ??
              '';

      final applicationId =
          await storageService.getApplicationId(activeAccountId);

      await initialiseFromPublicKey(accountName, activeAccountId);

      state = state.copyWith(applicationId: applicationId);
    } catch (e) {
      state = state.copyWith(error: 'Failed to initialize account: $e');
    }
  }

  Future<void> initialiseFromPublicKey(
      String accountName, String activeAccountId) async {
    try {
      final publicKey = await storageService.getPublicKey(activeAccountId);
      if (publicKey == null || publicKey.isEmpty) {
        state = state.copyWith(error: 'Public key not found in storage');
        return;
      }

      // Option 1: Check locally if it's an unfunded account
      final isFunded = await checkIfAccountIsFunded(publicKey);
      if (!isFunded) {
        state = state.copyWith(
          accountId: activeAccountId,
          accountName: accountName,
          account: AccountInformation(
            address: publicKey,
            amount: 0,
            amountWithoutPendingRewards: 0,
            pendingRewards: 0,
            rewards: 0,
            round: 0,
            status: 'Offline',
            deleted: false,
            assets: [],
            appsLocalState: [],
            createdApps: [],
            createdAssets: [],
          ),
          error:
              'This account has not been funded yet. Please fund it to see details.',
        );
        return;
      }
      final accountResponse =
          await algorand.indexer().getAccountById(publicKey);

      final applicationId =
          await storageService.getApplicationId(activeAccountId);

      state = state.copyWith(
        accountId: activeAccountId,
        accountName: accountName,
        account: accountResponse.account,
        applicationId: applicationId,
      );
    } catch (e) {
      state = state.copyWith(
          error: 'Failed to initialize account: ${e.toString()}');
      debugPrint(e.toString());
    }
  }

  Future<bool> checkIfAccountIsFunded(String publicKey) async {
    try {
      final accountResponse =
          await algorand.indexer().getAccountById(publicKey);
      return accountResponse.account.amountWithoutPendingRewards > 0;
    } catch (e) {
      return false;
    }
  }

  Future<void> setAccountName(String accountName) async {
    try {
      if (accountName.length > kMaxAccountNameLength) {
        ref.read(errorProvider.notifier).state = 'Account name is too long';
      }
      state = state.copyWith(accountName: accountName);
    } catch (e) {
      ref.read(errorProvider.notifier).state =
          'Failed to create account name: $e';
    }
  }

  Future<void> createAccount() async {
    try {
      // Step 1: Create a new Algorand account
      final account = await algorand.createAccount();

      // Step 2: Extract private key and public address from the created account
      final privateKeyBytes = await account.keyPair.extractPrivateKeyBytes();
      final encodedPrivateKey =
          hex.encode(privateKeyBytes); // Encode private key to store securely
      final publicKey =
          account.publicAddress; // Public address (Algorand address)

      // Step 3: Generate a new account ID
      final accountId = await storageService.generateNextAccountId();

      // Step 4: Store the private key and public key in secure storage
      await storageService.setAccountData(
          accountId, 'privateKey', encodedPrivateKey);
      await storageService.setAccountData(accountId, 'publicKey', publicKey);

      // Step 5: Set the active account in the storage
      await storageService.setActiveAccount(accountId);

      // Step 6: Initialize the account state using the public key
      await initialiseFromPublicKey('New Account', accountId);
    } catch (e) {
      // Handle errors gracefully
      ref.read(errorProvider.notifier).state = 'Failed to create account: $e';
      debugPrint('Error creating account: $e');
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
          final applicationId = await storageService.getApplicationId(
              otherAccounts.first); // Retrieve new account's applicationId
          state = state.copyWith(
            accountId: otherAccounts.first,
            accountName: accountData,
            applicationId: applicationId, // Update applicationId
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
        applicationId: null, // No applicationId yet
        error: null,
      );
    } catch (e) {
      state = state.copyWith(error: 'Failed to restore account: $e');
      throw Exception('Failed to restore account: $e');
    }
  }

  Future<String> getPrivateKey() async {
    final accountId = state.accountId;
    if (accountId == null) {
      ref.read(errorProvider.notifier).state = 'No active account';
      return '';
    }
    final privateKey =
        await storageService.getAccountData(accountId, 'privateKey');
    if (privateKey == null) {
      ref.read(errorProvider.notifier).state =
          'Private key not found in storage';
      return '';
    }
    return privateKey;
  }

  Future<String> getPublicAddress() async {
    if (state.account == null) {
      Future.microtask(() => ref.read(errorProvider.notifier).state =
          'Public address is not available.');
      return '';
    }
    return state.account?.address ?? '';
  }

  Future<String> getSeedPhraseAsString() async {
    final accountId = state.accountId;
    if (accountId == null) {
      ref.read(errorProvider.notifier).state = 'No active account';
      return '';
    }
    final seedPhrase =
        await storageService.getAccountData(accountId, 'seedPhrase');
    if (seedPhrase == null) {
      ref.read(errorProvider.notifier).state =
          'Seed phrase not found in storage';
      return '';
    }
    return seedPhrase;
  }

  Future<String?> getAccountId() async {
    return state.accountId;
  }

  Future<void> finalizeAccountCreation(String accountName) async {
    try {
      final tempAccountState = ref.read(temporaryAccountProvider);

      if (tempAccountState.account == null) {
        throw Exception('Account is missing in temporary account data');
      }

      // Generate a new account ID
      final accountId = await storageService.generateNextAccountId();

      // Handle the case where the account is a regular Algorand Account
      if (tempAccountState.account is Account) {
        // Ensure private key and seed phrase are available
        if (tempAccountState.privateKey == null ||
            tempAccountState.seedPhrase == null) {
          throw Exception(
              'Incomplete temporary account data for regular account');
        }

        ref.read(isAuthenticatedProvider.notifier).state = true;

        // Store account details (account name, private key, seed phrase, and public key)
        await storageService.setAccountData(
            accountId, 'accountName', accountName);
        await storageService.setAccountData(
            accountId, 'privateKey', tempAccountState.privateKey!);
        await storageService.setAccountData(
            accountId, 'seedPhrase', tempAccountState.seedPhrase!);

        final publicKey = (tempAccountState.account as Account).publicAddress;
        if (publicKey.isEmpty) {
          throw Exception('Public key is missing.');
        }
        await storageService.setAccountData(accountId, 'publicKey', publicKey);

        // Set the newly created account as active
        await storageService.setActiveAccount(accountId);
      }
      // Handle the case where the account is a watch account (AccountInformation)
      else if (tempAccountState.account is AccountInformation) {
        final publicKey =
            (tempAccountState.account as AccountInformation).address;

        if (publicKey.isEmpty) {
          throw Exception('Public key is missing.');
        }

        // Store account details (account name, public key)
        await storageService.setAccountData(
            accountId, 'accountName', accountName);
        await storageService.setAccountData(accountId, 'publicKey', publicKey);

        // Mark the account as a watch account
        await storageService.setAccountData(
            accountId, 'isWatchAccount', 'true');

        // Set the newly created watch account as active
        await storageService.setActiveAccount(accountId);
      } else {
        throw Exception('Unsupported account type');
      }

      // Update the state with the new account information
      state = state.copyWith(
        accountId: accountId,
        accountName: accountName,
        applicationId: null, // No applicationId at this point
        error: null,
      );

      // Reset the temporary account state
      ref.read(temporaryAccountProvider.notifier).reset();
    } catch (e) {
      state = state.copyWith(error: 'Failed to finalize account creation: $e');
    }
  }

  Future<bool> hasPrivateKey() async {
    final accountId = state.accountId;
    if (accountId == null) {
      return false;
    }

    final privateKey =
        await storageService.getAccountData(accountId, 'privateKey');
    return privateKey != null && privateKey.isNotEmpty;
  }

  void reset() {
    state = AccountState();
  }
}
