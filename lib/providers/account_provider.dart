import 'package:algorand_dart/algorand_dart.dart';
import 'package:convert/convert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/generated/l10n.dart';
import 'package:kibisis/providers/accounts_list_provider.dart';
import 'package:kibisis/providers/active_account_provider.dart';
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
    final activeAccountId = await storageService.getActiveAccount();
    if (activeAccountId == null || activeAccountId.isEmpty) {
      state = state.copyWith(error: S.current.noActiveAccountFound);

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
      state = state.copyWith(
          error: S.current.failedToInitializeAccount(e.toString()));
    }
  }

  Future<void> initialiseFromPublicKey(
      String accountName, String activeAccountId) async {
    try {
      final publicKey = await storageService.getPublicKey(activeAccountId);
      if (publicKey == null || publicKey.isEmpty) {
        state = state.copyWith(error: S.current.publicKeyNotFoundInStorage);
        return;
      }

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
          error: S.current.accountNotFundedPleaseFundToSeeDetails,
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
          error: S.current.failedToInitializeAccount(e.toString()));
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
        ref.read(errorProvider.notifier).state = S.current.accountNameIsTooLong;
      }
      state = state.copyWith(accountName: accountName);
    } catch (e) {
      ref.read(errorProvider.notifier).state =
          S.current.failedToCreateAccountName(e.toString());
    }
  }

  Future<void> createAccount() async {
    try {
      final account = await algorand.createAccount();

      final privateKeyBytes = await account.keyPair.extractPrivateKeyBytes();
      final encodedPrivateKey = hex.encode(privateKeyBytes);
      final publicKey = account.publicAddress;

      final accountId = await storageService.generateNextAccountId();

      await storageService.setAccountData(
          accountId, 'privateKey', encodedPrivateKey);
      await storageService.setAccountData(accountId, 'publicKey', publicKey);

      await storageService.setActiveAccount(accountId);

      await initialiseFromPublicKey('New Account', accountId);
    } catch (e) {
      ref.read(errorProvider.notifier).state =
          S.current.failedToCreateAccount(e.toString());

      debugPrint('Error creating account: $e');
    }
  }

  Future<void> updateAccountName(String newAccountName) async {
    final activeAccountId = state.accountId;
    if (activeAccountId == null) {
      throw Exception(S.current.noActiveAccountToUpdate);
    }

    await storageService.setAccountData(
        activeAccountId, 'accountName', newAccountName);
    state = state.copyWith(accountName: newAccountName);
  }

  Future<void> deleteAccount(String accountId) async {
    try {
      final accounts = await storageService.getAccounts();
      if (accounts == null || !accounts.containsKey(accountId)) {
        throw Exception(S.current.accountNotFound);
      }

      if (state.accountId == accountId) {
        final otherAccounts =
            accounts.keys.where((id) => id != accountId).toList();
        if (otherAccounts.isNotEmpty) {
          await storageService.setActiveAccount(otherAccounts.first);
          final accountData = await storageService.getAccountData(
              otherAccounts.first, 'accountName');
          final applicationId =
              await storageService.getApplicationId(otherAccounts.first);
          state = state.copyWith(
            accountId: otherAccounts.first,
            accountName: accountData,
            applicationId: applicationId,
          );
        } else {
          state = AccountState();
        }
      }

      await storageService.deleteAccount(accountId);
      await ref.read(accountsListProvider.notifier).loadAccounts();
    } catch (e) {
      state =
          state.copyWith(error: S.current.failedToDeleteAccount(e.toString()));
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
        applicationId: null,
        error: null,
      );
    } catch (e) {
      state =
          state.copyWith(error: S.current.failedToRestoreAccount(e.toString()));

      throw Exception(S.current.failedToRestoreAccount(e.toString()));
    }
  }

  Future<String> getPrivateKey() async {
    final accountId = state.accountId;
    if (accountId == null) {
      ref.read(errorProvider.notifier).state = S.current.noActiveAccount;
      return '';
    }
    final privateKey =
        await storageService.getAccountData(accountId, 'privateKey');
    if (privateKey == null) {
      ref.read(errorProvider.notifier).state =
          S.current.privateKeyNotFoundInStorage;
      return '';
    }
    return privateKey;
  }

  Future<String> getPublicAddress() async {
    if (state.account == null) {
      Future.microtask(() => ref.read(errorProvider.notifier).state =
          S.current.publicAddressNotAvailable);
      return '';
    }
    return state.account?.address ?? '';
  }

  Future<String> getSeedPhraseAsString() async {
    final accountId = state.accountId;
    if (accountId == null) {
      ref.read(errorProvider.notifier).state = S.current.noActiveAccountIdFound;
      return '';
    }
    final seedPhrase =
        await storageService.getAccountData(accountId, 'seedPhrase');
    if (seedPhrase == null) {
      ref.read(errorProvider.notifier).state =
          S.current.seedPhraseNotFoundInStorage;

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
        throw Exception(S.current.accountMissingInTemporaryData);
      }

      final accountId = await storageService.generateNextAccountId();

      if (tempAccountState.account is Account) {
        if (tempAccountState.privateKey == null ||
            tempAccountState.seedPhrase == null) {
          throw Exception(S.current.incompleteTemporaryAccountData);
        }

        ref.read(isAuthenticatedProvider.notifier).state = true;

        await storageService.setAccountData(
            accountId, 'accountName', accountName);
        await storageService.setAccountData(
            accountId, 'privateKey', tempAccountState.privateKey!);
        await storageService.setAccountData(
            accountId, 'seedPhrase', tempAccountState.seedPhrase!);

        final publicKey = (tempAccountState.account as Account).publicAddress;
        if (publicKey.isEmpty) {
          throw Exception(S.current.publicKeyIsMissing);
        }
        await storageService.setAccountData(accountId, 'publicKey', publicKey);

        // Set the new account as the active account
        await storageService.setActiveAccount(accountId);
        ref.read(activeAccountProvider.notifier).setActiveAccount(accountId);

        // Initialize account provider with new account details
        await ref
            .read(accountProvider.notifier)
            .initialiseFromPublicKey(accountName, accountId);
      } else if (tempAccountState.account is AccountInformation) {
        final publicKey =
            (tempAccountState.account as AccountInformation).address;

        if (publicKey.isEmpty) {
          throw Exception(S.current.noPublicKey);
        }

        await storageService.setAccountData(
            accountId, 'accountName', accountName);
        await storageService.setAccountData(accountId, 'publicKey', publicKey);

        await storageService.setAccountData(
            accountId, 'isWatchAccount', 'true');

        await storageService.setActiveAccount(accountId);
        ref.read(activeAccountProvider.notifier).setActiveAccount(accountId);
      } else {
        throw Exception(S.current.unsupportedAccountType);
      }

      state = state.copyWith(
        accountId: accountId,
        accountName: accountName,
        applicationId: null,
        error: null,
      );

      ref.read(temporaryAccountProvider.notifier).reset();
    } catch (e) {
      state = state.copyWith(
          error: S.current.failedToFinalizeAccountCreation(e.toString()));
      throw Exception(S.current.failedToFinalizeAccountCreation(e.toString()));
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
