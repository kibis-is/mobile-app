import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:algorand_dart/algorand_dart.dart';
import 'package:flutter/material.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/models/combined_asset.dart';

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

      if (txId.isNotEmpty && txId != 'error') {
        final transactionResponse =
            await algorand.waitForConfirmation(txId, timeout: 4);

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

  Future<List<CombinedAsset>> getAccountAssets(String publicAddress) async {
    try {
      final accountInfo = await _fetchAccountInfo(publicAddress);
      final holdings = accountInfo.data['assets'] as List<dynamic>;
      final List<Future<CombinedAsset?>> assetFutures = holdings.map((holding) {
        return _fetchAndConvertAsset(holding);
      }).toList();

      // Waiting for all asset futures to complete
      final List<CombinedAsset?> assets = await Future.wait(assetFutures);

      // Filtering out valid assets
      final List<CombinedAsset> validAssets = _filterValidAssets(assets);
      return validAssets;
    } on AlgorandException catch (e) {
      debugPrint('Get Account Assets Algorand Exception: ${e.message}');
      return <CombinedAsset>[];
    } catch (e) {
      debugPrint('Failed to fetch assets: $e');
      return <CombinedAsset>[];
    }
  }

  Future<dynamic> _fetchAccountInfo(String publicAddress) async {
    try {
      final response =
          await algorand.algodClient.client.get('/v2/accounts/$publicAddress');
      return response;
    } on AlgorandException catch (e) {
      debugPrint('Failed to fetch account info: ${e.message}');
      rethrow; // Rethrow to be caught by the main function's try-catch
    } catch (e) {
      debugPrint(
          'Generic Exception fetching account info for $publicAddress: $e');
      rethrow;
    }
  }

  Future<CombinedAsset?> _fetchAndConvertAsset(
      Map<String, dynamic> holding) async {
    final int assetId = holding['asset-id'];
    final int amount = holding['amount'];
    final bool isFrozen = holding['is-frozen'];

    try {
      final AssetResponse response =
          await algorand.indexer().getAssetById(assetId);

      final asset = _convertToCombinedAsset(response.asset, amount, isFrozen);
      return asset;
    } on AlgorandException catch (e) {
      debugPrint('AlgorandException for assetId $assetId: ${e.message}');
      return null;
    } catch (e) {
      debugPrint(
          'Generic Exception fetching or converting asset for assetId $assetId: $e');
      return null;
    }
  }

  CombinedAsset _convertToCombinedAsset(
      Asset asset, int amount, bool isFrozen) {
    debugPrint('Converting asset with id: ${asset.index}');

    final combinedAsset = CombinedAsset(
      index: asset.index,
      params: CombinedAssetParameters(
        total: asset.params.total,
        decimals: asset.params.decimals,
        creator: asset.params.creator,
        clawback: asset.params.clawback,
        defaultFrozen: asset.params.defaultFrozen,
        freeze: asset.params.freeze,
        manager: asset.params.manager,
        name: asset.params.name,
        reserve: asset.params.reserve,
        unitName: asset.params.unitName,
        url: asset.params.url,
        metadataHash: asset.params.metadataHash,
      ),
      createdAtRound: asset.createdAtRound,
      deleted: asset.deleted,
      destroyedAtRound: asset.destroyedAtRound,
      assetType: AssetType.standard,
      amount: amount,
      isFrozen: isFrozen,
    );

    debugPrint('Conversion complete for asset with id: ${asset.index}');
    return combinedAsset;
  }

  List<CombinedAsset> _filterValidAssets(List<CombinedAsset?> assets) {
    final validAssets =
        assets.where((asset) => asset != null).cast<CombinedAsset>().toList();
    debugPrint(
        'Filtered valid assets: ${validAssets.length} out of ${assets.length}');
    return validAssets;
  }

  Future<CombinedAsset> getAssetById(int assetId,
      {String? publicAddress}) async {
    try {
      final AssetResponse response =
          await algorand.indexer().getAssetById(assetId);

      int amount = 0;
      bool isFrozen = false;

      if (publicAddress != null) {
        final accountInfo = await algorand.algodClient.client
            .get('/v2/accounts/$publicAddress');
        final holdings = accountInfo.data['assets'] as List<dynamic>;

        final holding = holdings.firstWhere(
            (holding) => holding['asset-id'] == assetId,
            orElse: () => null);

        if (holding != null) {
          amount = holding['amount'];
          isFrozen = holding['is-frozen'];
        }
      }

      return CombinedAsset(
        index: response.asset.index,
        params: CombinedAssetParameters(
          total: response.asset.params.total,
          decimals: response.asset.params.decimals,
          creator: response.asset.params.creator,
          clawback: response.asset.params.clawback,
          defaultFrozen: response.asset.params.defaultFrozen,
          freeze: response.asset.params.freeze,
          manager: response.asset.params.manager,
          name: response.asset.params.name,
          reserve: response.asset.params.reserve,
          unitName: response.asset.params.unitName,
          url: response.asset.params.url,
          metadataHash: response.asset.params.metadataHash,
        ),
        createdAtRound: response.asset.createdAtRound,
        deleted: response.asset.deleted,
        destroyedAtRound: response.asset.destroyedAtRound,
        assetType: AssetType.standard,
        amount: amount,
        isFrozen: isFrozen,
      );
    } on FormatException {
      debugPrint('Invalid asset ID format. Asset ID must be a valid integer.');
      throw Exception(
          'Invalid asset ID format. Asset ID must be a valid integer.');
    } catch (e) {
      debugPrint('Failed to fetch asset details: $e');
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
          : 1e15;
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
      debugPrint('Search Assets AlgorandException: ${e.message}');
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
      final response =
          await algorand.algodClient.client.get('/v2/accounts/$publicAddress');

      final balance = response.data['amount'] as int?;

      if (balance == null) {
        debugPrint('Account balance not found in the response.');
        return '0';
      }

      return Algo.fromMicroAlgos(balance).toString();
    } catch (e) {
      if (e.toString().contains('404')) {
        debugPrint('Account not found for $publicAddress');
        return '0';
      } else {
        debugPrint('General Exception: $e');
        throw Exception('Failed to get account balance: $e');
      }
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
    } on AlgorandException catch (e) {
      debugPrint(e.message);
      throw Exception("Failed to opt-in to asset: ${e.message}");
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
      return 'Asset is frozen';
    }
    return e.message;
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

  Future<int> deployContract(Account account) async {
    try {
      // Load the TEAL files from the filesystem
      final approvalProgramSource =
          await File('teal/approval.teal').readAsString();
      final clearProgramSource =
          await File('teal/clear_state.teal').readAsString();

      // Compile the TEAL programs
      final approvalProgram =
          await algorand.applicationManager.compileTEAL(approvalProgramSource);
      final clearProgram =
          await algorand.applicationManager.compileTEAL(clearProgramSource);

      // Get the suggested transaction params
      final params = await algorand.getSuggestedTransactionParams();

      // Build and deploy the smart contract
      final transaction = await (ApplicationCreateTransactionBuilder()
            ..sender = account.address
            ..approvalProgram = approvalProgram.program
            ..clearStateProgram = clearProgram.program
            ..globalStateSchema = StateSchema(
              numUint: 1,
              numByteSlice: 0,
            )
            ..localStateSchema = StateSchema(
              numUint: 1,
              numByteSlice: 1,
            )
            ..suggestedParams = params)
          .build();

      final signedTx = await transaction.sign(account);

      debugPrint('Signed Transaction Details:');
      debugPrint('Transaction ID: ${signedTx.transaction.id}');
      debugPrint('Transaction Sender: ${signedTx.transaction.sender}');
      debugPrint('Transaction Fee: ${signedTx.transaction.fee}');
      debugPrint('Transaction First Valid: ${signedTx.transaction.firstValid}');
      debugPrint('Transaction Last Valid: ${signedTx.transaction.lastValid}');
      debugPrint('Transaction Genesis ID: ${signedTx.transaction.genesisId}');
      debugPrint(
          'Transaction Genesis Hash: ${signedTx.transaction.genesisHash}');
      debugPrint('Transaction Group: ${signedTx.transaction.group}');
      debugPrint('Transaction Lease: ${signedTx.transaction.lease}');
      debugPrint('Transaction Note: ${signedTx.transaction.note}');
      debugPrint('Transaction Type: ${signedTx.transaction.type}');
      debugPrint('Transaction RekeyTo: ${signedTx.transaction.rekeyTo}');
      debugPrint('Signed Transaction Signature: ${signedTx.signature}');

      final txId =
          await algorand.sendTransaction(signedTx, waitForConfirmation: true);

      final transactionResponse =
          await algorand.getPendingTransactionById(txId);

      if (transactionResponse.applicationIndex == null) {
        throw Exception("Transaction failed, no Application ID returned.");
      }

      final applicationId = transactionResponse.applicationIndex!;
      debugPrint('Smart contract deployed with Application ID: $applicationId');
      return applicationId;
    } on AlgorandException catch (e, stackTrace) {
      debugPrint("AlgorandException Message: ${e.message}");
      debugPrint("AlgorandException Details: ${e.error}");
      debugPrint("AlgorandException StackTrace: $stackTrace");
      throw Exception("Failed to deploy smart contract: ${e.message}");
    } catch (e, stackTrace) {
      debugPrint("General Exception: $e");
      debugPrint("General Exception StackTrace: $stackTrace");
      throw Exception("Failed to deploy smart contract: $e");
    }
  }

  Future<void> optInToContract(int applicationId, Account account) async {
    try {
      final params = await algorand.getSuggestedTransactionParams();

      final transaction = await (ApplicationOptInTransactionBuilder()
            ..sender = account.address
            ..applicationId = applicationId
            ..suggestedParams = params)
          .build();

      final signedTx = await transaction.sign(account);
      final txId =
          await algorand.sendTransaction(signedTx, waitForConfirmation: true);

      debugPrint('Opted into contract with transaction ID: $txId');
    } catch (e) {
      debugPrint("Failed to opt-in to contract: $e");
      throw Exception("Failed to opt-in to contract: $e");
    }
  }

  Future<void> callContract(
      int applicationId, Account account, List<String> arguments) async {
    try {
      final params = await algorand.getSuggestedTransactionParams();

      final convertedArgs =
          arguments.map((arg) => Uint8List.fromList(arg.codeUnits)).toList();

      final transaction = await (ApplicationCallTransactionBuilder()
            ..sender = account.address
            ..applicationId = applicationId
            ..arguments = convertedArgs
            ..suggestedParams = params)
          .build();

      final signedTx = await transaction.sign(account);
      final txId =
          await algorand.sendTransaction(signedTx, waitForConfirmation: true);

      debugPrint('Contract call made with transaction ID: $txId');
    } catch (e) {
      debugPrint("Failed to call contract: $e");
      throw Exception("Failed to call contract: $e");
    }
  }
}
