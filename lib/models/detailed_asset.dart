class DetailedAsset {
  final int amount;
  final int assetId;
  final String? creator;
  final bool isFrozen;
  final String? name;
  final String? unitName;
  final int? totalSupply;
  final int? decimals; // Added decimals field
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
    this.decimals, // Initialize decimals field
    this.manager,
    this.reserve,
    this.freeze,
    this.clawback,
    this.url,
    this.metadataHash,
    this.defaultFrozen,
  });
}
