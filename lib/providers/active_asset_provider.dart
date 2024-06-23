import 'package:algorand_dart/algorand_dart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final activeAssetProvider =
    StateNotifierProvider<ActiveAssetNotifier, Asset?>((ref) {
  return ActiveAssetNotifier();
});

class ActiveAssetNotifier extends StateNotifier<Asset?> {
  ActiveAssetNotifier() : super(null);

  void setActiveAsset(Asset asset) {
    state = asset;
  }

  void clearActiveAsset() {
    state = null;
  }

  void toggleFreeze() {
    if (state != null) {
      final updatedState = Asset(
        index: state!.index,
        createdAtRound: state!.createdAtRound,
        deleted: state!.deleted,
        destroyedAtRound: state!.destroyedAtRound,
        params: AssetParameters(
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
