import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/generated/l10n.dart';
import 'package:kibisis/models/combined_asset.dart';
import 'package:kibisis/providers/network_provider.dart';

final arc200ServiceProvider = Provider<Arc200Service>((ref) {
  return Arc200Service(ref);
});

class Arc200Service {
  late final String baseUrl;

  Arc200Service(Ref ref) {
    final network = ref.watch(networkProvider);
    switch (network?.value) {
      case "network-voi-mainnet":
        baseUrl = 'https://mainnet-idx.nautilus.sh/nft-indexer/v1/arc200';
        break;
      case "network-voi-testnet":
        baseUrl = 'https://testnet-idx.nautilus.sh/nft-indexer/v1/arc200';
        break;
      case "network-algorand-mainnet":
      case "network-algorand-testnet":
      default:
        baseUrl = '';
        break;
    }
  }

  Future<List<CombinedAsset>> fetchArc200Assets(String publicAddress) async {
    if (baseUrl.isEmpty) {
      debugPrint('No ARC200 assets available for the selected network.');
      return [];
    }

    try {
      final balancesUrl = '$baseUrl/balances?accountId=$publicAddress';
      final balancesResponse = await http.get(Uri.parse(balancesUrl));

      if (balancesResponse.statusCode != 200) {
        throw Exception(S.current.failedToLoadArc200Balances);
      }

      final balancesJson = json.decode(balancesResponse.body);
      final List<dynamic> balances = balancesJson['balances'];

      List<CombinedAsset> assets = [];

      for (var balance in balances) {
        final contractId = balance['contractId'];
        final tokenDetails = await fetchArc200TokenDetails(contractId);
        final amount = int.parse(balance['balance']);

        assets.add(CombinedAsset(
          index: contractId,
          params: CombinedAssetParameters.fromArc200(tokenDetails),
          assetType: AssetType.arc200,
          amount: amount,
          isFrozen: balance['isFrozen'] ?? false,
        ));
      }

      debugPrint('Fetched ARC200 assets: $assets');
      return assets;
    } catch (e) {
      debugPrint('Exception in fetchArc200Assets: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> fetchArc200TokenDetails(int contractId) async {
    if (baseUrl.isEmpty) {
      throw Exception(S.current.noArc200TokenDetailsForNetwork);
    }

    final tokenUrl = '$baseUrl/tokens?contractId=$contractId';
    final tokenResponse = await http.get(Uri.parse(tokenUrl));

    if (tokenResponse.statusCode != 200) {
      throw Exception(S.current.failedToLoadArc200TokenDetails);
    }

    final tokenJson = json.decode(tokenResponse.body);
    final token = tokenJson['tokens']?[0];

    if (token == null) {
      throw Exception(S.current.tokenDetailsNotFound(contractId.toString()));
    }

    return token;
  }

  Future<List<CombinedAsset>> searchArc200AssetsByContractIdOrName(
      String query) async {
    if (baseUrl.isEmpty) {
      debugPrint(
          'No ARC200 assets available for searching in the selected network.');
      return [];
    }

    final searchUrl = '$baseUrl/tokens?limit=100';
    try {
      final response = await http.get(Uri.parse(searchUrl));

      if (response.statusCode != 200) {
        throw Exception(S.current.failedToSearchArc200Assets);
      }

      final jsonResponse = json.decode(response.body);
      final List<dynamic> tokens = jsonResponse['tokens'] ?? [];

      final matchingAssets = tokens.where((data) {
        final contractIdMatches = data['contractId'].toString().contains(query);
        final nameMatches =
            data['name']?.toLowerCase()?.contains(query.toLowerCase()) ?? false;
        final symbolMatches =
            data['symbol']?.toLowerCase()?.contains(query.toLowerCase()) ??
                false;

        return contractIdMatches || nameMatches || symbolMatches;
      }).map<CombinedAsset>((data) {
        return CombinedAsset(
          index: data['contractId'] ?? '',
          params: CombinedAssetParameters.fromArc200(data),
          assetType: AssetType.arc200,
          amount: data['amount'] ?? 0,
          isFrozen: data['isFrozen'] ?? false,
        );
      }).toList();
      return matchingAssets;
    } catch (e) {
      debugPrint('Error searching ARC-0200 assets: $e');
      return [];
    }
  }

  Future<BigInt> getArc200Balance({
    required int contractId,
    required String publicAddress,
  }) async {
    if (baseUrl.isEmpty) {
      throw Exception(S.current.networkNotConfiguredForArc200);
    }

    try {
      final balanceUrl =
          '$baseUrl/balances?accountId=$publicAddress&contractId=$contractId';

      final response = await http.get(Uri.parse(balanceUrl));
      if (response.statusCode != 200) {
        throw Exception(
            S.current.failedToFetchArc200Balance(contractId.toString()));
      }

      final balanceJson = json.decode(response.body);
      final balanceList = balanceJson['balances'];

      if (balanceList == null || balanceList.isEmpty) {
        throw Exception(
            S.current.assetNotFoundForContract(contractId.toString()));
      }

      return BigInt.parse(balanceList[0]['balance']);
    } catch (e) {
      debugPrint('Error fetching ARC200 balance for contract $contractId: $e');
      throw Exception(
          S.current.failedToFetchArc200Balance(contractId.toString()));
    }
  }
}
