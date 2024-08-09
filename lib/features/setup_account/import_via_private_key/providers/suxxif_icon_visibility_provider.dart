import 'package:flutter_riverpod/flutter_riverpod.dart';

final suffixIconVisibilityProvider =
    StateNotifierProvider<SuffixIconVisibilityNotifier, bool>(
  (ref) => SuffixIconVisibilityNotifier(),
);

class SuffixIconVisibilityNotifier extends StateNotifier<bool> {
  SuffixIconVisibilityNotifier() : super(false);

  void showIcon() => state = true;
  void hideIcon() => state = false;
}
