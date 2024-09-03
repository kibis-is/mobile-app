import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/models/combined_asset.dart';

final activeAssetProvider =
    StateNotifierProvider<ActiveAssetNotifier, CombinedAsset?>((ref) {
  return ActiveAssetNotifier();
});

class ActiveAssetNotifier extends StateNotifier<CombinedAsset?> {
  ActiveAssetNotifier() : super(null);

  void setActiveAsset(CombinedAsset asset) {
    state = asset;
  }

  void clearActiveAsset() {
    state = null;
  }

  void toggleFreeze() {
    if (state != null) {
      final updatedState = CombinedAsset(
        index: state!.index,
        createdAtRound: state!.createdAtRound,
        deleted: state!.deleted,
        destroyedAtRound: state!.destroyedAtRound,
        assetType: state?.assetType ?? AssetType.standard,
        amount: state?.amount ?? 0,
        isFrozen: state?.isFrozen ?? false,
        params: CombinedAssetParameters(
          defaultFrozen: !(state!.params.defaultFrozen ?? false),
          decimals: state!.params.decimals,
          creator: state!.params.creator,
          total: state!.params.total,
        ),
      );

      state = updatedState;
    }
  }
}
