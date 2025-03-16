import 'package:algorand_dart/algorand_dart.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/generated/l10n.dart';
import 'package:kibisis/models/combined_asset.dart';

class AssetConverter {
  static String getNameOrFallback(String? name, String? fallback) {
    return (name?.isNotEmpty ?? false)
        ? name!
        : (fallback ?? S.current.unnamedAsset);
  }

  static CombinedAsset convertToCombinedAsset(
      Asset asset, int amount, bool isFrozen) {
    final assetName =
        getNameOrFallback(asset.params.name, asset.params.unitName);
    final assetUnitName =
        getNameOrFallback(asset.params.unitName, asset.params.name);

    return CombinedAsset(
      index: asset.index,
      createdAtRound: asset.createdAtRound,
      deleted: asset.deleted,
      destroyedAtRound: asset.destroyedAtRound,
      assetType: AssetType.standard,
      amount: amount,
      isFrozen: isFrozen,
      params: CombinedAssetParameters(
        total: asset.params.total,
        decimals: asset.params.decimals,
        creator: asset.params.creator,
        clawback: asset.params.clawback,
        defaultFrozen: asset.params.defaultFrozen,
        freeze: asset.params.freeze,
        manager: asset.params.manager,
        name: assetName,
        reserve: asset.params.reserve,
        unitName: assetUnitName,
        url: asset.params.url,
        metadataHash: asset.params.metadataHash,
      ),
    );
  }

  static CombinedAsset convertAssetToCombinedWithoutAmount(Asset asset) {
    final assetName =
        getNameOrFallback(asset.params.name, asset.params.unitName);
    final assetUnitName =
        getNameOrFallback(asset.params.unitName, asset.params.name);

    return CombinedAsset(
      index: asset.index,
      params: CombinedAssetParameters(
        total: asset.params.total,
        decimals: asset.params.decimals,
        creator: asset.params.creator,
        clawback: asset.params.clawback,
        defaultFrozen: asset.params.defaultFrozen,
        freeze: asset.params.freeze,
        manager: asset.params.manager,
        name: assetName,
        reserve: asset.params.reserve,
        unitName: assetUnitName,
        url: asset.params.url,
        metadataHash: asset.params.metadataHash,
      ),
      createdAtRound: asset.createdAtRound,
      deleted: asset.deleted,
      destroyedAtRound: asset.destroyedAtRound,
      assetType: AssetType.standard,
      amount: 0,
      isFrozen: false,
    );
  }
}
