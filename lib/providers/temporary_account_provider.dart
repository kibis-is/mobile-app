import 'dart:typed_data';

import 'package:algorand_dart/algorand_dart.dart';
import 'package:convert/convert.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/providers/algorand_provider.dart';
import 'package:kibisis/providers/storage_provider.dart';

final temporaryAccountProvider =
    StateNotifierProvider<TemporaryAccountNotifier, TemporaryAccountState>(
        (ref) {
  final algorand = ref.watch(algorandProvider);
  return TemporaryAccountNotifier(ref, algorand);
});

class TemporaryAccountState {
  final Account? account;
  final String? privateKey;
  final String? seedPhrase;
  final String? accountName; // Added field for account name

  TemporaryAccountState({
    this.account,
    this.privateKey,
    this.seedPhrase,
    this.accountName, // Initialize account name
  });

  TemporaryAccountState copyWith({
    Account? account,
    String? privateKey,
    String? seedPhrase,
    String? accountName, // Include accountName in copyWith
  }) {
    return TemporaryAccountState(
      account: account ?? this.account,
      privateKey: privateKey ?? this.privateKey,
      seedPhrase: seedPhrase ?? this.seedPhrase,
      accountName: accountName ?? this.accountName, // Set account name
    );
  }
}

class TemporaryAccountNotifier extends StateNotifier<TemporaryAccountState> {
  final Ref ref;
  final Algorand algorand;

  TemporaryAccountNotifier(this.ref, this.algorand)
      : super(TemporaryAccountState());

  Future<void> createTemporaryAccount() async {
    try {
      final account = await algorand.createAccount();
      final privateKeyBytes = await account.keyPair.extractPrivateKeyBytes();
      final encodedPrivateKey = hex.encode(privateKeyBytes);
      final seedPhrase = await account.seedPhrase;
      final seedPhraseString = seedPhrase.join(' ');

      state = state.copyWith(
        account: account,
        privateKey: encodedPrivateKey,
        seedPhrase: seedPhraseString,
      );
    } catch (e) {
      state = state.copyWith(
        account: null,
        privateKey: null,
        seedPhrase: null,
      );
      rethrow;
    }
  }

  Future<void> restoreAccountFromPrivateKey(String hexPrivateKey) async {
    try {
      final accountExists = await _accountExists(hexPrivateKey);
      if (accountExists) {
        throw Exception('Account already added.');
      }

      final account = await algorand.loadAccountFromPrivateKey(hexPrivateKey);

      final seedPhrase = await account.seedPhrase;
      final seedPhraseString = seedPhrase.join(' ');

      state = state.copyWith(
        account: account,
        privateKey: hexPrivateKey,
        seedPhrase: seedPhraseString,
      );
    } catch (e) {
      state = state.copyWith(
        account: null,
        privateKey: null,
        seedPhrase: null,
      );
      throw Exception(e);
    }
  }

  Future<void> restoreAccountFromSeedPhrase(List<String> seedPhrase) async {
    try {
      final account = await algorand.restoreAccount(seedPhrase);
      final privateKeyBytes = await account.keyPair.extractPrivateKeyBytes();
      final encodedPrivateKey = hex.encode(privateKeyBytes);

      final accountExists = await _accountExists(encodedPrivateKey);
      if (accountExists) {
        throw Exception('Account already added.');
      }

      final seedPhraseString = seedPhrase.join(' ');

      state = state.copyWith(
        account: account,
        privateKey: encodedPrivateKey,
        seedPhrase: seedPhraseString,
      );
    } on AlgorandException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      state = state.copyWith(
        account: null,
        privateKey: null,
        seedPhrase: null,
      );
      throw Exception(e);
    }
  }

  Future<void> restoreAccountFromSeed(Uint8List seed, {String? name}) async {
    try {
      // Create account from seed
      final account = await Account.fromSeed(seed);

      final hexPrivateKey = hex.encode(seed);

      // Check if account already exists
      final accountExists = await _accountExists(hexPrivateKey);
      if (accountExists) {
        throw Exception('Account already added.');
      }

      // Get seed phrase and convert to string
      final seedPhrase = await account.seedPhrase;
      final seedPhraseString = seedPhrase.join(' ');

      // Update state with the new account information and the provided name
      state = state.copyWith(
        account: account,
        accountName: name, // Use the provided name
        privateKey: hexPrivateKey,
        seedPhrase: seedPhraseString,
      );
    } on AlgorandException catch (e) {
      // Handle Algorand specific exceptions
      state = state.copyWith(
        account: null,
        accountName: null, // Reset account name on failure
        privateKey: null,
        seedPhrase: null,
      );
      throw Exception(e.message);
    } catch (e) {
      // Handle general exceptions
      state = state.copyWith(
        account: null,
        accountName: null, // Reset account name on failure
        privateKey: null,
        seedPhrase: null,
      );
      throw Exception(e);
    }
  }

  Future<bool> _accountExists(String privateKey) async {
    final storageService = ref.read(storageProvider);
    final existingAccounts = await storageService.getAccounts();
    final exists = existingAccounts?.values
            .any((account) => account['privateKey'] == privateKey) ??
        false;
    return exists;
  }

  Future<String> getSeedPhraseAsString() async {
    if (state.seedPhrase == null) {
      throw Exception('Seed phrase is not available');
    }
    return state.seedPhrase!;
  }

  Future<List<String>> getSeedPhraseAsList() async {
    if (state.seedPhrase == null) {
      throw Exception('Seed phrase is not available');
    }
    return state.seedPhrase!.split(' ');
  }

  void clear() {
    state = TemporaryAccountState();
  }
}
