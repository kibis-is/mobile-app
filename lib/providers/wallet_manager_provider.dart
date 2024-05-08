import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:algorand_dart/algorand_dart.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:convert/convert.dart';
import 'package:kibisis/providers/app_lifecycle_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

final algorandProvider = Provider<Algorand>((ref) => Algorand());
final walletManagerProvider =
    StateNotifierProvider<WalletManager, WalletState>((ref) {
  return WalletManager(ref.watch(algorandProvider), ref);
});

class WalletState {
  final String? accountName;
  final List<String> mnemonic;
  final String? balance;
  final bool isLoading;
  final String? error;
  final Account? currentAccount;
  final String? pin;

  WalletState({
    this.accountName,
    this.mnemonic = const [],
    this.balance,
    this.isLoading = false,
    this.error,
    this.currentAccount,
    this.pin,
  });

  WalletState copyWith({
    String? accountName,
    List<String>? mnemonic,
    String? balance,
    bool? isLoading,
    String? error,
    Account? currentAccount,
    String? pin,
  }) {
    return WalletState(
      accountName: accountName ?? this.accountName,
      mnemonic: mnemonic ?? this.mnemonic,
      balance: balance ?? this.balance,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      currentAccount: currentAccount ?? this.currentAccount,
      pin: pin ?? this.pin,
    );
  }
}

class WalletManager extends StateNotifier<WalletState>
    with WidgetsBindingObserver {
  final StateNotifierProviderRef<WalletManager, WalletState> ref;
  final Algorand algorand;
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  SharedPreferences? _prefs;

  WalletManager(this.algorand, this.ref) : super(WalletState()) {
    debugPrint('Wallet Manager Initialising...');
    WidgetsBinding.instance.addObserver(this);
    init();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    final appLifecycleNotifier = ref.read(appLifecycleProvider.notifier);

    if (state == AppLifecycleState.paused) {
      appLifecycleNotifier.updateLastPausedTime(DateTime.now());
      debugPrint('App is paused - might clear or secure sensitive data here');
    } else if (state == AppLifecycleState.resumed) {
      final appState = ref.read(appLifecycleProvider);
      final lastPausedTime = appState.lastPausedTime;

      if (lastPausedTime != null &&
          DateTime.now().difference(lastPausedTime) >
              appState.timeoutDuration) {
        this.state = WalletState();
        debugPrint("Timeout exceeded, sensitive data cleared");
      }
      debugPrint(
          'App is resumed - might prompt for authentication or refresh data');
    }
  }

  @override
  dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> init() async {
    await _loadPreferences();
    bool walletExists = await hasAccountFromStorage();
    if (walletExists) {
      initializeAccount();
    } else {
      createAccount();
    }
  }

  Future<void> _loadPreferences() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<bool> hasAccountFromStorage() async {
    try {
      final existingAccount = _prefs?.getString('accountName');
      if (existingAccount != null) {
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error initializing wallet: $e');
      return false;
    }
  }

  Future<void> createAccount() async {
    try {
      state = state.copyWith(isLoading: true);
      final account = await algorand.createAccount();
      final mnemonicWords = await account.seedPhrase;
      final privateKeyBytes = await account.keyPair.extractPrivateKeyBytes();
      final privateKeyHex = hex.encode(privateKeyBytes);

      // Store sensitive data in secure storage
      await storage.write(key: 'privateKey', value: privateKeyHex);
      await storage.write(key: 'mnemonic', value: mnemonicWords.join(' '));

      // Also update the public address in shared preferences and state
      await _prefs?.setString(
          'publicAddress', account.publicAddress.toString());

      // Update state
      state = state.copyWith(
          mnemonic: mnemonicWords, currentAccount: account, isLoading: false);
      debugPrint('Create Account: Balance - ${state.balance}');
      debugPrint(
          'Create Account: Public Key - ${state.currentAccount?.publicKey}');
      debugPrint(
          'Create Account: Private Key - ${state.currentAccount?.keyPair}');
      debugPrint('Create Account: Mnemonic - ${state.mnemonic}');
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
      debugPrint('Create Account Error: $e');
    }
  }

  Future<void> finaliseAccount(String pin, String accountName) async {
    try {
      state = state.copyWith(isLoading: true);
      setPin(pin);
      await _prefs?.setString('accountName', accountName);
      state = state.copyWith(
        accountName: accountName,
        isLoading: false,
      );
      debugPrint('Account Finalised');
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> initializeAccount({String newAccountName = ''}) async {
    try {
      state = state.copyWith(isLoading: true);
      if (_prefs == null) await _loadPreferences();
      final pin = await storage.read(key: 'pin');
      final mnemonic = await storage.read(key: 'mnemonic');
      String? accountName = '';
      if (newAccountName != '') {
        accountName = newAccountName;
        _prefs?.setString('accountName', newAccountName);
      } else {
        accountName = _prefs!.getString('accountName');
      }

      // Fetch public address only if it's not already set in the state or is empty
      String? publicAddress = state.currentAccount?.publicAddress;
      if (publicAddress == null || publicAddress.isEmpty) {
        debugPrint('Public address null, populating...');
        publicAddress = _prefs?.getString('publicAddress');
      }

      if (mnemonic != null && pin != null) {
        List<String> mnemonicWords = mnemonic.split(' ');
        final account = await algorand.restoreAccount(mnemonicWords);

        state = state.copyWith(
          mnemonic: mnemonicWords,
          currentAccount: account,
          isLoading: false,
          accountName: accountName,
          pin: pin,
        );
        debugPrint('Initialize Wallet: ${state.toString()}');
        debugPrint('Initialize Wallet: Balance - ${state.balance}');
        debugPrint(
            'Initialize Wallet: Public Key - ${state.currentAccount?.publicKey}');
        debugPrint(
            'Initialize Wallet: Private Key - ${state.currentAccount?.keyPair}');
        debugPrint('Initialize Wallet: Mnemonic - ${state.mnemonic}');
        debugPrint('Initialize Wallet: Pin - ${state.pin}');
      } else {
        // Handle the case where there is no mnemonic or PIN available
        debugPrint(
            'Initialize Wallet: No account information available, attempting to create a new account.');
        await createAccount(); // Call to a function that creates a new account
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
      debugPrint('Initialize Wallet Error: $e');
    }
    state = state.copyWith(isLoading: false);
  }

  Future<void> setPin(String pin) async {
    String hashedPin = hashPin(pin);
    await storage.write(key: 'pin', value: hashedPin);
    state = state.copyWith(pin: hashedPin);
    debugPrint('Set Pin: $pin');
  }

  Future<bool> verifyPin(String enteredPin) async {
    String? storedHashedPin = await storage.read(key: 'pin');
    if (storedHashedPin == null) return false;
    String enteredHashedPin = hashPin(enteredPin);
    debugPrint('Verify Pin: ${storedHashedPin == enteredHashedPin}');
    return storedHashedPin == enteredHashedPin;
  }

  String hashPin(String pin) {
    var bytes = utf8.encode(pin);
    var digest = sha256.convert(bytes);
    debugPrint('Hash Pin: $digest');
    return digest.toString();
  }

  Future<bool> changePin(String oldPin, String newPin) async {
    try {
      state = state.copyWith(isLoading: true);
      bool isOldPinValid = await verifyPin(oldPin);
      if (isOldPinValid) {
        final newPinHash = hashPin(newPin);
        await storage.write(key: 'pin', value: newPinHash);
        state = state.copyWith(pin: newPinHash, isLoading: false);
        return true;
      } else {
        state = state.copyWith(error: "Pin did not match.", isLoading: false);
        return false;
      }
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
      debugPrint('Error changing PIN: $e');
      return false;
    }
  }

  Future<void> restoreAccount(List<String> mnemonic) async {
    try {
      state = state.copyWith(isLoading: true);
      final account = await algorand.restoreAccount(mnemonic);
      final privateKeyBytes = await account.keyPair.extractPrivateKeyBytes();
      final privateKeyHex = hex.encode(privateKeyBytes);

      // Store sensitive data securely
      await storage.write(key: 'privateKey', value: privateKeyHex);
      await storage.write(key: 'mnemonic', value: mnemonic.join(' '));

      // Update public address in shared preferences
      await _prefs?.setString(
          'publicAddress', account.publicAddress.toString());

      state = state.copyWith(currentAccount: account, isLoading: false);
      debugPrint('Restore Account: Balance - ${state.balance}');
      debugPrint(
          'Restore Account: Public Key - ${state.currentAccount?.publicKey}');
      debugPrint(
          'Restore Account: Private Key - ${state.currentAccount?.keyPair}');
      debugPrint('Restore Account: Mnemonic - ${state.mnemonic}');
      debugPrint('Restore Account: Pin - ${state.pin}');
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
      debugPrint('Restore Account Error: $e');
    }
  }

  Future<void> loadAccountFromPrivateKey(String privateKey) async {
    try {
      state = state.copyWith(isLoading: true);
      final account = await algorand.loadAccountFromPrivateKey(privateKey);
      state = state.copyWith(currentAccount: account, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> sendPayment(String recipientAddress, double amount) async {
    try {
      state = state.copyWith(isLoading: true);
      final recipient = Address.fromAlgorandAddress(address: recipientAddress);
      final transactionId = await algorand.sendPayment(
          account: state.currentAccount!,
          recipient: recipient,
          amount: Algo.toMicroAlgos(amount));
      state = state.copyWith(isLoading: false);
      debugPrint("Transaction successful: $transactionId");
    } catch (e) {
      debugPrint("Transaction failed: ${e.toString()}");
      state = state.copyWith(error: e.toString(), isLoading: false);
      return;
    }
  }

  Future<void> loadAccountBalance() async {
    state = state.copyWith(isLoading: true);
    if (state.currentAccount == null) {
      state = state.copyWith(
          error: "Public address not available.", isLoading: false);
      return;
    }
    try {
      final accountInfo = await algorand
          .getBalance(state.currentAccount!.address.encodedAddress);
      state = state.copyWith(balance: accountInfo.toString(), isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> resetWallet() async {
    try {
      if (Platform.isWindows) {
        // Windows does not support deleteAll(), delete each key one at a time
        List<String> keys = ['mnemonic', 'pin', 'privateKey'];
        for (var key in keys) {
          await storage.delete(key: key);
          if (await storage.read(key: key) == null) {
            debugPrint('Reset Wallet: $key confirm deleted.');
          }
        }
      } else {
        await storage.deleteAll();
        debugPrint('Reset Wallet: All keys deleted.');
      }

      // Clear all data from shared preferences
      await _prefs?.clear();

      state = WalletState();
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  String getConcatenatedMnemonic() {
    return state.mnemonic.join(' ');
  }

  Future<String> getPublicAddress() async {
    return _prefs?.getString('publicAddress') ?? "Address not available";
  }
}
