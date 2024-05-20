import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/providers/account_provider.dart';
import 'package:kibisis/providers/app_lifecycle_provider.dart';
import 'package:kibisis/providers/authentication_provider.dart';
import 'package:kibisis/providers/error_provider.dart';
import 'package:kibisis/providers/loading_provider.dart';
import 'package:kibisis/providers/pin_provider.dart';

final appLifecycleCoordinatorProvider =
    Provider<AppLifecycleCoordinator>((ref) {
  return AppLifecycleCoordinator(ref);
});

class AppLifecycleCoordinator with WidgetsBindingObserver {
  final Ref ref;

  AppLifecycleCoordinator(this.ref) {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    final appLifecycleNotifier = ref.read(appLifecycleProvider.notifier);
    final loadingNotifier = ref.read(loadingProvider.notifier);
    final errorNotifier = ref.read(errorProvider.notifier);

    if (state == AppLifecycleState.paused) {
      appLifecycleNotifier.updateLastPausedTime(DateTime.now());
      debugPrint('App is paused');

      // Clear authentication and account state for security
      ref.read(isAuthenticatedProvider.notifier).state = false;
      ref.read(accountProvider.notifier).clearAccountState();
      ref.read(pinProvider.notifier).clearPinState();
      debugPrint("Sensitive data cleared on pause");
    } else if (state == AppLifecycleState.resumed) {
      final appState = ref.read(appLifecycleProvider);
      final lastPausedTime = appState.lastPausedTime;

      if (lastPausedTime != null &&
          DateTime.now().difference(lastPausedTime) >
              appState.timeoutDuration) {
        loadingNotifier.startLoading();

        // Notify the user that the session timed out
        errorNotifier.state = "Session timed out. Please re-authenticate.";
        debugPrint("Timeout exceeded, user needs to re-authenticate");

        loadingNotifier.stopLoading();
      }

      debugPrint(
          'App is resumed - might prompt for authentication or refresh data');
    }
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }
}
