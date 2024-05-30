// app_lifecycle_handler.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/features/settings/providers/settings_providers.dart';
import 'package:kibisis/providers/authentication_provider.dart';
import 'package:kibisis/providers/account_provider.dart';
import 'package:kibisis/providers/lock_timeout_provider.dart';
import 'package:kibisis/providers/pin_provider.dart';

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
    debugPrint(
        'Current AppLifecycleState is $state at ${DateTime.now().toIso8601String()}');

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

    final isPasswordLockEnabled = ref.read(enablePasswordLockProvider);
    if (_backgroundTime != null) {
      final duration = DateTime.now().difference(_backgroundTime!);
      debugPrint(
          'App was in the background for: ${duration.inSeconds} seconds');
      _backgroundTime = null; // Reset the background time

      onResumed?.call(duration.inSeconds);

      if (isPasswordLockEnabled && duration.inSeconds > lockoutTime) {
        debugPrint('The app was in the background for more than one minute.');
        handleTimeout();
      }
    }
  }

  void handleTimeout() {
    // Implement actions to be performed if the background time was more than one minute
    debugPrint('Performing actions due to extended background time.');
    // Set the isAuthenticatedProvider to false
    ref.read(isAuthenticatedProvider.notifier).state = false;

    // Clear account and PIN states
    ref.read(accountProvider.notifier).clearAccountState();
    ref.read(pinProvider.notifier).clearPinState();
  }

  void handleOnBackground() {
    _backgroundTime = DateTime.now();
    debugPrint('Background time set at: $_backgroundTime');
  }
}
