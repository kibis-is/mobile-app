class DetailedAsset {
  final int amount;
  final int assetId;
  final String? creator;
  final bool isFrozen;
  final String? name;
  final String? unitName;
  final int? totalSupply;
  final int? decimals;
  final String? manager;
  final String? reserve;
  final String? freeze;
  final String? clawback;
  final String? url;
  final String? metadataHash;
  final bool? defaultFrozen;

  DetailedAsset({
    required this.amount,
    required this.assetId,
    this.creator,
    required this.isFrozen,
    this.name,
    this.unitName,
    this.totalSupply,
    this.decimals,
    this.manager,
    this.reserve,
    this.freeze,
    this.clawback,
    this.url,
    this.metadataHash,
    this.defaultFrozen,
  });

  DetailedAsset copyWith({
    int? amount,
    int? assetId,
    String? creator,
    bool? isFrozen,
    String? name,
    String? unitName,
    int? totalSupply,
    int? decimals,
    String? manager,
    String? reserve,
    String? freeze,
    String? clawback,
    String? url,
    String? metadataHash,
    bool? defaultFrozen,
  }) {
    return DetailedAsset(
      amount: amount ?? this.amount,
      assetId: assetId ?? this.assetId,
      creator: creator ?? this.creator,
      isFrozen: isFrozen ?? this.isFrozen,
      name: name ?? this.name,
      unitName: unitName ?? this.unitName,
      totalSupply: totalSupply ?? this.totalSupply,
      decimals: decimals ?? this.decimals,
      manager: manager ?? this.manager,
      reserve: reserve ?? this.reserve,
      freeze: freeze ?? this.freeze,
      clawback: clawback ?? this.clawback,
      url: url ?? this.url,
      metadataHash: metadataHash ?? this.metadataHash,
      defaultFrozen: defaultFrozen ?? this.defaultFrozen,
    );
  }
}
