import 'package:algorand_dart/algorand_dart.dart';
import 'package:kibisis/models/combined_asset.dart';

CombinedAsset convertToCombinedAsset(Asset asset) {
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
      name: asset.params.name,
      reserve: asset.params.reserve,
      unitName: asset.params.unitName,
      url: asset.params.url,
      metadataHash: asset.params.metadataHash,
    ),
    createdAtRound: asset.createdAtRound,
    deleted: asset.deleted,
    destroyedAtRound: asset.destroyedAtRound,
    assetType: AssetType.standard, // Marking it as a standard asset
  );
}
