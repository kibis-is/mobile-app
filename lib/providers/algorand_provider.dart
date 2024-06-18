import 'package:algorand_dart/algorand_dart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/models/detailed_asset.dart';

// Define a provider for managing the Algorand instance
final algorandProvider = Provider<Algorand>((ref) {
  final algodClient = AlgodClient(
    apiUrl: "https://testnet-api.voi.nodly.io",
    apiKey: "",
    tokenKey: "",
  );

  final indexerClient = IndexerClient(
    apiUrl: "https://testnet-idx.voi.nodly.io",
    apiKey: "",
    tokenKey: "",
  );

  return Algorand(algodClient: algodClient, indexerClient: indexerClient);
});

final algorandServiceProvider = Provider<AlgorandService>((ref) {
  final algorand = ref.watch(algorandProvider);
  return AlgorandService(algorand);
});

class AlgorandService {
  final Algorand algorand;

  AlgorandService(this.algorand);

  Future<String> sendCurrency(
      Account senderAccount, String recipientAddress, double amountInAlgos,
      [String? note]) async {
    try {
      Address address = Address.fromAlgorandAddress(address: recipientAddress);
      final amountInMicroAlgos = Algo.toMicroAlgos(amountInAlgos);

      final txId = await algorand.sendPayment(
        account: senderAccount,
        recipient: address,
        amount: amountInMicroAlgos,
        note: note,
      );

      debugPrint("Payment successful: Transaction ID: $txId");
      return txId;
    } catch (e) {
      debugPrint("Failed to send payment: $e");
      //need to catch wrong address in here
      return 'error';
    }
  }

  Future<List<DetailedAsset>> getAccountAssets(String publicAddress) async {
    try {
      final accountInfo = await algorand.getAccountByAddress(publicAddress);
      final holdings = accountInfo.assets;

      List<DetailedAsset> detailedAssets =
          await Future.wait(holdings.map((holding) async {
        return await _createOrUpdateDetailedAsset(holding, publicAddress);
      }));

      return detailedAssets;
    } catch (e) {
      throw Exception('Failed to fetch assets: $e');
    }
  }

  Future<DetailedAsset> getDetailedAsset(
      String assetId, String publicAddress) async {
    try {
      final int id = int.parse(assetId);

      final accountInfo = await algorand.getAccountByAddress(publicAddress);
      final holding = accountInfo.assets.firstWhere((h) => h.assetId == id,
          orElse: () => throw Exception(
              'Asset with ID $assetId not found in the current holdings.'));

      return await _createOrUpdateDetailedAsset(holding, publicAddress);
    } on FormatException {
      throw Exception(
          'Invalid asset ID format. Asset ID must be a valid integer.');
    } catch (e) {
      throw Exception('Failed to fetch asset details: $e');
    }
  }

  Future<DetailedAsset> _createOrUpdateDetailedAsset(
      AssetHolding holding, String publicAddress) async {
    final response = await algorand.indexer().getAssetById(holding.assetId);
    final assetParams = response.asset.params;

    return DetailedAsset(
      amount: holding.amount,
      assetId: holding.assetId,
      creator: holding.creator,
      isFrozen: holding.isFrozen,
      name: assetParams.name,
      unitName: assetParams.unitName,
      totalSupply: assetParams.total,
      decimals: assetParams.decimals,
      manager: assetParams.manager,
      reserve: assetParams.reserve,
      freeze: assetParams.freeze,
      clawback: assetParams.clawback,
      url: assetParams.url,
      metadataHash: assetParams.metadataHash,
      defaultFrozen: assetParams.defaultFrozen,
    );
  }

  Future<SearchAssetsResponse> getAssets(
      String searchQuery,
      double currencyIsLessThan,
      double currencyIsGreaterThan,
      int searchLimit) async {
    try {
      final maxCurrencyValue = currencyIsGreaterThan.isFinite &&
              currencyIsGreaterThan < double.maxFinite
          ? currencyIsGreaterThan
          : 1e15; // Use a high but reasonable value

      // Logging the input values for debugging
      debugPrint('getAssets called with:');
      debugPrint('searchQuery: $searchQuery');
      debugPrint('currencyIsLessThan: $currencyIsLessThan');
      debugPrint('currencyIsGreaterThan: $maxCurrencyValue');
      debugPrint('searchLimit: $searchLimit');

      var assetsQuery = algorand
          .indexer()
          .assets()
          .whereCurrencyIsLessThan(Algo.toMicroAlgos(currencyIsLessThan))
          .whereCurrencyIsGreaterThan(Algo.toMicroAlgos(maxCurrencyValue));

      if (int.tryParse(searchQuery) != null) {
        assetsQuery = assetsQuery.whereAssetId(int.parse(searchQuery));
      } else if (_isValidAlgorandAddress(searchQuery)) {
        assetsQuery = assetsQuery.whereCreator(searchQuery);
      } else if (searchQuery.length > 1) {
        assetsQuery = assetsQuery.whereUnitName(searchQuery);
      } else {
        throw Exception('Search query is too short.');
      }

      final SearchAssetsResponse assets =
          await assetsQuery.search(limit: searchLimit);
      return assets;
    } on AlgorandException catch (e) {
      debugPrint('AlgorandException: ${e.toString()}');
      throw Exception('Failed to fetch assets: ${e.message}');
    } catch (e) {
      debugPrint('General Exception: $e');
      throw Exception('Failed to fetch assets: $e');
    }
  }

  bool _isValidAlgorandAddress(String address) {
    try {
      Address.fromAlgorandAddress(address: address);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<String> getAccountBalance(String publicAddress) async {
    try {
      final accountInfo = await algorand.getAccountByAddress(publicAddress);
      final balance = accountInfo.amount;
      return Algo.fromMicroAlgos(balance).toString();
    } on AlgorandException catch (e) {
      debugPrint('Algorand Exception: ${e.message}');
      return '0';
    } catch (e) {
      debugPrint('General Exception: $e');
      throw Exception('Failed to get account balance: $e');
    }
  }

  Future<String> createAsset(Account account, String assetName, String unitName,
      int totalAssets, int decimals) async {
    try {
      final transactionId = await algorand.assetManager.createAsset(
        account: account,
        assetName: assetName,
        unitName: unitName,
        totalAssets: totalAssets,
        decimals: decimals,
      );
      return transactionId;
    } catch (e) {
      debugPrint("Failed to create asset: $e");
      throw Exception("Failed to create asset: $e");
    }
  }

  // Edit an asset
  Future<void> editAsset({
    required int assetId,
    required Account account,
    required String managerAddress,
    required String reserveAddress,
    required String freezeAddress,
    required String clawbackAddress,
  }) async {
    try {
      // Convert string addresses to Address objects
      Address manager = Address.fromAlgorandAddress(address: managerAddress);
      Address reserve = Address.fromAlgorandAddress(address: reserveAddress);
      Address freeze = Address.fromAlgorandAddress(address: freezeAddress);
      Address clawback = Address.fromAlgorandAddress(address: clawbackAddress);

      // Edit the asset using the AssetManager from the SDK
      await algorand.assetManager.editAsset(
        assetId: assetId,
        account: account,
        managerAddress: manager,
        reserveAddress: reserve,
        freezeAddress: freeze,
        clawbackAddress: clawback,
      );
      debugPrint("Asset edited successfully: Asset ID $assetId");
    } catch (e) {
      debugPrint("Failed to edit asset: $e");
      throw Exception("Failed to edit asset: $e");
    }
  }

  // Destroy an asset
  Future<void> destroyAsset(int assetId, Account account) async {
    try {
      await algorand.assetManager.destroyAsset(
        assetId: assetId,
        account: account,
      );
    } catch (e) {
      debugPrint("Failed to destroy asset: $e");
      throw Exception("Failed to destroy asset: $e");
    }
  }

  // Opt-in to an asset
  Future<void> optInAsset(int assetId, Account account) async {
    try {
      await algorand.assetManager.optIn(
        assetId: assetId,
        account: account,
      );
    } catch (e) {
      debugPrint("Failed to opt-in to asset: $e");
      throw Exception("Failed to opt-in to asset: $e");
    }
  }

  Future<void> transferAsset(int assetId, Account senderAccount,
      String receiverAddress, int amount) async {
    try {
      await algorand.assetManager.transfer(
        assetId: assetId,
        account: senderAccount,
        receiver: Address.fromAlgorandAddress(address: receiverAddress),
        amount: amount,
      );
    } catch (e) {
      debugPrint("Failed to transfer asset: ${e.toString()}");
      if (e is AlgorandException) {
        debugPrint("AlgorandException Details: ${e.message}");
      }
      throw Exception("Failed to transfer asset: ${e.toString()}");
    }
  }

  String parseAlgorandException(AlgorandException e) {
    if (e.message.contains('frozen')) {
      return 'The asset you are trying to send is frozen and cannot be transferred.';
    }
    return e.toString();
  }

  Future<void> toggleFreezeAsset({
    required int assetId,
    required Account account,
    required bool freeze,
  }) async {
    try {
      await algorand.assetManager.freeze(
        assetId: assetId,
        account: account,
        freezeTarget:
            Address.fromAlgorandAddress(address: account.publicAddress),
        freeze: freeze,
      );
      debugPrint(
          "Successfully ${freeze ? 'froze' : 'unfroze'} asset with ID: $assetId");
    } on AlgorandException catch (e) {
      debugPrint(
          "Failed to ${freeze ? 'freeze' : 'unfreeze'} asset with ID: $assetId: ${e.message}");
      rethrow;
    } catch (e) {
      debugPrint(
          "Failed to ${freeze ? 'freeze' : 'unfreeze'} asset with ID: $assetId: $e");
      throw AlgorandException(
        message: "Failed to ${freeze ? 'freeze' : 'unfreeze'} asset: $e",
        cause: e,
      );
    }
  }

  Future<void> revokeAsset(
      int assetId, Account account, int amount, String revokeAddress) async {
    try {
      await algorand.assetManager.revoke(
        assetId: assetId,
        account: account,
        amount: amount,
        revokeAddress: Address.fromAlgorandAddress(address: revokeAddress),
      );
    } catch (e) {
      debugPrint("Failed to revoke asset: $e");
      throw Exception("Failed to revoke asset: $e");
    }
  }

  Future<List<Transaction>> getTransactions(
    String publicAddress, {
    int? limit,
    double? minAmount,
    double? maxAmount,
    int? assetId,
    String? notePrefix,
    TransactionType? transactionType,
  }) async {
    try {
      var query = algorand
          .indexer()
          .transactions()
          .whereAddress(Address.fromAlgorandAddress(address: publicAddress));

      // Apply optional filters
      if (minAmount != null) {
        query = query.whereCurrencyIsGreaterThan(Algo.toMicroAlgos(minAmount));
      }
      if (maxAmount != null) {
        query = query.whereCurrencyIsLessThan(Algo.toMicroAlgos(maxAmount));
      }
      if (assetId != null) {
        query = query.whereAssetId(assetId);
      }
      if (notePrefix != null) {
        query = query.whereNotePrefix(notePrefix);
      }
      if (transactionType != null) {
        query = query.whereTransactionType(transactionType);
      }

      final transactions = await query.search(limit: limit ?? 10);
      return transactions.transactions;
    } catch (e) {
      debugPrint('Failed to fetch transactions: $e');
      return [];
    }
  }
}
