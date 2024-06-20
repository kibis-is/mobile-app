import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/models/detailed_asset.dart';
import 'package:kibisis/providers/algorand_provider.dart';
import 'package:algorand_dart/algorand_dart.dart';

final assetsProvider =
    StateNotifierProvider<AssetsNotifier, AsyncValue<List<DetailedAsset>>>(
        (ref) {
  return AssetsNotifier(ref);
});

class AssetsNotifier extends StateNotifier<AsyncValue<List<DetailedAsset>>> {
  final Ref ref;

  AssetsNotifier(this.ref) : super(const AsyncValue.loading());

  Future<void> getAccountAssets(String address) async {
    final algorandService = ref.read(algorandServiceProvider);

    if (address.isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }
    try {
      final assets = await algorandService.getAccountAssets(address);
      state = AsyncValue.data(assets);
    } on AlgorandException {
      if (mounted) {
        state = AsyncValue.error('Failed to fetch assets', StackTrace.current);
      }
    } catch (e) {
      if (mounted) {
        state = AsyncValue.error(e, StackTrace.current);
      }
    }
  }
}
