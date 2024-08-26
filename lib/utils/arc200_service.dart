import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/combined_asset.dart';

class Arc200Service {
  final String baseUrl;

  Arc200Service(
      {this.baseUrl = 'https://arc72-idx.nautilus.sh/nft-indexer/v1/arc200'});

  Future<List<CombinedAsset>> fetchArc200Assets(String publicAddress) async {
    final balancesUrl = '$baseUrl/balances?accountId=$publicAddress';
    final balancesResponse = await http.get(Uri.parse(balancesUrl));

    if (balancesResponse.statusCode != 200) {
      throw Exception('Failed to load ARC200 balances');
    }

    final balancesJson = json.decode(balancesResponse.body);
    final List<dynamic> balances = balancesJson['balances'];

    List<CombinedAsset> assets = [];

    for (var balance in balances) {
      final contractId = balance['contractId'];
      final tokenDetails = await fetchArc200TokenDetails(contractId);

      assets.add(CombinedAsset(
        index: contractId,
        params: CombinedAssetParameters.fromArc200(tokenDetails),
        assetType: AssetType.arc200,
      ));
    }

    return assets;
  }

  Future<Map<String, dynamic>> fetchArc200TokenDetails(int contractId) async {
    final tokenUrl = '$baseUrl/tokens?contractId=$contractId';
    final tokenResponse = await http.get(Uri.parse(tokenUrl));

    if (tokenResponse.statusCode != 200) {
      throw Exception('Failed to load ARC200 token details');
    }

    final tokenJson = json.decode(tokenResponse.body);
    final token = tokenJson['tokens'][0];
    return token;
  }
}
