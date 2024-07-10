import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/providers/account_provider.dart';
import 'package:kibisis/providers/active_account_provider.dart';

class AccountHandler {
  final WidgetRef ref;

  AccountHandler(this.ref);

  Future<void> handleAccountSelection(String accountId) async {
    try {
      await ref
          .read(activeAccountProvider.notifier)
          .setActiveAccount(accountId);
      ref.invalidate(accountProvider);
      await ref.read(accountProvider.notifier).loadAccountFromPrivateKey();
    } catch (e) {
      debugPrint('Handle Account Selection: ${e.toString()}');
    }
  }
}
