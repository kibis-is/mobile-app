import 'package:flutter_riverpod/flutter_riverpod.dart';

class PinTitleNotifier extends StateNotifier<String> {
  PinTitleNotifier() : super('Create Pin');

  void setCreatePinTitle() {
    state = 'Create Pin';
  }

  void setConfirmPinTitle() {
    state = 'Confirm Pin';
  }

  void setUnlockTitle() {
    state = 'Unlock';
  }

  void setVerifyPinTitle() {
    state = 'Verify Pin';
  }
}

final pinTitleProvider = StateNotifierProvider<PinTitleNotifier, String>((ref) {
  return PinTitleNotifier();
});
