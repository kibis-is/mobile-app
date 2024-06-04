import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/models/pin_state.dart';
import 'package:kibisis/providers/account_provider.dart';
import 'package:kibisis/providers/authentication_provider.dart';
import 'package:kibisis/providers/pin_provider.dart';

final pinEntryStateNotifierProvider =
    StateNotifierProvider<PinEntryStateNotifier, PinState>((ref) {
  final pinStateNotifier = ref.watch(pinProvider.notifier);
  return PinEntryStateNotifier(ref, pinStateNotifier);
});

class PinEntryStateNotifier extends StateNotifier<PinState> {
  final StateNotifierProviderRef<PinEntryStateNotifier, PinState> ref;
  final PinStateNotifier pinStateNotifier;

  PinEntryStateNotifier(this.ref, this.pinStateNotifier) : super(PinState());

  bool addKey(String key) {
    if (state.pin.length < 6) {
      String newPin = state.pin + key;
      state = state.copyWith(pin: newPin);
      if (newPin.length == 6) {
        return true;
      }
    }
    return false;
  }

  void pinComplete(PinPadMode mode) async {
    try {
      if (mode == PinPadMode.unlock) {
        bool isPinVerified = await pinStateNotifier.verifyPin(state.pin);
        if (isPinVerified) {
          debugPrint('PIN verified successfully');
          await ref.read(accountProvider.notifier).loadAccountFromPrivateKey();
          ref.read(isAuthenticatedProvider.notifier).state = true;
          debugPrint('Authentication state set to true.');
        } else {
          throw Exception('Incorrect PIN');
        }
      } else if (mode == PinPadMode.setup) {
        await pinStateNotifier.setPin(state.pin);
        debugPrint('PIN set successfully');
      }
    } catch (e) {
      debugPrint('Invalid PIN entered: $e');
      state = state.copyWith(error: 'Invalid PIN. Try again.', pin: '');
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

  void clearPin() {
    state = state.copyWith(pin: '');
  }

  void removeLastKey() {
    if (state.pin.isNotEmpty) {
      state = state.copyWith(pin: state.pin.substring(0, state.pin.length - 1));
    }
  }
}
