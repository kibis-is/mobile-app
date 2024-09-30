import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final assetsFilterControllerProvider =
    StateNotifierProvider<AssetsFilterController, TextEditingController>((ref) {
  return AssetsFilterController();
});

class AssetsFilterController extends StateNotifier<TextEditingController> {
  AssetsFilterController() : super(TextEditingController());

  void reset() {
    state.text = '';
  }
}
