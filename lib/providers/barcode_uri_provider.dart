import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/generated/l10n.dart';
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
    final accountName = account['accountName'] ?? S.current.unnamedAccount;
    final privateKey =
        await storageService.getAccountData(accountId ?? '', 'privateKey');
    if (privateKey == null || privateKey.isEmpty) {
      continue;
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

  List<String> uris = [];
  int totalPages = accountChunks.length;

  for (int pageNumber = 1; pageNumber <= totalPages; pageNumber++) {
    final chunk = accountChunks[pageNumber - 1];
    final StringBuffer uri = StringBuffer('avm://account/import?');
    final List<String> params = [];

    for (var account in chunk) {
      final accountName = account['accountName'] ?? S.current.unnamedAccount;
      final privateKey = account['privateKey'];

      params.add(buildURIParams(accountName, privateKey));
    }

    if (params.isEmpty) {
      continue;
    }
    uri.write(params.join('&'));

    if (totalPages > 1) {
      final String allData = accountDataList.join();
      final String globalChecksum =
          md5.convert(utf8.encode(allData)).toString();
      uri.write('&checksum=$globalChecksum&page=$pageNumber:$totalPages');
    }
    uris.add(uri.toString());
  }

  return uris;
}

Future<String> generateSingleAccountURI(Ref ref, String accountId) async {
  final storageService = ref.read(storageProvider);
  final accountName =
      await storageService.getAccountData(accountId, 'accountName') ??
          S.current.unnamedAccount;
  final privateKey =
      await storageService.getAccountData(accountId, 'privateKey');

  if (privateKey == null || privateKey.isEmpty) {
    throw Exception(S.current.privateKeyNotFoundForAccount(accountId));
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
  final Uint8List bytes = Uint8List.fromList(List.generate(
    hexPrivateKey.length ~/ 2,
    (i) => int.parse(hexPrivateKey.substring(i * 2, i * 2 + 2), radix: 16),
  ));

  final String base64PrivateKey = base64UrlEncode(bytes);

  assert(
    base64PrivateKey.length == 44,
    S.current.invalidEncodedKeyLength,
  );

  return 'name=${Uri.encodeComponent(name)}&privatekey=$base64PrivateKey';
}
