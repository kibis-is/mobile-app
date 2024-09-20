import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/providers/accounts_list_provider.dart';
import 'package:kibisis/providers/storage_provider.dart';

final barcodeUriProvider = FutureProvider.autoDispose
    .family<List<String>, String?>((ref, accountId) async {
  if (accountId == 'all') {
    return await generateAllAccountURIs(ref);
  } else if (accountId != null) {
    return [await generateSingleAccountURI(ref, accountId)];
  }
  return [];
});

Future<List<String>> generateAllAccountURIs(Ref ref) async {
  await ref.read(accountsListProvider.notifier).loadAccounts();
  final accounts = ref.read(accountsListProvider).accounts;

  if (accounts.isEmpty) {
    return [];
  }

  final storageService = ref.read(storageProvider);
  List<String> accountDataList = [];
  List<List<Map<String, dynamic>>> accountChunks = [];
  const int chunkSize = 5;
  for (int i = 0; i < accounts.length; i++) {
    final account = accounts[i];
    final accountId = account['accountId'];
    final accountName = account['accountName'] ?? 'Unnamed Account';
    final privateKey =
        await storageService.getAccountData(accountId ?? '', 'privateKey');
    if (privateKey == null || privateKey.isEmpty) {
      continue; // Skip if private key not found
    }
    accountDataList.add('$accountName$privateKey');
    if (accountChunks.isEmpty || accountChunks.last.length >= chunkSize) {
      accountChunks.add([]);
    }
    accountChunks.last.add({
      'accountName': accountName,
      'privateKey': privateKey,
    });
  }

  if (accountDataList.isEmpty) {
    return [];
  }

  final String allData = accountDataList.join();
  final String globalChecksum = md5.convert(utf8.encode(allData)).toString();

  List<String> uris = [];
  int pageNumber = 1;
  final int totalPages = accountChunks.length;

  for (var chunk in accountChunks) {
    final StringBuffer uri = StringBuffer('avm://account/import?');
    final List<String> params = [];

    for (var account in chunk) {
      final accountName = account['accountName'] ?? 'Unnamed Account';
      final privateKey = account['privateKey'];

      params.add(buildURIParams(accountName, privateKey));
    }

    if (params.isEmpty) {
      continue;
    }

    uri.write(params.join('&'));

    uri.write('&checksum=$globalChecksum&page=$pageNumber:$totalPages');
    uris.add(uri.toString());
    pageNumber++;
  }

  return uris;
}

Future<String> generateSingleAccountURI(Ref ref, String accountId) async {
  final storageService = ref.read(storageProvider);
  final accountName =
      await storageService.getAccountData(accountId, 'accountName') ??
          'Unnamed Account';
  final privateKey =
      await storageService.getAccountData(accountId, 'privateKey');

  if (privateKey == null || privateKey.isEmpty) {
    throw Exception('Private key not found for account ID: $accountId');
  }

  return buildURI(name: accountName, privateKey: privateKey);
}

String buildURI({
  String base = 'avm://account/import?',
  required String name,
  required String privateKey,
}) {
  return '$base${buildURIParams(name, privateKey)}';
}

String buildURIParams(String name, String hexPrivateKey) {
  // Convert hexPrivateKey to bytes
  final Uint8List bytes = Uint8List.fromList(List.generate(
    hexPrivateKey.length ~/ 2,
    (i) => int.parse(hexPrivateKey.substring(i * 2, i * 2 + 2), radix: 16),
  ));

  // Encode to base64 URL-safe string
  final String base64PrivateKey = base64UrlEncode(bytes);

  // Ensure the encoded key is the expected length
  assert(base64PrivateKey.length == 44,
      'The encoded key should be 44 characters long');

  return 'name=${Uri.encodeComponent(name)}&privatekey=$base64PrivateKey';
}
