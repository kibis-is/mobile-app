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
      await _resetProvidersInBatches(ref);
      _resetSimpleProviders(ref);

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

  static Future<void> _clearStorage(WidgetRef ref) async {
    final storageService = ref.read(storageProvider);
    try {
      await storageService.clearOneByOne();
    } catch (e) {
      debugPrint('Error clearing secure storage: $e');
      throw Exception('Failed to clear storage: $e');
    }

    ref.invalidate(storageProvider);
    debugPrint('TRACKING: 1 - storage cleared');
  }

  static void _resetSimpleProviders(WidgetRef ref) {
    try {
      ref.read(isAuthenticatedProvider.notifier).state = false;
      ref.read(errorProvider.notifier).state = '';
      ref.read(setupCompleteProvider.notifier).reset();
    } catch (e) {
      debugPrint('Error resetting simple providers: $e');
      throw Exception('Failed to reset simple providers: $e');
    }
  }

  static Future<void> _resetProvidersInBatches(WidgetRef ref) async {
    try {
      final List<void Function()> resetFunctions = [
        () => ref.read(pinProvider.notifier).reset(),
        () => ref.read(pinEntryStateNotifierProvider.notifier).reset(),
        () => ref.read(temporaryAccountProvider.notifier).reset(),
        () => ref.read(selectedAssetProvider.notifier).reset(),
        () => ref.read(isDarkModeProvider.notifier).reset(),
        () => ref.read(showFrozenAssetsProvider.notifier).reset(),
        () => ref.read(accountProvider.notifier).reset(),
        () => ref.read(activeAccountProvider.notifier).reset(),
        () => ref.read(transactionsProvider.notifier).reset(),
        () => ref.read(balanceProvider.notifier).reset(),
        () => ref.read(assetsProvider.notifier).reset(),
        () =>
            ref.read(accountDataFetchStatusProvider.notifier).setFetched(false),
      ];

      for (int i = 0; i < resetFunctions.length; i += 3) {
        final batch = resetFunctions.sublist(
            i, i + 3 > resetFunctions.length ? resetFunctions.length : i + 3);
        await Future.wait(batch.map((resetFunction) async {
          resetFunction();
        }));
        await Future.delayed(const Duration(milliseconds: 50));
      }
    } catch (e) {
      debugPrint('Error resetting providers in batches: $e');
      throw Exception('Failed to reset providers in batches: $e');
    }
  }
}
