import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/features/settings/providers/pin_lock_provider.dart';
import 'package:kibisis/features/pin_pad/providers/pin_title_provider.dart';
import 'package:kibisis/providers/authentication_provider.dart';
import 'package:kibisis/providers/account_provider.dart';
import 'package:kibisis/providers/lock_timeout_provider.dart';
import 'package:kibisis/providers/pin_provider.dart';
import 'package:kibisis/providers/splash_screen_provider.dart';
import 'package:kibisis/providers/storage_provider.dart';
import 'package:kibisis/utils/biomentric_service.dart';
import 'package:kibisis/utils/wallet_connect_manageer.dart';

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

  void handleOnForeground() async {
    final lockoutTime = ref.read(lockTimeoutProvider);
    final isPasswordLockEnabled = ref.read(pinLockProvider);
    final storageService = ref.read(storageProvider);
    final walletConnectManager = WalletConnectManager(storageService);

    if (_backgroundTime != null) {
      final duration = DateTime.now().difference(_backgroundTime!);
      _backgroundTime = null;

      onResumed?.call(duration.inSeconds);

      if (isPasswordLockEnabled && duration.inSeconds > lockoutTime) {
        handleTimeout();
        await _triggerBiometricAuthentication();
      }

      await walletConnectManager.initialize();
      await walletConnectManager.reconnectSessions();

      if (Platform.isAndroid || Platform.isIOS) {
        ref.read(isSplashScreenVisibleProvider.notifier).state = false;
      }
    }
  }

  Future<void> _triggerBiometricAuthentication() async {
    final biometricService = BiometricService();
    final canAuthenticate = await biometricService.canCheckFingerprint();
    if (canAuthenticate) {
      final success = await biometricService.authenticateWithFingerprint();
      if (success) {
        ref.read(isAuthenticatedProvider.notifier).state = true;
      } else {
        debugPrint('Biometric authentication failed on app resume.');
      }
    }
  }

  void handleTimeout() {
    ref.read(isAuthenticatedProvider.notifier).state = false;
    ref.read(accountProvider.notifier).reset();
    ref.read(pinProvider.notifier).reset();
    ref.read(pinTitleProvider.notifier).setUnlockTitle();
  }

  void handleOnBackground() {
    _backgroundTime = DateTime.now();
    if (Platform.isAndroid || Platform.isIOS) {
      ref.read(isSplashScreenVisibleProvider.notifier).state = true;
    }
    ref.read(pinTitleProvider.notifier).setUnlockTitle();
  }
}
