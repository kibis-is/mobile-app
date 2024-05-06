import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Configuration for Android secure storage with encrypted SharedPreferences
AndroidOptions _getAndroidOptions() => const AndroidOptions(
      encryptedSharedPreferences: true,
    );

// Configuration for iOS secure storage to ensure data is available after first device unlock
IOSOptions _getIosOptions() => const IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    );

// Creating an instance of FlutterSecureStorage
final FlutterSecureStorage secureStorage = FlutterSecureStorage(
  aOptions: _getAndroidOptions(),
  iOptions: _getIosOptions(),
);
