import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/models/pin_state.dart';
import 'package:kibisis/providers/storage_provider.dart';
import 'package:kibisis/utils/crypto_utils.dart';

final pinProvider = StateNotifierProvider<PinStateNotifier, PinState>((ref) {
  final storageService = ref.read(storageProvider);
  return PinStateNotifier(ref, storageService);
});

class PinStateNotifier extends StateNotifier<PinState> {
  final Ref ref;
  final StorageService storageService;
  String? _storedHashedPin;

  PinStateNotifier(this.ref, this.storageService) : super(PinState());

  Future<void> preloadStoredHashedPin() async {
    _storedHashedPin = await storageService.getPinHash();
  }

  Future<void> setPin(String pin) async {
    try {
      String hashedPin = CryptoUtils.hashPin(pin);
      await storageService.setPinHash(hashedPin);
      _storedHashedPin = hashedPin;
    } catch (e) {
      state = state.copyWith(error: 'Failed to set PIN: $e');
    }
  }

  Future<bool> verifyPin(String enteredPin) async {
    try {
      String? storedHashedPin = _storedHashedPin;
      if (storedHashedPin == null) {
        storedHashedPin = await storageService.getPinHash();
        _storedHashedPin = storedHashedPin;
      }
      if (storedHashedPin == null) {
        return false;
      }
      String enteredHashedPin = CryptoUtils.hashPin(enteredPin);
      return storedHashedPin == enteredHashedPin;
    } catch (e) {
      state = state.copyWith(error: 'Failed to verify PIN: $e');
      return false;
    }
  }

  Future<bool> changePin(String oldPin, String newPin) async {
    try {
      bool isOldPinValid = await verifyPin(oldPin);
      if (isOldPinValid) {
        final newPinHash = CryptoUtils.hashPin(newPin);
        await storageService.setPinHash(newPinHash);
        _storedHashedPin = newPinHash;
        return true;
      } else {
        return false;
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to change PIN: $e');
      return false;
    }
  }

  void reset() {
    state = PinState();
  }
}
