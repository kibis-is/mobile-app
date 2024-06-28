import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/providers/account_provider.dart';
import 'package:kibisis/providers/algorand_provider.dart';
import 'package:algorand_dart/algorand_dart.dart';

final assetsProvider =
    StateNotifierProvider<AssetsNotifier, AsyncValue<List<Asset>>>((ref) {
  final publicAddress = ref.watch(accountProvider).account?.publicAddress ?? '';
  return AssetsNotifier(ref, publicAddress);
});

class AssetsNotifier extends StateNotifier<AsyncValue<List<Asset>>> {
  final Ref ref;
  final String publicAddress;

  AssetsNotifier(this.ref, this.publicAddress)
      : super(const AsyncValue.loading()) {
    fetchAssets();
  }

  Future<void> fetchAssets() async {
    if (publicAddress.isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }
    try {
      final algorandService = ref.read(algorandServiceProvider);
      final assets = await algorandService.getAccountAssets(publicAddress);
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
