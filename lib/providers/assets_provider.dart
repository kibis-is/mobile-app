import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/features/dashboard/widgets/assets_tab.dart';
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
  bool _showFrozen = false;
  Sorting? _sorting;

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

  void setShowFrozen(bool showFrozen) {
    _showFrozen = showFrozen;
    state = AsyncValue.data(_filteredAssets());
  }

  void sortAssets(Sorting sorting) {
    switch (sorting) {
      case Sorting.assetId:
        _allAssets.sort((a, b) => a.index.compareTo(b.index));
        break;
      case Sorting.name:
        _allAssets.sort((a, b) =>
            a.params.name
                ?.toLowerCase()
                .compareTo(b.params.name!.toLowerCase()) ??
            0);
        break;
    }
    state = AsyncValue.data(_filteredAssets()); // Update state with sorted data
  }

  List<Asset> _filteredAssets() {
    List<Asset> filteredAssets = _allAssets;

    if (_filter.isNotEmpty) {
      filteredAssets = filteredAssets
          .where((asset) =>
              asset.params.name
                  ?.toLowerCase()
                  .contains(_filter.toLowerCase()) ??
              false)
          .toList();
    }

    if (!_showFrozen) {
      filteredAssets = filteredAssets
          .where((asset) => !(asset.params.defaultFrozen ?? false))
          .toList();
    }

    switch (_sorting) {
      case Sorting.assetId:
        filteredAssets.sort((a, b) => a.index.compareTo(b.index));
        break;
      case Sorting.name:
        filteredAssets.sort((a, b) =>
            a.params.name
                ?.toLowerCase()
                .compareTo(b.params.name?.toLowerCase() ?? '') ??
            0);
        break;
      default:
        break;
    }

    return filteredAssets;
  }

  void reset() {
    _filter = '';
    _showFrozen = false;
    _sorting = null;
    state = AsyncValue.data(_filteredAssets());
  }
}
