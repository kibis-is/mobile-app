import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/features/dashboard/providers/transactions_provider.dart';
import 'package:kibisis/providers/account_provider.dart';
import 'package:kibisis/providers/assets_provider.dart';
import 'package:kibisis/providers/balance_provider.dart';

void refreshAccountData(
    BuildContext context, WidgetRef ref, String publicAddress) async {
  if (publicAddress.isNotEmpty) {
    if (context.mounted) {
      debugPrint('Fetching account details for public address: $publicAddress');
      await ref.read(accountProvider.notifier).loadAccountFromPrivateKey();
    }

    if (context.mounted) {
      debugPrint('Fetching assets for public address: $publicAddress');
      await ref.read(assetsProvider.notifier).getAccountAssets(publicAddress);
    }
    if (context.mounted) {
      debugPrint('Fetching balance for public address: $publicAddress');
      await ref
          .read(balanceProvider(publicAddress).notifier)
          .getBalance(publicAddress);
    }
    if (context.mounted) {
      debugPrint('Fetching transactions for public address: $publicAddress');
      await ref.read(transactionsProvider(publicAddress).future);
    }
  }
}
