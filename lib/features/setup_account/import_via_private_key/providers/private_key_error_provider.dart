import 'package:flutter_riverpod/flutter_riverpod.dart';

class PrivateKeyErrorNotifier extends StateNotifier<bool> {
  PrivateKeyErrorNotifier() : super(false);

  void showError() => state = true;
  void hideError() => state = false;
}

final privateKeyErrorProvider =
    StateNotifierProvider<PrivateKeyErrorNotifier, bool>(
  (ref) => PrivateKeyErrorNotifier(),
);
