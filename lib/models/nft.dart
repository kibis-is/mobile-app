class NFT {
  final int contractId;
  final int tokenId;
  final String owner;
  final String metadataURI;
  final String name;
  final String description;
  final String imageUrl;
  final String imageMimetype;
  final Map<String, dynamic> properties;
  final String royalties;
  final int mintRound;
  final bool isBurned;

  NFT({
    required this.contractId,
    required this.tokenId,
    required this.owner,
    required this.metadataURI,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.imageMimetype,
    required this.properties,
    required this.royalties,
    required this.mintRound,
    required this.isBurned,
  });

  Map<String, dynamic> toJson() {
    return {
      'contractId': contractId,
      'tokenId': tokenId,
      'owner': owner,
      'metadataURI': metadataURI,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'imageMimetype': imageMimetype,
      'properties': properties,
      'royalties': royalties,
      'mintRound': mintRound,
      'isBurned': isBurned,
    };
  }

  static NFT fromJson(Map<String, dynamic> json) {
    return NFT(
      contractId: json['contractId'],
      tokenId: json['tokenId'],
      owner: json['owner'],
      metadataURI: json['metadataURI'],
      name: json['name'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      imageMimetype: json['imageMimetype'],
      properties: Map<String, dynamic>.from(json['properties']),
      royalties: json['royalties'],
      mintRound: json['mintRound'],
      isBurned: json['isBurned'],
    );
  }
}
