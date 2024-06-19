import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/features/dashboard/providers/transactions_provider.dart';
import 'package:kibisis/providers/account_provider.dart';
import 'package:kibisis/providers/assets_provider.dart';
import 'package:kibisis/providers/balance_provider.dart';

void refreshAccountData(
    BuildContext context, WidgetRef ref, String publicAddress) {
  if (publicAddress.isNotEmpty) {
    ref.invalidate(balanceProvider);
    ref.invalidate(assetsProvider);
    ref.invalidate(transactionsProvider);
    ref.invalidate(accountProvider);

    if (context.mounted) {
      ref.read(accountProvider);
    }
    if (context.mounted) {
      ref.read(assetsProvider.notifier).getAccountAssets(publicAddress);
    }
    if (context.mounted) {
      ref.read(balanceProvider);
    }
    if (context.mounted) {
      ref.read(transactionsProvider.notifier).getTransactions(publicAddress);
    }
  }
}
