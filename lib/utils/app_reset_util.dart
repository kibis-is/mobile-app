import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/providers/account_provider.dart';
import 'package:kibisis/providers/active_account_provider.dart';
import 'package:kibisis/providers/authentication_provider.dart';
import 'package:kibisis/providers/error_provider.dart';
import 'package:kibisis/providers/loading_provider.dart';
import 'package:kibisis/providers/pin_entry_provider.dart';
import 'package:kibisis/providers/pin_provider.dart';
import 'package:kibisis/providers/setup_complete_provider.dart';
import 'package:kibisis/providers/storage_provider.dart';
import 'package:kibisis/providers/temporary_account_provider.dart';

class AppResetUtil {
  static Future<void> resetApp(WidgetRef ref) async {
    ref.read(loadingProvider.notifier).startLoading();
    final storageService = ref.read(storageProvider);

    await storageService.clearAll();

    ref.read(accountProvider.notifier).clearAccountState();

    ref.read(pinProvider.notifier).clearPinState();

    ref.read(pinEntryStateNotifierProvider.notifier).clearPin();

    ref.read(setupCompleteProvider.notifier).setSetupComplete(false);

    ref.read(errorProvider.notifier).state = null;

    ref.read(activeAccountProvider.notifier).clearActiveAccount();

    ref.read(temporaryAccountProvider.notifier).clear();

    ref.read(isAuthenticatedProvider.notifier).state = false;

    ref.read(loadingProvider.notifier).stopLoading();
  }
}
