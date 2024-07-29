import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/features/dashboard/providers/assets_fetched_provider.dart';
import 'package:kibisis/features/dashboard/providers/show_frozen_assets.dart';
import 'package:kibisis/features/dashboard/providers/transactions_provider.dart';
import 'package:kibisis/features/send_transaction/providers/selected_asset_provider.dart';
import 'package:kibisis/features/settings/appearance/providers/dark_mode_provider.dart';
import 'package:kibisis/providers/account_provider.dart';
import 'package:kibisis/providers/active_account_provider.dart';
import 'package:kibisis/providers/assets_provider.dart';
import 'package:kibisis/providers/authentication_provider.dart';
import 'package:kibisis/providers/balance_provider.dart';
import 'package:kibisis/providers/error_provider.dart';
import 'package:kibisis/providers/loading_provider.dart';
import 'package:kibisis/providers/pin_entry_provider.dart';
import 'package:kibisis/providers/pin_provider.dart';
import 'package:kibisis/providers/setup_complete_provider.dart';
import 'package:kibisis/providers/storage_provider.dart';
import 'package:kibisis/providers/temporary_account_provider.dart';

class AppResetUtil {
  static Future<void> resetApp(WidgetRef ref) async {
    try {
      ref.read(loadingProvider.notifier).startLoading();
      final storageService = ref.read(storageProvider);
      await storageService.clearAll();
      ref.invalidate(accountProvider);
      ref.invalidate(pinProvider);
      ref.invalidate(pinEntryStateNotifierProvider);
      ref.invalidate(errorProvider);
      ref.invalidate(activeAccountProvider);
      ref.invalidate(temporaryAccountProvider);
      ref.invalidate(balanceProvider);
      ref.invalidate(assetsProvider);
      ref.invalidate(transactionsProvider);
      ref.invalidate(accountProvider);
      ref.invalidate(storageProvider);
      ref.invalidate(selectedAssetProvider);
      ref.invalidate(isDarkModeProvider);
      ref.invalidate(showFrozenAssetsProvider);
      ref.read(accountDataFetchStatusProvider.notifier).setFetched(false);
      ref.read(setupCompleteProvider.notifier).setSetupComplete(false);
      ref.read(isAuthenticatedProvider.notifier).state = false;
    } catch (e) {
      debugPrint('Reset App: ${e.toString()}');
    } finally {
      ref.read(loadingProvider.notifier).stopLoading();
    }
  }
}
