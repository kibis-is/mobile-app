import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/providers/account_provider.dart';
import 'package:kibisis/providers/accounts_list_provider.dart';
import 'package:kibisis/providers/active_account_provider.dart';
import 'package:kibisis/providers/authentication_provider.dart';
import 'package:kibisis/providers/loading_provider.dart';
import 'package:kibisis/providers/setup_complete_provider.dart';
import 'package:kibisis/providers/storage_provider.dart';
import 'package:kibisis/providers/temporary_account_provider.dart';

Future<void> completeAccountSetup(
  WidgetRef ref,
  String accountName,
  AccountFlow accountFlow,
) async {
  try {
    ref.read(loadingProvider.notifier).startLoading();

    await ref
        .read(accountProvider.notifier)
        .finalizeAccountCreation(accountName);

    // Set the newly created account as the active account
    final newAccountId =
        await ref.read(accountProvider.notifier).getAccountId();
    if (newAccountId != null) {
      await ref
          .read(activeAccountProvider.notifier)
          .setActiveAccount(newAccountId);
    }

    // Refresh the accounts list
    await ref.read(accountsListProvider.notifier).refreshAccounts();

    if (accountFlow == AccountFlow.setup) {
      ref.read(isAuthenticatedProvider.notifier).state = true;
      await ref.read(setupCompleteProvider.notifier).setSetupComplete(true);
    }

    // Clear the temporary account state
    ref.read(temporaryAccountProvider.notifier).clear();

    // Ensure the latest state is fetched
    await ref.refresh(storageProvider).accountExists();

    ref.read(loadingProvider.notifier).stopLoading();
  } catch (e) {
    ref.read(loadingProvider.notifier).stopLoading();
    debugPrint('Failed to complete account setup: $e');
  }
}
