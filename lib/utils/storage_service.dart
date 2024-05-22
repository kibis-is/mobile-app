// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// final sharedPreferencesProvider =
//     FutureProvider<SharedPreferences>((ref) async {
//   return await SharedPreferences.getInstance();
// });

// final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
//   return const FlutterSecureStorage();
// });

// // StorageService provider
// final storageProvider = Provider<StorageService>((ref) {
//   final prefs = ref.watch(sharedPreferencesProvider).maybeWhen(
//         data: (prefs) => prefs,
//         orElse: () => null,
//       );

//   final secureStorage = ref.watch(secureStorageProvider);

//   // Ensure SharedPreferences is ready before creating StorageService
//   if (prefs == null) {
//     throw UnimplementedError("SharedPreferences is not yet initialized");
//   }

//   return StorageService(prefs, secureStorage);
// });

// class StorageService {
//   final SharedPreferences _prefs;
//   final FlutterSecureStorage _secureStorage;
//   static const int _maxRetries = 3;
//   static const Duration _retryDelay = Duration(milliseconds: 200);

//   StorageService(this._prefs, this._secureStorage);

//   // Retry mechanism to handle potential file access issues
//   Future<T> _retryOnException<T>(
//     Future<T> Function() operation,
//     String errorMessage, {
//     T? returnOnError,
//   }) async {
//     for (int attempt = 0; attempt < _maxRetries; attempt++) {
//       try {
//         return await operation();
//       } catch (e, stacktrace) {
//         debugPrint('$errorMessage: $e');
//         debugPrint('Stacktrace: $stacktrace');
//         if (attempt < _maxRetries - 1) {
//           await Future.delayed(_retryDelay);
//         } else {
//           // Handle the error or rethrow it if necessary
//           return returnOnError ?? (throw e);
//         }
//       }
//     }
//     return returnOnError as T;
//   }

//   Future<void> setAccountName(String accountName) async {
//     await _prefs.setString('accountName', accountName);
//   }

//   Future<bool> accountExists() async {
//     return await _retryOnException(() async {
//       debugPrint('AccountExists');
//       bool privateKeyExists =
//           await _secureStorage.containsKey(key: 'privateKey');
//       bool seedPhraseExists =
//           await _secureStorage.containsKey(key: 'seedPhrase');
//       bool pinExists = await _secureStorage.containsKey(key: 'pin');
//       bool accountNameExists = _prefs.containsKey('accountName');
//       return privateKeyExists &&
//           accountNameExists &&
//           seedPhraseExists &&
//           pinExists;
//     }, 'Error checking account existence', returnOnError: false);
//   }

//   String? getAccountName() {
//     return _prefs.getString('accountName');
//   }

//   Future<void> setBalance(String balance) async {
//     await _prefs.setString('balance', balance);
//   }

//   String? getBalance() {
//     return _prefs.getString('balance');
//   }

//   Future<void> setPrivateKey(String privateKey) async {
//     await _retryOnException(() async {
//       await _secureStorage.write(key: 'privateKey', value: privateKey);
//     }, 'Error storing private key');
//   }

//   Future<String?> getPrivateKey() async {
//     return await _retryOnException(() async {
//       return await _secureStorage.read(key: 'privateKey');
//     }, 'Error reading private key', returnOnError: null);
//   }

//   Future<void> setSeedPhrase(String seedPhrase) async {
//     await _retryOnException(() async {
//       await _secureStorage.write(key: 'seedPhrase', value: seedPhrase);
//     }, 'Error storing seed phrase');
//   }

//   Future<String?> getSeedPhrase() async {
//     return await _retryOnException(() async {
//       return await _secureStorage.read(key: 'seedPhrase');
//     }, 'Error reading seed phrase', returnOnError: null);
//   }

//   Future<void> setError(String error) async {
//     await _prefs.setString('error', error);
//   }

//   String? getError() {
//     return _prefs.getString('error');
//   }

//   Future<void> setIsSetupComplete(bool isSetupComplete) async {
//     _prefs.setBool('isSetupComplete', isSetupComplete);
//   }

//   bool? getIsSetupComplete() {
//     return _prefs.getBool('isSetupComplete');
//   }

//   Future<void> setPinHash(String pinHash) async {
//     await _retryOnException(() async {
//       await _secureStorage.write(key: 'pin', value: pinHash);
//     }, 'Error storing pin hash');
//   }

//   Future<String?> getPinHash() async {
//     return await _retryOnException(() async {
//       return await _secureStorage.read(key: 'pin');
//     }, 'Error reading pin hash', returnOnError: null);
//   }

//   Future<void> clearAll() async {
//     await _retryOnException(() async {
//       await _prefs.clear();
//       await _secureStorage.deleteAll();
//     }, 'Error clearing all data');
//   }
// }
