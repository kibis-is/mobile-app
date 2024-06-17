import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/providers/assets_provider.dart';
import 'package:kibisis/providers/balance_provider.dart';
import 'package:kibisis/providers/loading_provider.dart';

void refreshAccountData(WidgetRef ref, String publicAddress) async {
  ref.read(loadingProvider.notifier).startLoading(); // Start loading

  if (publicAddress.isNotEmpty) {
    debugPrint('Fetching assets for public address: $publicAddress');
    await ref.read(assetsProvider.notifier).getAccountAssets(publicAddress);

    debugPrint('Fetching balance for public address: $publicAddress');
    await ref.read(balanceProvider.notifier).getBalance(publicAddress);
  }

  ref.read(loadingProvider.notifier).stopLoading(); // Stop loading
}
