import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/features/dashboard/widgets/assets_tab.dart';
import 'package:kibisis/generated/l10n.dart';
import 'package:kibisis/models/nft.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kibisis/providers/account_provider.dart';
import 'package:kibisis/providers/network_provider.dart';
import 'package:kibisis/providers/storage_provider.dart';

final nftNotifierProvider =
    StateNotifierProvider<NFTNotifier, AsyncValue<List<NFT>>>((ref) {
  final publicAddress = ref.watch(accountProvider).account?.address;
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
  bool _isLoadingMore = false;
  String? _nextToken;

  NFTNotifier(this.ref, this.publicAddress)
      : super(const AsyncValue.loading()) {
    _loadCachedNFTs();
  }

  String get filterText => _filter;

  Future<void> fetchNFTs({bool isInitialLoad = false, int limit = 20}) async {
    if (publicAddress.isEmpty || _isLoadingMore) return;

    _isLoadingMore = true;
    try {
      final currentNetwork = ref.read(networkProvider);
      final baseUrl = _getBaseUrl(currentNetwork);
      if (baseUrl == null) {
        // Unsupported network: update state to empty list and exit.
        state = const AsyncValue.data([]);
        return;
      }

      final url = _buildUrl(baseUrl, isInitialLoad, limit);
      final response = await http.get(Uri.parse(url));

      if (response.statusCode != 200) {
        throw Exception(S.current.failedToLoadNFTs(response.statusCode));
      }

      final body = json.decode(response.body);
      final List<dynamic> tokens = body['tokens'];
      _nextToken = body['next'];

      if (tokens.isEmpty && isInitialLoad) {
        state = const AsyncValue.data([]);
        return;
      }

      final List<NFT> nfts = tokens.map<NFT>(_parseNFT).toList();

      if (isInitialLoad) {
        _allNfts = nfts;
      } else {
        _allNfts.addAll(nfts);
      }

      state = AsyncValue.data(_filteredNfts());
      final selectedNetwork = ref.watch(networkProvider);
      final storageService = ref.read(storageProvider);
      await storageService.setNFTsForAccount(
          publicAddress, selectedNetwork?.name ?? '', _allNfts);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    } finally {
      _isLoadingMore = false;
    }
  }

  String? _getBaseUrl(dynamic network) {
    if (network?.value == "network-voi-testnet") {
      return 'https://arc72-idx.nftnavigator.xyz/nft-indexer/v1/tokens';
    } else if (network?.value == "network-voi-mainnet") {
      return 'https://arc72-voi-mainnet.nftnavigator.xyz/nft-indexer/v1/tokens';
    }
    return null;
  }

  String _buildUrl(String baseUrl, bool isInitialLoad, int limit) {
    return isInitialLoad
        ? '$baseUrl?owner=$publicAddress&limit=$limit'
        : '$baseUrl?owner=$publicAddress&next=$_nextToken&limit=$limit';
  }

  NFT _parseNFT(dynamic json) {
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
  }

  bool get isLoadingMore => _isLoadingMore;

  void loadMoreNFTs({int limit = 20}) async {
    if (_nextToken != null && !_isLoadingMore) {
      await fetchNFTs(limit: limit);
    }
  }

  Future<void> _loadCachedNFTs() async {
    final storageService = ref.read(storageProvider);
    final network = ref.read(networkProvider);
    _allNfts = await storageService.getNFTsForAccount(
        publicAddress, network?.name ?? '');

    if (_allNfts.isNotEmpty) {
      state = AsyncValue.data(_filteredNfts());
    } else {
      await fetchNFTs(isInitialLoad: true);
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
