import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/generated/l10n.dart';
import 'package:kibisis/providers/account_provider.dart';
import 'package:kibisis/providers/active_account_provider.dart';
import 'package:kibisis/providers/error_provider.dart';
import 'package:kibisis/providers/storage_provider.dart';
import 'package:kibisis/utils/refresh_account_data.dart';

class AccountHandler {
  final WidgetRef ref;

  AccountHandler(this.ref);

  Future<void> handleAccountSelection(String accountId) async {
    try {
      final activeAccountId = ref.watch(activeAccountProvider);
      if (accountId == activeAccountId) return;
      await ref
          .read(activeAccountProvider.notifier)
          .setActiveAccount(accountId);
      final accountName =
          await ref.read(storageProvider).getAccountName(accountId);

      if (accountName == null || accountName.isEmpty) {
        throw Exception(S.current.accountNameNotFoundForId(accountId));
      }

      ref.invalidate(accountProvider);

      await ref
          .read(accountProvider.notifier)
          .initialiseFromPublicKey(accountName, accountId);
      invalidateProviders(ref);
    } catch (e) {
      debugPrint('Handle Account Selection Error: ${e.toString()}');
      ref.read(errorProvider.notifier).state =
          S.current.failedToSelectAccount(e.toString());
    }
  }
}
