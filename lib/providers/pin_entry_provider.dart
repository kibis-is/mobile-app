import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/models/pin_state.dart';
import 'package:kibisis/providers/wallet_manager_provider.dart';

final pinEntryStateNotifierProvider =
    StateNotifierProvider<PinEntryStateNotifier, PinState>((ref) {
  return PinEntryStateNotifier(ref);
});

class PinEntryStateNotifier extends StateNotifier<PinState> {
  final StateNotifierProviderRef<PinEntryStateNotifier, PinState> ref;
  PinEntryStateNotifier(this.ref) : super(PinState());

  bool addKey(String key) {
    if (state.pin.length < 6) {
      String newPin = state.pin + key;
      if (newPin.length == 6) {
        return true;
      } else {
        state = state.copyWith(pin: newPin);
      }
    }
    return false;
  }

  void pinComplete(PinPadMode mode) async {
    try {
      await ref.read(walletManagerProvider.notifier).setPin(state.pin);
      if (mode == PinPadMode.unlock) {
        await ref.read(walletManagerProvider.notifier).initializeAccount();
      }
    } catch (e) {
      debugPrint('invalid pin entered');
      if (mode == PinPadMode.setup) {
        await ref.read(walletManagerProvider.notifier).resetWallet();
      }
      state = state.copyWith(error: 'Invalid PIN. Try again.', pin: '');
    }
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
