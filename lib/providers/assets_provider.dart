import 'package:algorand_dart/algorand_dart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/features/dashboard/widgets/assets_tab.dart';
import 'package:kibisis/providers/account_provider.dart';
import 'package:kibisis/providers/algorand_provider.dart';
import 'package:kibisis/utils/arc200_service.dart';
import '../models/combined_asset.dart';

final assetsProvider =
    StateNotifierProvider<AssetsNotifier, AsyncValue<List<CombinedAsset>>>(
        (ref) {
  final publicAddress = ref.watch(accountProvider).account?.publicAddress;
  if (publicAddress != null) {
    return AssetsNotifier(ref, publicAddress);
  }
  return AssetsNotifier(ref, '');
});

class AssetsNotifier extends StateNotifier<AsyncValue<List<CombinedAsset>>> {
  final Ref ref;
  final String publicAddress;
  List<CombinedAsset> _allAssets = [];
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
      final arc200Service = Arc200Service();
      final arc200Assets = await arc200Service.fetchArc200Assets(publicAddress);
      final standardAssets =
          await algorandService.getAccountAssets(publicAddress);
      final List<CombinedAsset> standardCombinedAssets = [];
      for (var asset in standardAssets) {
        try {
          final combinedAsset = CombinedAsset(
            index: asset.index,
            params: asset.params,
            createdAtRound: asset.createdAtRound,
            deleted: asset.deleted,
            destroyedAtRound: asset.destroyedAtRound,
            assetType: AssetType.standard,
            amount: asset.amount,
            isFrozen: asset.isFrozen,
          );
          standardCombinedAssets.add(combinedAsset);
        } catch (e) {
          debugPrint(
              'Error processing assetId: ${asset.index}, skipping. Error: $e');
          continue;
        }
      }
      _allAssets = standardCombinedAssets;

      _allAssets = [...standardCombinedAssets, ...arc200Assets];

      state = AsyncValue.data(_filteredAssets());
    } on AlgorandException {
      if (mounted) {
        debugPrint('AlgorandException occurred while fetching assets.');
        state = AsyncValue.error('Failed to fetch assets', StackTrace.current);
      }
    } catch (e) {
      if (mounted) {
        debugPrint('Exception occurred: $e');
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
    _sorting = sorting;

    _allAssets.sort((a, b) {
      if (a.params.defaultFrozen != b.params.defaultFrozen) {
        return a.params.defaultFrozen ?? false ? 1 : -1;
      }

      switch (sorting) {
        case Sorting.assetId:
          return a.index.compareTo(b.index);
        case Sorting.name:
          return a.params.name
                  ?.toLowerCase()
                  .compareTo(b.params.name?.toLowerCase() ?? '') ??
              0;
        default:
          return 0;
      }
    });

    state = AsyncValue.data(_filteredAssets());
  }

  List<CombinedAsset> _filteredAssets() {
    List<CombinedAsset> filteredAssets = _allAssets;

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

    filteredAssets.sort((a, b) {
      if (a.params.defaultFrozen != b.params.defaultFrozen) {
        return a.params.defaultFrozen ?? false ? 1 : -1;
      }

      switch (_sorting) {
        case Sorting.assetId:
          return a.index.compareTo(b.index);
        case Sorting.name:
          return a.params.name
                  ?.toLowerCase()
                  .compareTo(b.params.name?.toLowerCase() ?? '') ??
              0;
        default:
          return 0;
      }
    });

    return filteredAssets;
  }

  void reset() {
    _filter = '';
    _showFrozen = false;
    _sorting = null;
    state = AsyncValue.data(_filteredAssets());
  }
}
