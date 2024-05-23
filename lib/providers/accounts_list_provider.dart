import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/providers/storage_provider.dart';

// Accounts List Provider
final accountsListProvider =
    FutureProvider<List<Map<String, String>>>((ref) async {
  final storageService = ref.read(storageProvider);
  final accountsMap = await storageService.getAccounts();

  // Convert the Map<String, Map<String, String>>? to a List<Map<String, String>>
  if (accountsMap == null) return [];

  final accountsList = accountsMap.entries.map((entry) {
    final accountId = entry.key;
    final accountData = entry.value;
    return {
      'accountId': accountId,
      ...accountData,
    };
  }).toList();

  // Debugging: Print accounts fetched from storage
  for (var account in accountsList) {
    debugPrint(
        'Fetched account: ${account['accountName']} with ID: ${account['accountId']}');
  }

  return accountsList;
});
