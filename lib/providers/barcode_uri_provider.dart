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
  await ref.read(accountsListProvider.notifier).loadAccountsWithPrivateKeys();
  final accounts = ref.read(accountsListProvider).accounts;

  if (accounts.isEmpty) {
    return [];
  }

  String allData = accounts
      .map((account) =>
          '${account['accountName'] ?? 'Unnamed Account'}${account['privateKey'] ?? '0'}')
      .join();
  String globalChecksum = md5.convert(utf8.encode(allData)).toString();

  List<List<Map<String, dynamic>>> accountChunks = chunkAccounts(accounts, 5);
  List<String> uris = [];
  int pageNumber = 1;
  int totalPages = accountChunks.length;

  for (var chunk in accountChunks) {
    StringBuffer uri = StringBuffer('avm://account/import?');
    List<String> params = [];

    for (var account in chunk) {
      params.add(buildURIParams(account['accountName'] ?? 'Unnamed Account',
          account['privateKey'] ?? '0'));
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
  Uint8List bytes = Uint8List.fromList(List.generate(hexPrivateKey.length ~/ 2,
      (i) => int.parse(hexPrivateKey.substring(i * 2, i * 2 + 2), radix: 16)));
  String base64PrivateKey = base64UrlEncode(bytes);
  assert(base64PrivateKey.length == 44,
      "The encoded key should be 44 characters long");
  return 'name=${Uri.encodeComponent(name)}&privatekey=$base64PrivateKey';
}

List<List<Map<String, dynamic>>> chunkAccounts(
    List<Map<String, dynamic>> accounts, int chunkSize) {
  List<List<Map<String, dynamic>>> chunks = [];
  for (int i = 0; i < accounts.length; i += chunkSize) {
    int end =
        (i + chunkSize < accounts.length) ? i + chunkSize : accounts.length;
    chunks.add(accounts.sublist(i, end));
  }
  return chunks;
}