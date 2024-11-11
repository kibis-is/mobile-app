import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/generated/l10n.dart';

final multipartScanProvider =
    StateNotifierProvider<MultipartScanNotifier, MultipartScanState>(
  (ref) => MultipartScanNotifier(),
);

class MultipartScanState {
  final Map<String, List<MapEntry<String, String>>> scannedParts;
  final int totalParts;
  final bool isComplete;
  final String? checksum;

  MultipartScanState({
    this.scannedParts = const {},
    this.totalParts = 0,
    this.isComplete = false,
    this.checksum,
  });

  MultipartScanState copyWith({
    Map<String, List<MapEntry<String, String>>>? scannedParts,
    int? totalParts,
    bool? isComplete,
    String? checksum,
  }) {
    return MultipartScanState(
      scannedParts: scannedParts ?? this.scannedParts,
      totalParts: totalParts ?? this.totalParts,
      isComplete: isComplete ?? this.isComplete,
      checksum: checksum ?? this.checksum,
    );
  }
}

class MultipartScanNotifier extends StateNotifier<MultipartScanState> {
  MultipartScanNotifier() : super(MultipartScanState());

  Map<String, List<MapEntry<String, String>>> get scannedParts =>
      state.scannedParts;

  int get totalParts => state.totalParts;

  bool get isComplete => state.isComplete;

  void addPart(
      String page, List<MapEntry<String, String>> params, String checksum) {
    if (state.checksum != null && state.checksum != checksum) {
      throw Exception(S.current.checksumMismatch);
    }

    final newParts =
        Map<String, List<MapEntry<String, String>>>.from(state.scannedParts);
    newParts[page] = params;
    state = state.copyWith(
      scannedParts: newParts,
      checksum: checksum,
      isComplete: newParts.length == state.totalParts,
    );
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

    final allParts = List<int>.generate(state.totalParts, (index) => index + 1);
    final remainingParts =
        allParts.where((part) => !scannedPartNumbers.contains(part)).toList();

    return remainingParts;
  }
}
