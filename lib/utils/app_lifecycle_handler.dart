import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/features/settings/providers/pin_lock_provider.dart';
import 'package:kibisis/providers/authentication_provider.dart';
import 'package:kibisis/providers/account_provider.dart';
import 'package:kibisis/providers/lock_timeout_provider.dart';
import 'package:kibisis/providers/pin_provider.dart';
import 'package:kibisis/providers/splash_screen_provider.dart';

// Provider to manage splash screen visibility

class AppLifecycleHandler with WidgetsBindingObserver {
  DateTime? _backgroundTime;
  final Function(int)? onResumed;
  final WidgetRef ref;

  AppLifecycleHandler({required this.ref, this.onResumed});

  void initialize() {
    WidgetsBinding.instance.addObserver(this);
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if ((state == AppLifecycleState.inactive ||
            state == AppLifecycleState.hidden) &&
        _backgroundTime == null) {
      handleOnBackground();
    }

    if (state == AppLifecycleState.resumed) {
      handleOnForeground();
    }
  }

  void handleOnForeground() {
    final lockoutTime = ref.read(lockTimeoutProvider);
    final isPasswordLockEnabled = ref.read(pinLockProvider);

    if (_backgroundTime != null) {
      final duration = DateTime.now().difference(_backgroundTime!);
      _backgroundTime = null; // Reset the background time

      onResumed?.call(duration.inSeconds);

      if (isPasswordLockEnabled && duration.inSeconds > lockoutTime) {
        handleTimeout();
      }

      // Remove the splash screen when the app comes to the foreground
      ref.read(isSplashScreenVisibleProvider.notifier).state = false;
    }
  }

  void handleTimeout() {
    ref.read(isAuthenticatedProvider.notifier).state = false;
    ref.read(accountProvider.notifier).clearAccountState();
    ref.read(pinProvider.notifier).clearPinState();
  }

  void handleOnBackground() {
    _backgroundTime = DateTime.now();

    // Show the splash screen when the app goes to the background
    ref.read(isSplashScreenVisibleProvider.notifier).state = true;
  }
}
