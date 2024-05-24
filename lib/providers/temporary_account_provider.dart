import 'package:algorand_dart/algorand_dart.dart';
import 'package:convert/convert.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/providers/algorand_provider.dart';

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

  TemporaryAccountState({
    this.account,
    this.privateKey,
    this.seedPhrase,
  });

  TemporaryAccountState copyWith({
    Account? account,
    String? privateKey,
    String? seedPhrase,
  }) {
    return TemporaryAccountState(
      account: account ?? this.account,
      privateKey: privateKey ?? this.privateKey,
      seedPhrase: seedPhrase ?? this.seedPhrase,
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
      throw Exception('Failed to restore account: $e');
    }
  }

  Future<void> restoreAccountFromSeedPhrase(List<String> seedPhrase) async {
    try {
      final account = await algorand.restoreAccount(seedPhrase);
      final privateKeyBytes = await account.keyPair.extractPrivateKeyBytes();
      final encodedPrivateKey = hex.encode(privateKeyBytes);
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
      throw Exception('Failed to restore account: $e');
    }
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
