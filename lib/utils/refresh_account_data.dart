import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/features/dashboard/providers/transactions_provider.dart';
import 'package:kibisis/providers/account_provider.dart';
import 'package:kibisis/providers/assets_provider.dart';
import 'package:kibisis/providers/balance_provider.dart';
import 'package:kibisis/providers/loading_provider.dart';

void refreshAccountData(WidgetRef ref, String publicAddress) async {
  ref.read(loadingProvider.notifier).startLoading();

  if (publicAddress.isNotEmpty) {
    debugPrint('Fetching account details for public address: $publicAddress');
    await ref.read(accountProvider.notifier).loadAccountFromPrivateKey();

    debugPrint('Fetching assets for public address: $publicAddress');
    await ref.read(assetsProvider.notifier).getAccountAssets(publicAddress);

    debugPrint('Fetching balance for public address: $publicAddress');
    await ref.read(balanceProvider.notifier).getBalance(publicAddress);

    debugPrint('Fetching transactions for public address: $publicAddress');
    await ref.read(transactionsProvider(publicAddress).future);
  }

  ref.read(loadingProvider.notifier).stopLoading();
}
