// In account_provider.dart or a separate utilities file
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/providers/account_provider.dart';
import 'package:kibisis/providers/active_account_provider.dart';
import 'package:kibisis/providers/authentication_provider.dart';
import 'package:kibisis/providers/loading_provider.dart';
import 'package:kibisis/providers/setup_complete_provider.dart';
import 'package:kibisis/providers/storage_provider.dart';
import 'package:kibisis/providers/temporary_account_provider.dart';

// In utils/account_setup_utils.dart

Future<void> completeAccountSetup(
  WidgetRef ref,
  String accountName,
  bool isSetupFlow,
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

    // Clear the temporary account state
    ref.read(temporaryAccountProvider.notifier).clear();

    // Ensure the latest state is fetched
    await ref.refresh(storageProvider).accountExists();

    // Set setup complete and authenticate the user
    if (isSetupFlow) {
      ref.read(setupCompleteProvider.notifier).setSetupComplete(true);
      ref.read(isAuthenticatedProvider.notifier).state = true;
    }

    ref.read(loadingProvider.notifier).stopLoading();
  } catch (e) {
    ref.read(loadingProvider.notifier).stopLoading();
    debugPrint('Failed to complete account setup: $e');
  }
}
