import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/providers/account_provider.dart';
import 'package:kibisis/providers/algorand_provider.dart';
import 'package:algorand_dart/algorand_dart.dart';

final assetsProvider =
    StateNotifierProvider<AssetsNotifier, AsyncValue<List<Asset>>>((ref) {
  final publicAddress = ref.watch(accountProvider).account?.publicAddress;
  if (publicAddress != null) {
    return AssetsNotifier(ref, publicAddress);
  }
  return AssetsNotifier(ref, '');
});

class AssetsNotifier extends StateNotifier<AsyncValue<List<Asset>>> {
  final Ref ref;
  final String publicAddress;
  List<Asset> _allAssets = [];
  String _filter = '';

  AssetsNotifier(this.ref, this.publicAddress)
      : super(const AsyncValue.loading()) {
    fetchAssets();
  }

  Future<void> fetchAssets() async {
    if (publicAddress.isEmpty) {
      debugPrint('publicAddress is empty');
      state = const AsyncValue.data([]);
      return;
    }
    try {
      final algorandService = ref.read(algorandServiceProvider);
      _allAssets = await algorandService.getAccountAssets(publicAddress);
      debugPrint('fetched assets with publicAddress: $publicAddress');
      state = AsyncValue.data(_filteredAssets());
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

  void setFilter(String filter) {
    _filter = filter;
    state = AsyncValue.data(_filteredAssets());
  }

  List<Asset> _filteredAssets() {
    if (_filter.isEmpty) {
      return _allAssets;
    }
    return _allAssets
        .where((asset) =>
            asset.params.name?.toLowerCase().contains(_filter.toLowerCase()) ??
            false)
        .toList();
  }
}
