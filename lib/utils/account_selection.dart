import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kibisis/providers/account_provider.dart';
import 'package:kibisis/providers/active_account_provider.dart';
import 'package:kibisis/utils/refresh_account_data.dart';

class AccountHandler {
  final BuildContext context;
  final WidgetRef ref;

  AccountHandler(this.context, this.ref);

  Future<void> handleAccountSelection(String accountId) async {
    GoRouter.of(context).go('/');
    await ref.read(activeAccountProvider.notifier).setActiveAccount(accountId);
    ref.invalidate(accountProvider);
    await ref.read(accountProvider.notifier).loadAccountFromPrivateKey();

    invalidateProviders(ref);
  }
}
