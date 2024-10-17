import 'package:algorand_dart/algorand_dart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/models/select_item.dart';
import 'package:kibisis/providers/network_provider.dart';
import 'algorand_service.dart';

class NetworkConfig {
  final String algodUrl;
  final String indexerUrl;

  NetworkConfig({required this.algodUrl, required this.indexerUrl});
}

final Map<String, NetworkConfig> networkConfigs = {
  "network-algorand-mainnet": NetworkConfig(
    algodUrl: "https://mainnet-api.4160.nodely.dev",
    indexerUrl: "https://mainnet-idx.4160.nodely.dev",
  ),
  "network-algorand-testnet": NetworkConfig(
    algodUrl: "https://testnet-api.4160.nodely.dev",
    indexerUrl: "https://testnet-idx.4160.nodely.dev",
  ),
  "network-voi-mainnet": NetworkConfig(
    algodUrl: "https://mainnet-api.voi.nodely.dev",
    indexerUrl: "https://mainnet-idx.voi.nodely.dev",
  ),
  "network-voi-testnet": NetworkConfig(
    algodUrl: "https://testnet-api.voi.nodly.io",
    indexerUrl: "https://testnet-idx.voi.nodly.io",
  ),
};

final algorandProvider = Provider<Algorand>((ref) {
  final SelectItem? currentNetwork = ref.watch(networkProvider);

  final config = networkConfigs[currentNetwork?.value ?? "network-voi-mainnet"];

  final algodClient = AlgodClient(apiUrl: config?.algodUrl ?? "");
  final indexerClient = IndexerClient(apiUrl: config?.indexerUrl ?? "");

  return Algorand(algodClient: algodClient, indexerClient: indexerClient);
});

final algorandServiceProvider = Provider<AlgorandService>((ref) {
  final algorand = ref.watch(algorandProvider);
  return AlgorandService(algorand);
});
