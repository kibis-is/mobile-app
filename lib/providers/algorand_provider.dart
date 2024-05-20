import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:algorand_dart/algorand_dart.dart';

// Define a provider for managing the Algorand instance
final algorandProvider = Provider<Algorand>((ref) {
  return Algorand(); // Assuming Algorand() constructor sets up the necessary Algorand client
});

// Using AlgorandProvider in a consumer, where you can access and use the Algorand instance
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
}
