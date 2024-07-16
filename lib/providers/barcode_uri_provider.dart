import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/providers/accounts_list_provider.dart';
import 'package:kibisis/providers/storage_provider.dart';

final barcodeUriProvider =
    FutureProvider.autoDispose.family<String, String?>((ref, accountId) async {
  if (accountId == 'all') {
    return await generateAllAccountURIs(ref);
  } else if (accountId != null) {
    return await generateSingleAccountURI(ref, accountId);
  }
  return '';
});

Future<String> generateAllAccountURIs(Ref ref) async {
  await ref.read(accountsListProvider.notifier).loadAccountsWithPrivateKeys();
  final accounts = ref.read(accountsListProvider).accounts;

  if (accounts.isEmpty) {
    return '';
  }

  final firstAccount = accounts.first;
  final StringBuffer uri = StringBuffer(buildURI(
      name: firstAccount['accountName'] ?? 'Unnamed Account',
      privateKey: firstAccount['privateKey'] ?? '0'));

  for (int i = 1; i < accounts.length; i++) {
    var account = accounts[i];
    uri.write('&');
    uri.write(buildURIParams(account['accountName'] ?? 'Unnamed Account',
        account['privateKey'] ?? '0'));
  }

  final uriString = uri.toString();
  debugPrint(uriString);
  return uriString;
}

Future<String> generateSingleAccountURI(Ref ref, String accountId) async {
  final storageService = ref.read(storageProvider);
  final accountName =
      await storageService.getAccountData(accountId, 'accountName') ??
          'Unnamed Account';
  final privateKey =
      await storageService.getPrivateKey(accountId) ?? 'No Private Key';
  return buildURI(name: accountName, privateKey: privateKey);
}

String buildURI(
    {String base = 'avm://account/import?',
    required String name,
    required String privateKey}) {
  return '$base${buildURIParams(name, privateKey)}';
}

String buildURIParams(String name, String hexPrivateKey) {
  // Convert hex string to bytes
  Uint8List bytes = Uint8List.fromList(List.generate(hexPrivateKey.length ~/ 2,
      (i) => int.parse(hexPrivateKey.substring(i * 2, i * 2 + 2), radix: 16)));

  // Encode bytes to base64 URL safe format
  String base64PrivateKey = base64UrlEncode(bytes);

  // Ensure the private key is the correct length
  assert(base64PrivateKey.length == 44,
      "The encoded key should be 44 characters long");

  return 'name=${Uri.encodeComponent(name)}&privatekey=$base64PrivateKey';
}
