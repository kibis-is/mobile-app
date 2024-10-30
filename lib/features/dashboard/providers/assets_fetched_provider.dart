import 'package:flutter_riverpod/flutter_riverpod.dart';

final accountDataFetchStatusProvider =
    StateNotifierProvider<FetchStatusNotifier, bool>((ref) {
  return FetchStatusNotifier();
});

class FetchStatusNotifier extends StateNotifier<bool> {
  FetchStatusNotifier() : super(false);

  void setFetched(bool fetched) {
    state = fetched;
  }

  void reset() {
    state = false;
  }
}
