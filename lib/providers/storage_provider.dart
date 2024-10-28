import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/models/contact.dart';
import 'package:kibisis/models/nft.dart';
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
  String? _cachedActiveAccount;
  static const int _maxRetries = 5;
  static const Duration _retryDelay = Duration(milliseconds: 400);
  static const String _arc200FollowedAssetsKey = 'arc200_followed_assets';

  StorageService(this._prefs, this._secureStorage);

  static const String _sessionsKey = 'walletconnect_sessions';

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

  SharedPreferences? get prefs => _prefs;

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
    await _prefs?.remove('nfts_$accountId');
    await setAccounts(accounts);
  }

  Future<void> setActiveAccount(String accountId) async {
    _cachedActiveAccount = accountId;
    await _prefs?.setString('activeAccount', accountId);
  }

  Future<String?> getActiveAccount() async {
    if (_cachedActiveAccount != null) return _cachedActiveAccount;

    _cachedActiveAccount = _prefs?.getString('activeAccount');
    return _cachedActiveAccount;
  }

  String? getDefaultNetwork() {
    return _prefs?.getString('defaultNetwork');
  }

  Future<void> setDefaultNetwork(String network) async {
    _prefs?.setString('defaultNetwork', network);
  }

  Future<void> clearAll() async {
    await _retryOnException(() async {
      if (_prefs == null) {
        throw UnimplementedError("SharedPreferences is not yet initialized");
      }
      await _prefs.clear();
      await _secureStorage.deleteAll();
    }, 'Error clearing all data');
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

  Future<void> setApplicationId(String accountId, String applicationId) async {
    await setAccountData(accountId, 'applicationId', applicationId);
  }

  Future<String?> getApplicationId(String accountId) async {
    return await getAccountData(accountId, 'applicationId');
  }

  Future<void> saveSessions(List<Map<String, dynamic>> sessions) async {
    final sessionsJson =
        sessions.map((session) => jsonEncode(session)).toList();
    await _retryOnException(
      () async => _prefs?.setStringList(_sessionsKey, sessionsJson),
      'Failed to save sessions',
    );
  }

  Future<List<Map<String, dynamic>>> getSessions() async {
    final sessionsJson = await _retryOnException(
      () async => _prefs?.getStringList(_sessionsKey),
      'Failed to retrieve sessions',
    );
    if (sessionsJson == null) {
      return [];
    }
    return sessionsJson
        .map((sessionString) =>
            jsonDecode(sessionString) as Map<String, dynamic>)
        .toList();
  }

  Future<void> removeSessions() async {
    await _retryOnException(
      () async => _prefs?.remove(_sessionsKey),
      'Failed to remove sessions',
    );
  }

  Future<void> removeSessionByTopic(String topic) async {
    final sessions = await getSessions();
    sessions.removeWhere((session) => session['topic'] == topic);
    await saveSessions(sessions);
  }

  Future<void> setNFTsForAccount(String accountId, List<NFT> nfts) async {
    final encodedNfts = jsonEncode(nfts.map((nft) => nft.toJson()).toList());
    await _prefs?.setString('nfts_$accountId', encodedNfts);
  }

  Future<List<NFT>> getNFTsForAccount(String accountId) async {
    final cachedNftsJson = _prefs?.getString('nfts_$accountId');
    if (cachedNftsJson == null) {
      return [];
    }

    final List<dynamic> cachedNfts = json.decode(cachedNftsJson);
    return cachedNfts.map<NFT>((json) => NFT.fromJson(json)).toList();
  }

  Future<void> clearNFTsForAccount(String accountId) async {
    await _prefs?.remove('nfts_$accountId');
  }

  static const String _contactsKey = 'contacts';

  Future<List<Contact>> getContacts() async {
    final contactsJson = _prefs?.getStringList(_contactsKey) ?? [];
    return contactsJson.map((contactString) {
      final jsonData = jsonDecode(contactString);
      return Contact.fromJson(jsonData);
    }).toList();
  }

  Future<void> saveContacts(List<Contact> contacts) async {
    final contactsJson =
        contacts.map((contact) => jsonEncode(contact.toJson())).toList();
    await _prefs?.setStringList(_contactsKey, contactsJson);
  }

  Future<void> addContact(Contact contact) async {
    final contacts = await getContacts();
    contacts.add(contact);
    await saveContacts(contacts);
  }

  Future<void> removeContact(String contactId) async {
    final contacts = await getContacts();
    contacts.removeWhere((contact) => contact.id == contactId);
    await saveContacts(contacts);
  }

  static const String _showTestNetworksKey = 'showTestNetworks';

  Future<void> setShowTestNetworks(bool show) async {
    if (_prefs == null) {
      throw Exception("SharedPreferences is not initialized");
    }
    await _prefs.setBool(_showTestNetworksKey, show);
  }

  bool getShowTestNetworks() {
    return _prefs?.getBool(_showTestNetworksKey) ?? false;
  }

  Future<void> followArc200Asset(String accountId, int assetId) async {
    final followedAssets = await getFollowedArc200Assets(accountId);
    if (!followedAssets.contains(assetId)) {
      followedAssets.add(assetId);
      await _prefs?.setStringList(
        '${_arc200FollowedAssetsKey}_$accountId',
        followedAssets.map((id) => id.toString()).toList(),
      );
    }
  }

  Future<void> unfollowArc200Asset(String accountId, int assetId) async {
    final followedAssets = await getFollowedArc200Assets(accountId);
    followedAssets.remove(assetId);
    await _prefs?.setStringList(
      '${_arc200FollowedAssetsKey}_$accountId',
      followedAssets.map((id) => id.toString()).toList(),
    );
  }

  Future<List<int>> getFollowedArc200Assets(String accountId) async {
    final followedAssets =
        _prefs?.getStringList('${_arc200FollowedAssetsKey}_$accountId') ?? [];
    return followedAssets.map((id) => int.parse(id)).toList();
  }
}
