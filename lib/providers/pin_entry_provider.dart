import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/models/pin_state.dart';
import 'package:kibisis/providers/wallet_manager_provider.dart';

final pinEntryStateNotifierProvider =
    StateNotifierProvider<PinEntryStateNotifier, PinState>((ref) {
  return PinEntryStateNotifier(ref);
});

class PinEntryStateNotifier extends StateNotifier<PinState> {
  final StateNotifierProviderRef<PinEntryStateNotifier, PinState> ref;
  PinEntryStateNotifier(this.ref) : super(PinState());

  void addKey(String key) async {
    if (state.pin.length < 6) {
      String newPin = state.pin + key;
      if (newPin.length == 6) {
        debugPrint('Pin Entry Complete: $newPin');
        bool isPinValid =
            await ref.read(walletManagerProvider.notifier).verifyPin(newPin);
        if (isPinValid) {
          debugPrint('valid pin entered');
          ref.read(walletManagerProvider.notifier).initializeAccount();
        } else {
          debugPrint('invalid pin entered');
          state = state.copyWith(error: 'Invalid PIN. Try again.', pin: '');
        }
      } else {
        state = state.copyWith(pin: newPin);
      }
    }
  }

  void removeLastKey() {
    if (state.pin.isNotEmpty) {
      state = state.copyWith(pin: state.pin.substring(0, state.pin.length - 1));
    }
  }
}
