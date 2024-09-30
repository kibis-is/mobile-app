import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final nftFilterControllerProvider =
    StateNotifierProvider<NftFilterController, TextEditingController>((ref) {
  return NftFilterController();
});

class NftFilterController extends StateNotifier<TextEditingController> {
  NftFilterController() : super(TextEditingController());

  void reset() {
    state.text = '';
  }
}
