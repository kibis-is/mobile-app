import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:kibisis/models/nft.dart';

final nftNotifierProvider = StateNotifierProvider<NFTNotifier, NFTState>((ref) {
  return NFTNotifier();
});

class NFTState {
  final List<NFT> nfts;
  final String? error;

  NFTState({required this.nfts, this.error});

  NFTState.initial() : this(nfts: [], error: null);
}

class NFTNotifier extends StateNotifier<NFTState> {
  NFTNotifier() : super(NFTState.initial()) {
    // Load mock data by default for testing
    _loadMockData();
  }

  // Method to fetch NFTs using a public key
  Future<void> fetchNFTs(String publicKey) async {
    final String url =
        'https://arc72-idx.nftnavigator.xyz/nft-indexer/v1/tokens?owner=$publicKey';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        final List<dynamic> tokens = body['tokens'];
        final List<NFT> nfts =
            tokens.map<NFT>((json) => NFT.fromJson(json)).toList();
        state = NFTState(nfts: nfts);
      } else {
        throw Exception(
            'Failed to load NFTs with status code: ${response.statusCode}');
      }
    } catch (e) {
      state = NFTState(nfts: [], error: e.toString());
    }
  }

  // Method to load mock data
  void _loadMockData() {
    final mockNfts = List<NFT>.generate(15, (index) {
      return NFT(
        contractId: index + 1,
        tokenId: index + 1,
        owner: "mockOwner",
        metadataURI: "assets/nfts/${index + 1}.webp",
        name: "Mock NFT #${index + 1}",
        description: "This is a mock NFT for testing.",
        imageUrl:
            "assets/nfts/${index + 1}.webp", // Correctly reference the asset path
        imageMimetype: "image/webp",
        properties: {
          "Property1": "Value1",
          "Property2": "Value2"
        }, // Example properties
        royalties: "mockRoyalties",
        mintRound: 1,
        isBurned: false,
      );
    });

    state = NFTState(nfts: mockNfts);
  }

  // Uncomment the following method to switch from mock data to real data fetching
  /*
  Future<void> loadNftsFromPublicKey(String publicKey) async {
    state = NFTState(nfts: []); // Clear current state
    await fetchNFTs(publicKey);
  }
  */

  // Call this method to switch between mock data and real data fetching
  /*
  void switchToRealDataFetching(String publicKey) {
    _loadMockData(); // Load mock data by default
    // Call this to load real data when needed
    // loadNftsFromPublicKey(publicKey);
  }
  */
}
