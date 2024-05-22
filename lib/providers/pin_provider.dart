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

  PinStateNotifier(this.ref, this.storageService) : super(PinState());

  // Method to set the PIN hash
  Future<void> setPin(String pin) async {
    try {
      String hashedPin = CryptoUtils.hashPin(pin);
      await storageService.setPinHash(hashedPin);
    } catch (e) {
      state = state.copyWith(error: 'Failed to set PIN: $e');
    }
  }

  // Method to verify the PIN against the stored hash
  Future<bool> verifyPin(String enteredPin) async {
    try {
      String? storedHashedPin = await storageService.getPinHash();
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

  // Method to change the PIN
  Future<bool> changePin(String oldPin, String newPin) async {
    try {
      bool isOldPinValid = await verifyPin(oldPin);
      if (isOldPinValid) {
        final newPinHash = CryptoUtils.hashPin(newPin);
        await storageService.setPinHash(newPinHash);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to change PIN: $e');
      return false;
    }
  }

  // Method to reset the PIN
  void clearPinState() {
    state = PinState();
  }
}
