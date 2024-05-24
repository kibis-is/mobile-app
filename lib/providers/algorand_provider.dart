import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:algorand_dart/algorand_dart.dart';
import 'package:kibisis/models/asset.dart';

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

  Future<void> sendPayment(
      String recipientAddress, double amount, Account account) async {
    try {
      final transactionId =
          await executePaymentTransaction(recipientAddress, amount, account);
      debugPrint("Transaction successful: $transactionId");
    } catch (e) {
      debugPrint("Failed to execute transaction: $e");
    }
  }

  Future<String?> executePaymentTransaction(
      String recipientAddress, double amount, Account account) async {
    try {
      return await algorand.sendPayment(
        account: account,
        recipient: Address.fromAlgorandAddress(address: recipientAddress),
        amount: Algo.toMicroAlgos(amount),
      );
    } catch (e) {
      debugPrint("Failed to execute transaction: $e");
      throw Exception("Failed to execute transaction: $e");
    }
  }

  Future<List<AccountAsset>> getAccountAssets(String address) async {
    try {
      final accountInfo = await algorand.getAccountByAddress(address);
      final createdAssets = accountInfo.createdAssets;

      if (createdAssets.isEmpty) {
        return [];
      }

      // Map the created assets to MockAsset objects
      return createdAssets.map((asset) {
        return AccountAsset(
          name: asset.params.name ?? 'Unnamed Asset',
          subtitle: 'ID: ${asset.index}',
          image:
              'assets/images/asset-logo.svg', // Replace with actual asset image if available
          value: asset.params.total, // or another relevant field
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch assets: $e');
    }
  }

  Future<String> getAccountBalance(String address) async {
    try {
      final accountInfo = await algorand.getAccountByAddress(address);
      final balance = accountInfo.amount;
      return Algo.fromMicroAlgos(balance).toString();
    } on AlgorandException catch (e) {
      debugPrint('AlgorandException: ${e.message}');
      return '0'; // Return 0 balance in case of AlgorandException
    } catch (e) {
      debugPrint('General Exception: $e');
      throw Exception('Failed to get account balance: $e');
    }
  }
}
