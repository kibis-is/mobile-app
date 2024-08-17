import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/models/nft.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

final nftNotifierProvider =
    StateNotifierProvider<NFTNotifier, AsyncValue<List<NFT>>>((ref) {
  return NFTNotifier();
});

class NFTNotifier extends StateNotifier<AsyncValue<List<NFT>>> {
  List<NFT> _allNfts = [];

  NFTNotifier() : super(const AsyncValue.loading());

  Future<void> fetchNFTs(String publicKey) async {
    if (_allNfts.isNotEmpty) {
      state = AsyncValue.data(_allNfts);
      return;
    }

    state = const AsyncValue.loading();
    final String url =
        'https://arc72-idx.nftnavigator.xyz/nft-indexer/v1/tokens?owner=$publicKey';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        final List<dynamic> tokens = body['tokens'];

        if (tokens.isEmpty) {
          throw Exception('No tokens found in response');
        }

        final List<NFT> nfts = tokens.map<NFT>((json) {
          final metadataJson = jsonDecode(json['metadata']);
          return NFT(
            contractId: json['contractId'],
            tokenId: json['tokenId'],
            owner: json['owner'],
            metadataURI: json['metadataURI'],
            name: metadataJson['name'],
            description: metadataJson['description'],
            imageUrl: metadataJson['image'],
            imageMimetype: metadataJson['image_mimetype'],
            properties: Map<String, String>.from(metadataJson['properties']),
            royalties: metadataJson['royalties'],
            mintRound: json['mint-round'],
            isBurned: json['isBurned'],
          );
        }).toList();

        _allNfts = nfts;
        state = AsyncValue.data(nfts);
      } else {
        throw Exception(
            'Failed to load NFTs with status code: ${response.statusCode}');
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  void setFilter(String query) {
    if (query.isEmpty) {
      state = AsyncValue.data(_allNfts);
    } else {
      final filteredNfts = _allNfts.where((nft) {
        final nameLower = nft.name.toLowerCase();
        final queryLower = query.toLowerCase();
        return nameLower.contains(queryLower);
      }).toList();

      state = AsyncValue.data(filteredNfts);
    }
  }
}
