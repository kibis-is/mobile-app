import 'package:algorand_dart/algorand_dart.dart';
import 'package:flutter/material.dart';

class AlgorandService {
  final Algorand algorand;

  AlgorandService(this.algorand);
  Future<String> sendPayment(
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

      // Check that the transaction ID is not 'error' or empty
      if (txId.isNotEmpty && txId != 'error') {
        // Wait for the transaction to be confirmed with a specified timeout
        final transactionResponse =
            await algorand.waitForConfirmation(txId, timeout: 4);

        // Check that confirmedRound is not null and greater than zero
        if (transactionResponse.confirmedRound != null &&
            transactionResponse.confirmedRound! > 0) {
          debugPrint(
              "Transaction confirmed in round: ${transactionResponse.confirmedRound}");
          return txId;
        } else {
          debugPrint(
              "Transaction failed to confirm within the expected rounds.");
          return 'error';
        }
      }
      return txId;
    } catch (e) {
      debugPrint("Failed to send payment: $e");
      return 'error';
    }
  }

  Future<List<Asset>> getAccountAssets(String publicAddress) async {
    try {
      final accountInfo = await algorand.getAccountByAddress(publicAddress);
      final holdings = accountInfo.assets;

      List<Asset> assets = await Future.wait(
        holdings.map((holding) => getAssetById(holding.assetId)),
      );

      return assets;
    } on AlgorandException catch (e) {
      debugPrint('Get Account Assets Algorand Exception: ${e.toString()}');
      // Return an empty list instead of throwing an exception
      return <Asset>[];
    } catch (e) {
      debugPrint('Failed to fetch assets: $e');
      // Return an empty list or handle differently as per your use case
      return <Asset>[];
    }
  }

  Future<Asset> getAssetById(int assetId) async {
    try {
      final response = await algorand.indexer().getAssetById(assetId);
      return response.asset;
    } on FormatException {
      throw Exception(
          'Invalid asset ID format. Asset ID must be a valid integer.');
    } catch (e) {
      throw Exception('Failed to fetch asset details: $e');
    }
  }

  Future<SearchAssetsResponse> searchAssets(
      String searchQuery,
      double currencyIsLessThan,
      double currencyIsGreaterThan,
      int searchLimit) async {
    try {
      final maxCurrencyValue = currencyIsGreaterThan.isFinite &&
              currencyIsGreaterThan < double.maxFinite
          ? currencyIsGreaterThan
          : 1e15; // Use a high but reasonable value

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
      debugPrint('Search Assets AlgorandException: ${e.toString()}');
      throw Exception('Failed to fetch assets zxc: ${e.message}');
    } catch (e) {
      debugPrint('General Exception: $e');
      throw Exception('Failed to fetch assets abc: $e');
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
      debugPrint('Get Balance Algorand Exception: ${e.message}');
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

      // Wait for the transaction to be confirmed
      if (transactionId.isNotEmpty && transactionId != 'error') {
        final transactionResponse =
            await algorand.waitForConfirmation(transactionId, timeout: 4);
        if (transactionResponse.confirmedRound != null &&
            transactionResponse.confirmedRound! > 0) {
          debugPrint(
              "Asset creation confirmed in round: ${transactionResponse.confirmedRound}");
          return transactionId;
        } else {
          debugPrint(
              "Asset creation failed to confirm within the expected rounds.");
          return 'error';
        }
      }
      return transactionId;
    } catch (e) {
      debugPrint("Failed to create asset: $e");
      return 'error';
    }
  }

  Future<void> editAsset({
    required int assetId,
    required Account account,
    required String managerAddress,
    required String reserveAddress,
    required String freezeAddress,
    required String clawbackAddress,
  }) async {
    try {
      Address manager = Address.fromAlgorandAddress(address: managerAddress);
      Address reserve = Address.fromAlgorandAddress(address: reserveAddress);
      Address freeze = Address.fromAlgorandAddress(address: freezeAddress);
      Address clawback = Address.fromAlgorandAddress(address: clawbackAddress);

      final txId = await algorand.assetManager.editAsset(
        assetId: assetId,
        account: account,
        managerAddress: manager,
        reserveAddress: reserve,
        freezeAddress: freeze,
        clawbackAddress: clawback,
      );

      // Wait for the transaction to be confirmed
      if (txId.isNotEmpty && txId != 'error') {
        final transactionResponse =
            await algorand.waitForConfirmation(txId, timeout: 4);
        if (transactionResponse.confirmedRound != null &&
            transactionResponse.confirmedRound! > 0) {
          debugPrint(
              "Asset edit confirmed in round: ${transactionResponse.confirmedRound}");
        } else {
          debugPrint(
              "Asset edit failed to confirm within the expected rounds.");
          throw Exception("Asset edit confirmation failed.");
        }
      }
    } catch (e) {
      debugPrint("Failed to edit asset: $e");
      throw Exception("Failed to edit asset: $e");
    }
  }

  Future<void> destroyAsset(int assetId, Account account) async {
    try {
      final txId = await algorand.assetManager.destroyAsset(
        assetId: assetId,
        account: account,
      );

      // Wait for the transaction to be confirmed
      if (txId.isNotEmpty && txId != 'error') {
        final transactionResponse =
            await algorand.waitForConfirmation(txId, timeout: 4);
        if (transactionResponse.confirmedRound != null &&
            transactionResponse.confirmedRound! > 0) {
          debugPrint(
              "Asset destruction confirmed in round: ${transactionResponse.confirmedRound}");
        } else {
          debugPrint(
              "Asset destruction failed to confirm within the expected rounds.");
          throw Exception("Asset destruction confirmation failed.");
        }
      }
    } catch (e) {
      debugPrint("Failed to destroy asset: $e");
      throw Exception("Failed to destroy asset: $e");
    }
  }

  Future<void> optInAsset(int assetId, Account account) async {
    try {
      final txId = await algorand.assetManager.optIn(
        assetId: assetId,
        account: account,
      );

      // Wait for the transaction to be confirmed
      if (txId.isNotEmpty && txId != 'error') {
        final transactionResponse =
            await algorand.waitForConfirmation(txId, timeout: 4);
        if (transactionResponse.confirmedRound != null &&
            transactionResponse.confirmedRound! > 0) {
          debugPrint(
              "Asset opt-in confirmed in round: ${transactionResponse.confirmedRound}");
        } else {
          debugPrint(
              "Asset opt-in failed to confirm within the expected rounds.");
          throw Exception("Asset opt-in confirmation failed.");
        }
      }
    } catch (e) {
      debugPrint("Failed to opt-in to asset: $e");
      throw Exception("Failed to opt-in to asset: $e");
    }
  }

  Future<void> transferAsset(int assetId, Account senderAccount,
      String receiverAddress, int amount) async {
    try {
      final txId = await algorand.assetManager.transfer(
        assetId: assetId,
        account: senderAccount,
        receiver: Address.fromAlgorandAddress(address: receiverAddress),
        amount: amount,
      );

      // Wait for the transaction to be confirmed
      if (txId.isNotEmpty && txId != 'error') {
        final transactionResponse =
            await algorand.waitForConfirmation(txId, timeout: 4);
        if (transactionResponse.confirmedRound != null &&
            transactionResponse.confirmedRound! > 0) {
          debugPrint(
              "Asset transfer confirmed in round: ${transactionResponse.confirmedRound}");
        } else {
          debugPrint(
              "Asset transfer failed to confirm within the expected rounds.");
          throw Exception("Asset transfer confirmation failed.");
        }
      }
    } catch (e) {
      debugPrint("Failed to transfer asset: ${e.toString()}");
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
