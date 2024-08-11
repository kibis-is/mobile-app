import 'package:flutter_riverpod/flutter_riverpod.dart';

class ShowNftInfoNotifier extends StateNotifier<bool> {
  ShowNftInfoNotifier() : super(false);

  void toggle() {
    state = !state;
  }
}

final showNftInfoProvider =
    StateNotifierProvider<ShowNftInfoNotifier, bool>((ref) {
  return ShowNftInfoNotifier();
});
