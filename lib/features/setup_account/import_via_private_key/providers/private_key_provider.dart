import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

final privateKeyProvider =
    StateNotifierProvider<PrivateKeyNotifier, TextEditingController>(
  (ref) => PrivateKeyNotifier(),
);

class PrivateKeyNotifier extends StateNotifier<TextEditingController> {
  PrivateKeyNotifier() : super(TextEditingController());

  void clear() {
    state.clear();
  }

  void updateKey(String newKey) {
    state.text = newKey;
  }
}
