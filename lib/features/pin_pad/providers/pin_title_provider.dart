import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/generated/l10n.dart';

final pinTitleProvider = StateNotifierProvider<PinTitleNotifier, String>((ref) {
  final s = S.current;
  return PinTitleNotifier(
    createPinTitle: s.createPin,
    confirmPinTitle: s.confirmPin,
    unlockTitle: s.unlock,
    verifyPinTitle: s.verifyPin,
  );
});

class PinTitleNotifier extends StateNotifier<String> {
  final String createPinTitle;
  final String confirmPinTitle;
  final String unlockTitle;
  final String verifyPinTitle;

  PinTitleNotifier({
    required this.createPinTitle,
    required this.confirmPinTitle,
    required this.unlockTitle,
    required this.verifyPinTitle,
  }) : super(createPinTitle);

  void setCreatePinTitle() {
    state = createPinTitle;
  }

  void setConfirmPinTitle() {
    state = confirmPinTitle;
  }

  void setUnlockTitle() {
    state = unlockTitle;
  }

  void setVerifyPinTitle() {
    state = verifyPinTitle;
  }
}
