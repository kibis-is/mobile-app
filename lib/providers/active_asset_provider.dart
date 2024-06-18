import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/models/detailed_asset.dart';

final activeAssetProvider =
    StateNotifierProvider<ActiveAssetNotifier, DetailedAsset?>((ref) {
  return ActiveAssetNotifier();
});

class ActiveAssetNotifier extends StateNotifier<DetailedAsset?> {
  ActiveAssetNotifier() : super(null);

  void setActiveAsset(DetailedAsset asset) {
    state = asset;
  }

  void clearActiveAsset() {
    state = null;
  }

  void toggleFreeze() {
    if (state != null) {
      state = state!.copyWith(isFrozen: !state!.isFrozen);
    }
  }
}
