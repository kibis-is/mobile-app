import 'package:algorand_dart/algorand_dart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'algorand_service.dart';

final algorandProvider = Provider<Algorand>((ref) {
  final algodClient = AlgodClient(
    apiUrl: "https://testnet-api.voi.nodly.io",
  );

  final indexerClient = IndexerClient(
    apiUrl: "https://testnet-idx.voi.nodly.io",
  );

  return Algorand(algodClient: algodClient, indexerClient: indexerClient);
});

final algorandServiceProvider = Provider<AlgorandService>((ref) {
  final algorand = ref.watch(algorandProvider);
  return AlgorandService(algorand);
});
