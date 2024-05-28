import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/models/asset.dart';
import 'package:kibisis/providers/algorand_provider.dart';
import 'package:algorand_dart/algorand_dart.dart';

final assetsProvider =
    FutureProvider.family<List<AccountAsset>, String>((ref, address) async {
  final algorandService = ref.watch(algorandServiceProvider);
  if (address.isEmpty) {
    return [];
  }
  try {
    return await algorandService.getAccountAssets(address);
  } on AlgorandException {
    return [];
  } catch (e) {
    rethrow;
  }
});
