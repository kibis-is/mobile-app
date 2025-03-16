import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/features/dashboard/providers/transactions_provider.dart';
import 'package:kibisis/features/pin_pad/providers/pin_title_provider.dart';
import 'package:kibisis/providers/accounts_list_provider.dart';
import 'package:kibisis/providers/active_asset_provider.dart';
import 'package:kibisis/providers/active_transaction_provider.dart';
import 'package:kibisis/providers/assets_provider.dart';
import 'package:kibisis/providers/balance_provider.dart';
import 'package:kibisis/providers/nft_provider.dart';

void invalidateProviders(WidgetRef ref) {
  ref.invalidate(nftNotifierProvider);
  ref.invalidate(balanceProvider);
  ref.invalidate(assetsProvider);
  ref.invalidate(transactionsProvider);
  ref.invalidate(pinTitleProvider);
  ref.invalidate(privateKeyAccountsProvider);
  ref.invalidate(activeAssetProvider);
  ref.invalidate(activeTransactionProvider);
  try {
    ref.invalidate(assetsProvider);
  } catch (e) {
    debugPrint('Provider already disposed: $e');
  }
}
