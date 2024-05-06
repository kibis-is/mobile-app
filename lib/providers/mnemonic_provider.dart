import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:algorand_dart/algorand_dart.dart';

final algorandProvider = Provider<Algorand>((ref) => Algorand());
final walletManagerProvider =
    StateNotifierProvider<WalletManager, WalletState>((ref) {
  return WalletManager(ref.watch(algorandProvider));
});

class WalletState {
  final List<String> mnemonic;
  final String? balance;
  final bool isLoading;
  final String? error;
  final Account? currentAccount;

  WalletState({
    this.mnemonic = const [],
    this.balance,
    this.isLoading = false,
    this.error,
    this.currentAccount,
  });

  WalletState copyWith({
    List<String>? mnemonic,
    String? balance,
    bool? isLoading,
    String? error,
    Account? currentAccount,
  }) {
    return WalletState(
      mnemonic: mnemonic ?? this.mnemonic,
      balance: balance ?? this.balance,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      currentAccount: currentAccount ?? this.currentAccount,
    );
  }
}

class WalletManager extends StateNotifier<WalletState> {
  final Algorand algorand;

  WalletManager(this.algorand) : super(WalletState()) {
    createAccount();
  }

  Future<void> createAccount() async {
    state = state.copyWith(isLoading: true);
    try {
      final account = await algorand.createAccount();
      state = state.copyWith(
          mnemonic: await account.seedPhrase,
          currentAccount: account,
          isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> restoreAccount(List<String> mnemonic) async {
    state = state.copyWith(isLoading: true);
    try {
      final account = await algorand.restoreAccount(mnemonic);
      state = state.copyWith(currentAccount: account, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> loadAccountFromPrivateKey(String privateKey) async {
    state = state.copyWith(isLoading: true);
    try {
      final account = await algorand.loadAccountFromPrivateKey(privateKey);
      state = state.copyWith(currentAccount: account, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> sendPayment(String recipientAddress, double amount) async {
    state = state.copyWith(isLoading: true);
    try {
      final recipient = Address.fromAlgorandAddress(address: recipientAddress);
      final transactionId = await algorand.sendPayment(
          account: state.currentAccount!,
          recipient: recipient,
          amount: Algo.toMicroAlgos(amount));
      state = state.copyWith(isLoading: false);
      debugPrint("Transaction successful: $transactionId");
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> loadAccountBalance() async {
    if (state.currentAccount == null) return;

    state = state.copyWith(isLoading: true);
    try {
      final accountInfo = await algorand
          .getBalance(state.currentAccount!.address.encodedAddress);
      state = state.copyWith(balance: accountInfo.toString(), isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  String getConcatenatedMnemonic() {
    return state.mnemonic.join(' ');
  }
}
