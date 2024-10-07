import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/features/dashboard/providers/assets_fetched_provider.dart';
import 'package:kibisis/features/dashboard/providers/show_frozen_assets.dart';
import 'package:kibisis/features/dashboard/providers/transactions_provider.dart';
import 'package:kibisis/features/scan_qr/scan_qr_screen.dart';
import 'package:kibisis/features/scan_qr/widgets/progress_bar.dart';
import 'package:kibisis/features/send_transaction/providers/selected_asset_provider.dart';
import 'package:kibisis/features/send_transaction/send_transaction_screen.dart';
import 'package:kibisis/features/settings/appearance/providers/dark_mode_provider.dart';
import 'package:kibisis/providers/account_provider.dart';
import 'package:kibisis/providers/active_account_provider.dart';
import 'package:kibisis/providers/assets_provider.dart';
import 'package:kibisis/providers/authentication_provider.dart';
import 'package:kibisis/providers/balance_provider.dart';
import 'package:kibisis/providers/contacts_provider.dart';
import 'package:kibisis/providers/error_provider.dart';
import 'package:kibisis/providers/multipart_scan_provider.dart';
import 'package:kibisis/providers/pin_entry_provider.dart';
import 'package:kibisis/providers/pin_provider.dart';
import 'package:kibisis/providers/setup_complete_provider.dart';
import 'package:kibisis/providers/storage_provider.dart';
import 'package:kibisis/providers/temporary_account_provider.dart';
import 'package:kibisis/utils/wallet_connect_manageer.dart';

class AppResetUtil {
  static Future<void> resetApp(WidgetRef ref) async {
    try {
      debugPrint('Starting reset process...');

      await _disconnectAllSessions(ref);

      await _clearStorage(ref);
      _invalidateProviders(ref);
      _resetExplicitProviders(ref);

      debugPrint('Reset process completed.');
    } catch (e, stackTrace) {
      debugPrint('Error during reset process: $e');
      debugPrint('Stack trace: $stackTrace');
      throw Exception('Reset app failed: $e');
    }
  }

  static Future<void> _disconnectAllSessions(WidgetRef ref) async {
    final storageService = ref.read(storageProvider);
    final walletConnectManager = WalletConnectManager(storageService);

    try {
      await walletConnectManager.disconnectAllSessions();
      debugPrint('All WalletConnect sessions disconnected.');
    } catch (e) {
      debugPrint('Error disconnecting WalletConnect sessions: $e');
      throw Exception('Failed to disconnect WalletConnect sessions: $e');
    }
  }

  // Clear secure storage
  static Future<void> _clearStorage(WidgetRef ref) async {
    final storageService = ref.read(storageProvider);
    try {
      await storageService.clearOneByOne();
      debugPrint('Storage cleared successfully.');
    } catch (e) {
      debugPrint('Error clearing storage: $e');
      throw Exception('Failed to clear storage: $e');
    }

    ref.invalidate(storageProvider);
  }

  static void _invalidateProviders(WidgetRef ref) {
    ref.invalidate(accountProvider);
    ref.invalidate(pinProvider);
    ref.invalidate(pinEntryStateNotifierProvider);
    ref.invalidate(activeAccountProvider);
    ref.invalidate(temporaryAccountProvider);
    ref.invalidate(balanceProvider);
    ref.invalidate(assetsProvider(''));
    ref.invalidate(transactionsProvider);
    ref.invalidate(selectedAssetProvider);
    ref.invalidate(isDarkModeProvider);
    ref.invalidate(showFrozenAssetsProvider);
    ref.invalidate(multipartScanProvider);
    ref.invalidate(progressBarProvider);
    ref.invalidate(isPaginatedScanProvider);
    ref.invalidate(dropdownItemsProvider);
    ref.invalidate(contactsListProvider);
    ref.invalidate(sendTransactionScreenModeProvider);
  }

  static void _resetExplicitProviders(WidgetRef ref) {
    ref.read(isAuthenticatedProvider.notifier).state = false;
    ref.read(errorProvider.notifier).state = '';
    ref.read(setupCompleteProvider.notifier).setSetupComplete(false);
    ref.read(accountDataFetchStatusProvider.notifier).setFetched(false);
  }
}
