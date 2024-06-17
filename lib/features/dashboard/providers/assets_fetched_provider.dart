import 'package:flutter_riverpod/flutter_riverpod.dart';

final assetFetchStatusProvider =
    StateNotifierProvider<AssetFetchStatusNotifier, bool>((ref) {
  return AssetFetchStatusNotifier();
});

class AssetFetchStatusNotifier extends StateNotifier<bool> {
  AssetFetchStatusNotifier() : super(false);

  void setFetched(bool fetched) {
    state = fetched;
  }
}
