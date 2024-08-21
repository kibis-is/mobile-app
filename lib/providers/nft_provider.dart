import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/features/dashboard/widgets/assets_tab.dart';
import 'package:kibisis/models/nft.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kibisis/providers/account_provider.dart';
import 'package:kibisis/providers/storage_provider.dart';

final nftNotifierProvider =
    StateNotifierProvider<NFTNotifier, AsyncValue<List<NFT>>>((ref) {
  final publicAddress = ref.watch(accountProvider).account?.publicAddress;
  if (publicAddress != null) {
    return NFTNotifier(ref, publicAddress);
  }
  return NFTNotifier(ref, '');
});

class NFTNotifier extends StateNotifier<AsyncValue<List<NFT>>> {
  final Ref ref;
  final String publicAddress;
  List<NFT> _allNfts = [];
  String _filter = '';
  Sorting? _sorting;

  NFTNotifier(this.ref, this.publicAddress)
      : super(const AsyncValue.loading()) {
    _loadCachedNFTs();
  }

  Future<void> _loadCachedNFTs() async {
    final storageService = ref.read(storageProvider);
    final cachedNftsJson = storageService.prefs?.getString('cachedNfts');

    if (cachedNftsJson != null) {
      final List<dynamic> cachedNfts = json.decode(cachedNftsJson);
      _allNfts = cachedNfts.map<NFT>((json) => NFT.fromJson(json)).toList();
      state = AsyncValue.data(_filteredNfts());
    } else {
      fetchNFTs();
    }
  }

  Future<void> fetchNFTs() async {
    if (publicAddress.isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }

    try {
      final String url =
          'https://arc72-idx.nftnavigator.xyz/nft-indexer/v1/tokens?owner=$publicAddress';
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

        _allNfts = nfts; // Cache the NFTs
        state = AsyncValue.data(_filteredNfts());

        // Cache the fetched NFTs in SharedPreferences
        final storageService = ref.read(storageProvider);
        final String encodedNfts =
            jsonEncode(nfts.map((nft) => nft.toJson()).toList());
        await storageService.prefs?.setString('cachedNfts', encodedNfts);
      } else {
        throw Exception(
            'Failed to load NFTs with status code: ${response.statusCode}');
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  void setFilter(String filter) {
    _filter = filter;
    state = AsyncValue.data(_filteredNfts());
  }

  void sortNFTs(Sorting sorting) {
    _sorting = sorting;
    state = AsyncValue.data(_filteredNfts());
  }

  List<NFT> _filteredNfts() {
    List<NFT> filteredNfts = _allNfts;

    if (_filter.isNotEmpty) {
      filteredNfts = filteredNfts.where((nft) {
        final nameLower = nft.name.toLowerCase();
        final filterLower = _filter.toLowerCase();
        return nameLower.contains(filterLower);
      }).toList();
    }

    switch (_sorting) {
      case Sorting.assetId:
        filteredNfts.sort((a, b) => a.tokenId.compareTo(b.tokenId));
        break;
      case Sorting.name:
        filteredNfts.sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
      default:
        break;
    }

    return filteredNfts;
  }
}
