import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final sharedPreferencesProvider =
    FutureProvider<SharedPreferences>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs;
});

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true));
});

final storageProvider = Provider<StorageService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider).maybeWhen(
        data: (prefs) => prefs,
        orElse: () => null,
      );

  final secureStorage = ref.watch(secureStorageProvider);

  if (prefs == null) {
    return StorageService.initPending(secureStorage);
  }

  return StorageService(prefs, secureStorage);
});

class StorageService {
  final SharedPreferences? _prefs;
  final FlutterSecureStorage _secureStorage;
  static const int _maxRetries = 5;
  static const Duration _retryDelay = Duration(milliseconds: 400);

  StorageService(this._prefs, this._secureStorage);

  StorageService.initPending(this._secureStorage) : _prefs = null;

  Future<T> _retryOnException<T>(
    Future<T> Function() operation,
    String errorMessage, {
    T? returnOnError,
  }) async {
    for (int attempt = 0; attempt < _maxRetries; attempt++) {
      try {
        return await operation();
      } catch (e, stacktrace) {
        debugPrint('$errorMessage: $e');
        debugPrint('Stacktrace: $stacktrace');
        if (attempt < _maxRetries - 1) {
          await Future.delayed(_retryDelay);
        } else {
          return returnOnError ?? (throw e);
        }
      }
    }
    return returnOnError as T;
  }

  Future<void> setAccounts(Map<String, Map<String, String>> accounts) async {
    final accountsJson = jsonEncode(accounts);
    await _secureStorage.write(key: 'accounts', value: accountsJson);
  }

  Future<Map<String, Map<String, String>>?> getAccounts() async {
    for (int attempt = 0; attempt < _maxRetries; attempt++) {
      try {
        final accountsJson = await _secureStorage.read(key: 'accounts');
        if (accountsJson == null) return null;

        final decoded = jsonDecode(accountsJson) as Map<String, dynamic>;
        final accounts = decoded.map((key, value) => MapEntry(
              key,
              Map<String, String>.from(value as Map),
            ));

        return accounts;
      } catch (e) {
        if (attempt < _maxRetries - 1) {
          await Future.delayed(_retryDelay);
        } else {
          throw Exception('Failed to read accounts data: $e');
        }
      }
    }
    return null;
  }

  Future<void> setAccountData(
      String accountId, String key, String value) async {
    final accounts = await getAccounts() ?? {};
    accounts[accountId] = accounts[accountId] ?? {};
    accounts[accountId]![key] = value;
    await setAccounts(accounts);
  }

  Future<String?> getAccountData(String accountId, String key) async {
    final accounts = await getAccounts();
    if (accounts == null || !accounts.containsKey(accountId)) return null;
    return accounts[accountId]?[key];
  }

  Future<void> deleteAccount(String accountId) async {
    final accounts = await getAccounts() ?? {};
    accounts.remove(accountId);
    await setAccounts(accounts);
  }

  Future<void> setActiveAccount(String accountId) async {
    debugPrint('Setting Active Account: $accountId');
    await _prefs?.setString('activeAccount', accountId);
  }

  String? getActiveAccount() {
    try {
      return _prefs?.getString('activeAccount');
    } catch (e) {
      return '0';
    }
  }

  String? getDefaultNetwork() {
    return _prefs?.getString('defaultNetwork');
  }

  Future<void> setDefaultNetwork(String network) async {
    _prefs?.setString('defaultNetwork', network);
  }

//TODO:Decide if this is to be removed, no longer used
  Future<void> clearAll() async {
    await _retryOnException(() async {
      if (_prefs == null) {
        throw UnimplementedError("SharedPreferences is not yet initialized");
      }
      await _prefs.clear();
      await _secureStorage.deleteAll();
    }, 'Error clearing all data');
  }

  Future<void> clearOneByOne() async {
    try {
      final allKeys = await _secureStorage.readAll();
      for (String key in allKeys.keys) {
        await _secureStorage.delete(key: key);
      }
    } catch (e) {
      debugPrint('Error clearing secure storage: ${e.toString()}');
      rethrow;
    }
  }

  Future<String> generateNextAccountId() async {
    final accounts = await getAccounts();
    if (accounts == null || accounts.isEmpty) {
      return '0';
    }
    final highestId = accounts.keys
        .map((id) => int.parse(id))
        .reduce((a, b) => a > b ? a : b);
    return (highestId + 1).toString();
  }

  Future<String?> getPublicKey(String accountId) async {
    return await getAccountData(accountId, 'publicKey');
  }

  Future<void> setPinHash(String pinHash) async {
    await _retryOnException(() async {
      await _secureStorage.write(key: 'pinHash', value: pinHash);
    }, 'Error storing pin hash');
  }

  Future<String?> getPinHash() async {
    return await _retryOnException(() async {
      return await _secureStorage.read(key: 'pinHash');
    }, 'Error reading pin hash', returnOnError: null);
  }

  Future<void> clearPin() async {
    await _retryOnException(() async {
      await _secureStorage.delete(key: 'pinHash');
    }, 'Error clearing pin hash');
  }

  Future<bool> accountExists() async {
    final accounts = await getAccounts();
    return accounts != null && accounts.isNotEmpty;
  }

  Future<void> setError(String error) async {
    await _prefs?.setString('error', error);
  }

  String? getError() {
    return _prefs?.getString('error');
  }

  Future<String?> getAccountName(String accountId) async {
    return await getAccountData(accountId, 'accountName');
  }

  Future<String?> getPrivateKey(String accountId) async {
    return await getAccountData(accountId, 'privateKey');
  }

  Future<void> setLockTimeout(int seconds) async {
    await _prefs?.setInt('lockTimeout', seconds);
  }

  int? getLockTimeout() {
    return _prefs?.getInt('lockTimeout');
  }

  Future<void> setTimeoutEnabled(bool isEnabled) async {
    await _prefs?.setBool('timeoutEnabled', isEnabled);
  }

  bool? getTimeoutEnabled() {
    return _prefs?.getBool('timeoutEnabled');
  }

  Future<void> setIsDarkMode(bool isDarkMode) async {
    await _prefs?.setBool('isDarkMode', isDarkMode);
  }

  bool? getIsDarkMode() {
    return _prefs?.getBool('isDarkMode');
  }

  Future<void> setShowFrozenAssets(bool showFrozenAssets) async {
    await _prefs?.setBool('showFrozenAssets', showFrozenAssets);
  }

  bool? getShowFrozenAssets() {
    return _prefs?.getBool('showFrozenAssets');
  }

  Future<void> initialize() async {
    await SharedPreferences.getInstance();
    await const FlutterSecureStorage().readAll();
  }

  Future<void> setTransactionLastFetchTime(
      String accountId, int lastFetchTime) async {
    await _prefs?.setInt('lastTransactionFetchTime$accountId', lastFetchTime);
  }

  Future<int> getTransactionLastFetchTime(String accountId) async {
    final lastFetchTime =
        _prefs?.getInt('lastTransactionFetchTime$accountId') ?? 0;
    return lastFetchTime;
  }
}
