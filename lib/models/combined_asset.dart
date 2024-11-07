import 'package:algorand_dart/algorand_dart.dart';
import 'package:kibisis/constants/constants.dart';

class CombinedAsset {
  final int index;
  final CombinedAssetParameters params;
  final int? createdAtRound;
  final bool? deleted;
  final int? destroyedAtRound;
  final AssetType assetType;
  final int amount;
  final bool isFrozen;

  CombinedAsset({
    required this.index,
    required this.params,
    this.createdAtRound,
    this.deleted,
    this.destroyedAtRound,
    required this.assetType,
    required this.amount,
    required this.isFrozen,
  });

  CombinedAsset copyWith({
    int? index,
    CombinedAssetParameters? params,
    int? createdAtRound,
    bool? deleted,
    int? destroyedAtRound,
    AssetType? assetType,
    int? amount,
    bool? isFrozen,
  }) {
    return CombinedAsset(
      index: index ?? this.index,
      params: params ?? this.params,
      createdAtRound: createdAtRound ?? this.createdAtRound,
      deleted: deleted ?? this.deleted,
      destroyedAtRound: destroyedAtRound ?? this.destroyedAtRound,
      assetType: assetType ?? this.assetType,
      amount: amount ?? this.amount,
      isFrozen: isFrozen ?? this.isFrozen,
    );
  }
}

class CombinedAssetParameters {
  final int total;
  final int decimals;
  final String creator;
  final String? clawback;
  final bool? defaultFrozen;
  final String? freeze;
  final String? manager;
  final String? name;
  final String? reserve;
  final String? unitName;
  final String? url;
  final String? metadataHash;

  CombinedAssetParameters({
    required this.total,
    required this.decimals,
    required this.creator,
    this.clawback,
    this.defaultFrozen,
    this.freeze,
    this.manager,
    this.name,
    this.reserve,
    this.unitName,
    this.url,
    this.metadataHash,
  });

  factory CombinedAssetParameters.fromStandardAsset(AssetParameters params) {
    return CombinedAssetParameters(
      total: params.total,
      decimals: params.decimals,
      creator: params.creator,
      clawback: params.clawback,
      defaultFrozen: params.defaultFrozen,
      freeze: params.freeze,
      manager: params.manager,
      name: params.name,
      reserve: params.reserve,
      unitName: params.unitName,
      url: params.url,
      metadataHash: params.metadataHash,
    );
  }

  factory CombinedAssetParameters.fromArc200(
      Map<String, dynamic> tokenDetails) {
    return CombinedAssetParameters(
      total: int.parse(tokenDetails['totalSupply'] ?? '0'),
      decimals: tokenDetails['decimals'] ?? 0,
      creator: tokenDetails['creator'] ?? 'Unknown',
      name: tokenDetails['name'] ?? 'Unknown',
      unitName: tokenDetails['symbol'] ?? 'Unknown',
      clawback: '0',
      defaultFrozen: false,
      freeze: null,
      manager: null,
      reserve: null,
      url: null,
      metadataHash: null,
    );
  }

  CombinedAssetParameters copyWith({
    int? total,
    int? decimals,
    String? creator,
    String? clawback,
    bool? defaultFrozen,
    String? freeze,
    String? manager,
    String? name,
    String? reserve,
    String? unitName,
    String? url,
    String? metadataHash,
  }) {
    return CombinedAssetParameters(
      total: total ?? this.total,
      decimals: decimals ?? this.decimals,
      creator: creator ?? this.creator,
      clawback: clawback ?? this.clawback,
      defaultFrozen: defaultFrozen ?? this.defaultFrozen,
      freeze: freeze ?? this.freeze,
      manager: manager ?? this.manager,
      name: name ?? this.name,
      reserve: reserve ?? this.reserve,
      unitName: unitName ?? this.unitName,
      url: url ?? this.url,
      metadataHash: metadataHash ?? this.metadataHash,
    );
  }
}
