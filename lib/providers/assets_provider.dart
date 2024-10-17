import 'package:algorand_dart/algorand_dart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/features/dashboard/widgets/assets_tab.dart';
import 'package:kibisis/providers/algorand_provider.dart';
import 'package:kibisis/providers/network_provider.dart';
import 'package:kibisis/utils/arc200_service.dart';
import '../models/combined_asset.dart';

final assetsProvider = StateNotifierProvider.family<AssetsNotifier,
    AsyncValue<List<CombinedAsset>>, String>(
  (ref, publicAddress) => AssetsNotifier(ref, publicAddress),
);

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

  String get filterText => _filter;

  Future<void> fetchAssets() async {
    if (publicAddress.isEmpty) {
      debugPrint('publicAddress is empty');
      state = const AsyncValue.data([]);
      return;
    }
    try {
      final algorandService = ref.read(algorandServiceProvider);
      final network = ref.read(networkProvider);
      final standardAssets =
          await algorandService.getAccountAssets(publicAddress);
      List<CombinedAsset> standardCombinedAssets = standardAssets
          .map((asset) => CombinedAsset(
                index: asset.index,
                params: asset.params,
                createdAtRound: asset.createdAtRound,
                deleted: asset.deleted,
                destroyedAtRound: asset.destroyedAtRound,
                assetType: AssetType.standard,
                amount: asset.amount,
                isFrozen: asset.isFrozen,
              ))
          .toList();
      _allAssets = standardCombinedAssets;

      if (network?.value.startsWith('network-voi') ?? false) {
        final arc200Service = Arc200Service(ref);
        final arc200Assets =
            await arc200Service.fetchArc200Assets(publicAddress);
        _allAssets = [...standardCombinedAssets, ...arc200Assets];
      }

      state = AsyncValue.data(_filteredAssets());
    } on AlgorandException catch (algEx) {
      debugPrint(
          'AlgorandException occurred while fetching assets: ${algEx.message}');
      state = AsyncValue.error('Failed to fetch assets', StackTrace.current);
    } catch (e, stack) {
      debugPrint('Exception occurred while fetching assets: $e');
      state = AsyncValue.error(e, stack);
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
