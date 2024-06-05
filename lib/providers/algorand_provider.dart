import 'package:algorand_dart/algorand_dart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  Future<String> sendCurrency(Account senderAccount, String recipientAddress,
      double amountInAlgos) async {
    try {
      Address address = Address.fromAlgorandAddress(address: recipientAddress);
      final amountInMicroAlgos = Algo.toMicroAlgos(amountInAlgos);

      final txId = await algorand.sendPayment(
        account: senderAccount,
        recipient: address,
        amount: amountInMicroAlgos,
      );

      debugPrint("Payment successful: Transaction ID: $txId");
      return txId;
    } catch (e) {
      debugPrint("Failed to send payment: $e");
      //need to catch wrong address in here
      return 'error';
    }
  }

  Future<List<AssetHolding>> getAccountAssets(String publicAddress) async {
    try {
      final accountInfo = await algorand.getAccountByAddress(publicAddress);
      final assets = accountInfo.assets;

      if (assets.isEmpty) {
        return [];
      }

      return assets;
    } catch (e) {
      throw Exception('Failed to fetch assets: $e');
    }
  }

  Future<List<Asset>> getCreatedAssets(String publicAddress) async {
    try {
      final accountInfo = await algorand.getAccountByAddress(publicAddress);
      final createdAssets = accountInfo.createdAssets;

      if (createdAssets.isEmpty) {
        return [];
      }
      return createdAssets;
    } catch (e) {
      throw Exception('Failed to fetch assets: $e');
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

  // Transfer an asset
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
      debugPrint("Failed to transfer asset: $e");
      throw Exception("Failed to transfer asset: $e");
    }
  }

  // Freeze an asset
  Future<void> freezeAsset(int assetId, Account freezeAccount,
      String freezeTargetAddress, bool freeze) async {
    try {
      await algorand.assetManager.freeze(
        assetId: assetId,
        account: freezeAccount,
        freezeTarget: Address.fromAlgorandAddress(address: freezeTargetAddress),
        freeze: freeze,
      );
    } catch (e) {
      debugPrint("Failed to freeze asset: $e");
      throw Exception("Failed to freeze asset: $e");
    }
  }

  // Revoke an asset
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
}
