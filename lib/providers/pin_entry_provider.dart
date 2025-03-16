import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/generated/l10n.dart';
import 'package:kibisis/models/pin_state.dart';
import 'package:kibisis/providers/account_provider.dart';
import 'package:kibisis/providers/authentication_provider.dart';
import 'package:kibisis/providers/loading_provider.dart';
import 'package:kibisis/providers/pin_provider.dart';

final pinEntryStateNotifierProvider =
    StateNotifierProvider<PinEntryStateNotifier, PinState>((ref) {
  final pinStateNotifier = ref.watch(pinProvider.notifier);
  return PinEntryStateNotifier(ref, pinStateNotifier);
});

final isPinCompleteProvider = StateProvider<bool>((ref) => false);

class PinEntryStateNotifier extends StateNotifier<PinState> {
  String? _firstPin;

  final Ref ref;
  final PinStateNotifier pinStateNotifier;

  PinEntryStateNotifier(this.ref, this.pinStateNotifier) : super(PinState());

  void addKey(String key) {
    if (state.pin.length < 6) {
      String newPin = state.pin + key;
      state = state.copyWith(pin: newPin);
    }
  }

  bool isPinComplete() {
    return state.pin.length == 6;
  }

  void setFirstPin(String pin) {
    _firstPin = pin;
  }

  String? getFirstPin() {
    return _firstPin;
  }

  String _getOverlayText(PinPadMode mode) {
    switch (mode) {
      case PinPadMode.setup:
        return S.current.settingUp;
      case PinPadMode.unlock:
        return S.current.authenticating;
      case PinPadMode.verifyTransaction:
        return S.current.verifying;
      case PinPadMode.changePin:
        return S.current.settingNewPin;
      default:
        return '';
    }
  }

  Future<void> pinComplete(
      PinPadMode mode, String? activeAccountId, String? accountName) async {
    try {
      if (mode == PinPadMode.setup) {
        await pinStateNotifier.setPin(state.pin);
      } else if (mode == PinPadMode.unlock) {
        bool isPinVerified = await pinStateNotifier.verifyPin(state.pin);
        if (isPinVerified) {
          ref
              .read(loadingProvider.notifier)
              .startLoading(message: _getOverlayText(mode));

          if (activeAccountId == null) {
            throw Exception(S.current.noActiveAccountFound);
          }

          if (accountName == null || accountName.isEmpty) {
            throw Exception(S.current.accountNameNotFound(activeAccountId));
          }

          await ref
              .read(accountProvider.notifier)
              .initialiseFromPublicKey(accountName, activeAccountId);
          ref.read(isAuthenticatedProvider.notifier).state = true;
          clearError();
        } else {
          throw Exception(S.current.incorrectPin);
        }
      }
    } catch (e) {
      state = state.copyWith(error: S.current.invalidPinTryAgain, pin: '');
      ref.read(loadingProvider.notifier).stopLoading();
      debugPrint('Error in pinComplete: ${e.toString()}');
    }
  }

  void setError(String error) {
    state = state.copyWith(error: error, pin: '');
  }

  void clearError() {
    state = state.copyWith(error: '');
  }

  String getPin() {
    return state.pin;
  }

  void reset() {
    state = state.copyWith(pin: '');
  }

  void removeLastKey() {
    if (state.pin.isNotEmpty) {
      state = state.copyWith(pin: state.pin.substring(0, state.pin.length - 1));
    }
  }
}
