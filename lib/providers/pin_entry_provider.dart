import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/constants/constants.dart';
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

  final StateNotifierProviderRef<PinEntryStateNotifier, PinState> ref;
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
        return 'Setting Up';
      case PinPadMode.unlock:
        return 'Authenticating';
      case PinPadMode.verifyTransaction:
        return 'Verifying';
      case PinPadMode.changePin:
        return 'Setting New PIN';
      default:
        return '';
    }
  }

  Future<void> pinComplete(PinPadMode mode) async {
    try {
      if (mode == PinPadMode.setup) {
        await pinStateNotifier.setPin(state.pin);
      } else if (mode == PinPadMode.unlock) {
        bool isPinVerified = await pinStateNotifier.verifyPin(state.pin);
        if (isPinVerified) {
          ref
              .read(loadingProvider.notifier)
              .startLoading(message: _getOverlayText(mode));
          await ref.read(accountProvider.notifier).loadAccountFromPrivateKey();
          ref.read(isAuthenticatedProvider.notifier).state = true;
          clearError();
        } else {
          throw Exception('Incorrect PIN');
        }
      }
    } catch (e) {
      state = state.copyWith(error: 'Invalid PIN. Try again.', pin: '');
      ref.read(loadingProvider.notifier).stopLoading();
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
