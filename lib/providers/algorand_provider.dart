import 'package:algorand_dart/algorand_dart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/models/select_item.dart';
import 'package:kibisis/providers/network_provider.dart';
import 'algorand_service.dart';

final algorandProvider = Provider<Algorand>((ref) {
  final SelectItem? currentNetwork = ref.watch(networkProvider);

  // Set default to mainnet values
  String algodUrl = "https://mainnet-api.voi.nodely.dev";
  String indexerUrl = "https://mainnet-idx.voi.nodely.dev";

  // Adjust for testnet if that's the selected network
  if (currentNetwork?.value == "network-voi-testnet") {
    algodUrl = "https://testnet-api.voi.nodly.io";
    indexerUrl = "https://testnet-idx.voi.nodly.io";
  }

  final algodClient = AlgodClient(apiUrl: algodUrl);
  final indexerClient = IndexerClient(apiUrl: indexerUrl);

  return Algorand(algodClient: algodClient, indexerClient: indexerClient);
});

final algorandServiceProvider = Provider<AlgorandService>((ref) {
  final algorand = ref.watch(algorandProvider);
  return AlgorandService(algorand);
});
