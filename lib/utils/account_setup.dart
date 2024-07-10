import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/providers/account_provider.dart';
import 'package:kibisis/providers/accounts_list_provider.dart';
import 'package:kibisis/providers/authentication_provider.dart';
import 'package:kibisis/providers/setup_complete_provider.dart';
import 'package:kibisis/providers/storage_provider.dart';
import 'package:kibisis/providers/temporary_account_provider.dart';
import 'package:kibisis/utils/account_selection.dart';
import 'package:kibisis/utils/refresh_account_data.dart';

class AccountSetupUtility {
  static Future<void> completeAccountSetup(
      WidgetRef ref, String accountName, AccountFlow accountFlow) async {
    try {
      invalidateProviders(ref);
      await ref
          .read(accountProvider.notifier)
          .finalizeAccountCreation(accountName);
      final newAccountId =
          await ref.read(accountProvider.notifier).getAccountId() ?? '';

      await ref.read(accountsListProvider.notifier).loadAccounts();

      if (accountFlow == AccountFlow.setup) {
        ref.read(isAuthenticatedProvider.notifier).state = true;
        await ref.read(setupCompleteProvider.notifier).setSetupComplete(true);
      }

      ref.read(temporaryAccountProvider.notifier).clear();

      await ref.refresh(storageProvider).accountExists();

      if (newAccountId.isNotEmpty) {
        final accountHandler = AccountHandler(ref);
        accountHandler.handleAccountSelection(newAccountId);
      }

      invalidateProviders(ref);
    } catch (e) {
      debugPrint('Failed to complete account setup: $e');
      throw Exception('Failed to complete account setup: ${e.toString()}');
    }
  }
}
