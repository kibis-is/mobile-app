import 'package:algorand_dart/algorand_dart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/providers/account_provider.dart';
import 'package:kibisis/providers/accounts_list_provider.dart';
import 'package:kibisis/providers/algorand_provider.dart';
import 'package:kibisis/providers/authentication_provider.dart';
import 'package:kibisis/providers/setup_complete_provider.dart';
import 'package:kibisis/providers/storage_provider.dart';
import 'package:kibisis/providers/temporary_account_provider.dart';
import 'package:kibisis/utils/account_selection.dart';

class AccountSetupUtility {
  static Future<void> completeAccountSetup({
    required WidgetRef ref,
    required String accountName,
    required AccountFlow accountFlow,
    required bool setFinalState,
  }) async {
    try {
      await ref
          .read(accountProvider.notifier)
          .finalizeAccountCreation(accountName);
      await _handleAccountPostSetup(ref, accountFlow, setFinalState);
      //TODO:  Deploy smart contract
      // await _deploySmartContract(ref);
      await _handleCleanUp(ref, accountFlow, setFinalState);
    } catch (e) {
      debugPrint('Failed to complete account setup: $e');
      throw Exception('Failed to complete account setup: ${e.toString()}');
    }
  }

  static Future<void> _handleAccountPostSetup(
      WidgetRef ref, AccountFlow accountFlow, bool setFinalState) async {
    final newAccountId =
        await ref.read(accountProvider.notifier).getAccountId() ?? '';

    await ref.read(accountsListProvider.notifier).loadAccounts();

    if (newAccountId.isNotEmpty) {
      final accountHandler = AccountHandler(ref);
      accountHandler.handleAccountSelection(newAccountId);
    }
  }

  static Future<void> _handleCleanUp(
      WidgetRef ref, AccountFlow accountFlow, bool setFinalState) async {
    ref.read(temporaryAccountProvider.notifier).reset();
    await ref.refresh(storageProvider).accountExists();
    if (accountFlow == AccountFlow.setup && setFinalState) {
      ref.read(isAuthenticatedProvider.notifier).state = true;
      await ref.read(setupCompleteProvider.notifier).setSetupComplete(true);
    }
  }

  static Future<Account?> _getActiveAccount(WidgetRef ref) async {
    const maxRetries = 5;
    for (int i = 0; i < maxRetries; i++) {
      final account = ref.read(accountProvider).account;
      if (account != null) {
        return account;
      }
      await Future.delayed(const Duration(seconds: 1));
    }
    return null;
  }

  static Future<void> _deploySmartContract(WidgetRef ref) async {
    try {
      final account = await _getActiveAccount(ref);
      if (account == null) {
        throw Exception('No active account available for contract deployment');
      }

      final applicationId =
          await ref.read(algorandServiceProvider).deployContract(account);

      // Save the applicationId in the storage
      final accountId = ref.read(accountProvider).accountId;
      if (accountId != null) {
        await ref.read(storageProvider).setAccountData(
            accountId, 'applicationId', applicationId.toString());
      }
    } catch (e) {
      debugPrint('Failed to deploy smart contract: $e');
      throw Exception('Failed to deploy smart contract: $e');
    }
  }
}