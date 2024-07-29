import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final multipartScanProvider =
    StateNotifierProvider<MultipartScanNotifier, MultipartScanState>(
  (ref) => MultipartScanNotifier(),
);

class MultipartScanState {
  final Map<String, String> scannedParts;
  final int totalParts;
  final bool isComplete;

  MultipartScanState({
    this.scannedParts = const {},
    this.totalParts = 0,
    this.isComplete = false,
  });

  MultipartScanState copyWith({
    Map<String, String>? scannedParts,
    int? totalParts,
    bool? isComplete,
  }) {
    return MultipartScanState(
      scannedParts: scannedParts ?? this.scannedParts,
      totalParts: totalParts ?? this.totalParts,
      isComplete: isComplete ?? this.isComplete,
    );
  }
}

class MultipartScanNotifier extends StateNotifier<MultipartScanState> {
  MultipartScanNotifier() : super(MultipartScanState());

  void addPart(String page, String data) {
    final newParts = Map<String, String>.from(state.scannedParts);
    newParts[page] = data;
    state = state.copyWith(
        scannedParts: newParts,
        isComplete: newParts.length == state.totalParts);
  }

  void setTotalParts(int total) {
    state = state.copyWith(totalParts: total);
  }

  void reset() {
    state = MultipartScanState();
  }

  List<int> getRemainingParts() {
    final scannedPartNumbers = state.scannedParts.keys
        .map((key) {
          final parts = key.split(':');
          if (parts.length == 2) {
            return int.tryParse(parts[0]);
          }
          return null;
        })
        .whereType<int>()
        .toSet();

    debugPrint('Scanned part numbers: $scannedPartNumbers');
    debugPrint('Total parts: ${state.totalParts}');

    final allParts = List<int>.generate(state.totalParts, (index) => index + 1);
    final remainingParts =
        allParts.where((part) => !scannedPartNumbers.contains(part)).toList();

    debugPrint('Remaining parts: $remainingParts');

    return remainingParts;
  }
}
