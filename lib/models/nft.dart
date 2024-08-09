import 'dart:convert';

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

  factory NFT.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> metadata = jsonDecode(json['metadata']);
    return NFT(
      contractId: json['contractId'],
      tokenId: json['tokenId'],
      owner: json['owner'],
      metadataURI: json['metadataURI'],
      name: metadata['name'],
      description: metadata['description'],
      imageUrl: metadata['image'],
      imageMimetype: metadata['image_mimetype'],
      properties: metadata['properties'],
      royalties: json['royalties'],
      mintRound: json['mint-round'],
      isBurned: json['isBurned'],
    );
  }
}
