import 'package:convert/convert.dart';
import 'package:algorand_dart/algorand_dart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/providers/algorand_provider.dart';
import 'package:kibisis/providers/storage_provider.dart';
import 'package:kibisis/utils/hex_coverter.dart';

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
  final String? accountName;

  TemporaryAccountState({
    this.account,
    this.privateKey,
    this.seedPhrase,
    this.accountName,
  });

  TemporaryAccountState copyWith({
    Account? account,
    String? privateKey,
    String? seedPhrase,
    String? accountName,
  }) {
    return TemporaryAccountState(
      account: account ?? this.account,
      privateKey: privateKey ?? this.privateKey,
      seedPhrase: seedPhrase ?? this.seedPhrase,
      accountName: accountName ?? this.accountName,
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

  Future<void> restoreAccountFromPrivateKey(String privateKeyInput) async {
    try {
      // Use the HexConverter to convert the input to hexadecimal
      final hexPrivateKey = HexConverter.convertToHex(privateKeyInput);

      // Check if the account already exists
      final accountExists = await accountAlreadyExists(hexPrivateKey);
      if (accountExists) {
        throw Exception('Account already added.');
      }

      // Load the account using the hexadecimal private key
      final account = await algorand.loadAccountFromPrivateKey(hexPrivateKey);

      // Extract the seed phrase from the account
      final seedPhrase = await account.seedPhrase;
      final seedPhraseString = seedPhrase.join(' ');

      // Update the state with the account details
      state = state.copyWith(
        account: account,
        privateKey: hexPrivateKey,
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
      throw Exception('Failed to restore account: ${e.toString()}');
    }
  }

  Future<void> restoreAccountFromSeedPhrase(List<String> seedPhrase) async {
    try {
      final account = await algorand.restoreAccount(seedPhrase);
      final privateKeyBytes = await account.keyPair.extractPrivateKeyBytes();
      final encodedPrivateKey = hex.encode(privateKeyBytes);

      final accountExists = await accountAlreadyExists(encodedPrivateKey);
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
      final account = await Account.fromSeed(seed);
      final hexPrivateKey = hex.encode(seed);
      final accountExists = await accountAlreadyExists(hexPrivateKey);
      if (accountExists) {
        throw Exception('Account already added.');
      }
      final seedPhrase = await account.seedPhrase;
      final seedPhraseString = seedPhrase.join(' ');
      state = state.copyWith(
        account: account,
        accountName: name,
        privateKey: hexPrivateKey,
        seedPhrase: seedPhraseString,
      );
    } on AlgorandException catch (e) {
      state = state.copyWith(
        account: null,
        accountName: null,
        privateKey: null,
        seedPhrase: null,
      );
      throw Exception(e.message);
    } catch (e) {
      state = state.copyWith(
        account: null,
        accountName: null,
        privateKey: null,
        seedPhrase: null,
      );
      throw Exception(e);
    }
  }

  Future<bool> accountAlreadyExists(String privateKey) async {
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

  void reset() {
    state = TemporaryAccountState();
  }
}
