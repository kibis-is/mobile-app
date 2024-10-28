import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/models/combined_asset.dart';
import 'package:kibisis/providers/algorand_provider.dart';
import 'package:kibisis/utils/arc200_service.dart';
import 'package:kibisis/utils/conver_to_combined_asset.dart';

final searchProvider = StateNotifierProvider.autoDispose<SearchNotifier,
    AsyncValue<List<CombinedAsset>>>((ref) {
  return SearchNotifier(ref);
});

class SearchNotifier extends StateNotifier<AsyncValue<List<CombinedAsset>>> {
  SearchNotifier(this.ref) : super(const AsyncValue.data([]));
  final Ref ref;
  Timer? _debounce;
  void searchAssets(String searchQuery) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        if (searchQuery.length < 2) {
          state = const AsyncValue.data([]);
          return;
        }
        state = const AsyncValue.loading();

        final combinedAssets = await _fetchCombinedAssets(searchQuery);

        state = AsyncValue.data(combinedAssets);
      } on Exception catch (e) {
        debugPrint('Exception: $e');
        state = AsyncValue.error(e, StackTrace.current);
      }
    });
  }

  Future<List<CombinedAsset>> _fetchCombinedAssets(String searchQuery) async {
    final standardAssetsFuture = _fetchStandardAssets(searchQuery);
    final arc200AssetsFuture = _fetchArc200Assets(searchQuery);

    final results =
        await Future.wait([standardAssetsFuture, arc200AssetsFuture]);
    return results.expand((assetList) => assetList).toList();
  }

  Future<List<CombinedAsset>> _fetchStandardAssets(String searchQuery) async {
    final algorandService = ref.read(algorandServiceProvider);
    final algorandResponse =
        await algorandService.searchAssets(searchQuery, 0, 1e15, 100);

    final searchQueryLower = searchQuery.toLowerCase().trim();

    return algorandResponse.assets
        .map(AssetConverter.convertAssetToCombinedWithoutAmount)
        .where((asset) {
      final assetName = asset.params.name?.toLowerCase().trim() ?? '';
      final unitName = asset.params.unitName?.toLowerCase().trim() ?? '';
      final contractId = asset.index.toString().trim();
      return assetName.contains(searchQueryLower) ||
          unitName.contains(searchQueryLower) ||
          contractId.contains(searchQueryLower);
    }).toList();
  }

  Future<List<CombinedAsset>> _fetchArc200Assets(String searchQuery) async {
    final arc200Service = ref.read(arc200ServiceProvider);

    try {
      final arc200Assets =
          await arc200Service.searchArc200AssetsByContractIdOrName(searchQuery);

      return arc200Assets.map((asset) {
        return CombinedAsset(
          index: asset.index,
          params: CombinedAssetParameters(
            name: asset.params.name ?? 'Unknown',
            unitName: asset.params.unitName ?? 'N/A',
            decimals: asset.params.decimals,
            total: asset.params.total,
            defaultFrozen: asset.params.defaultFrozen ?? false,
            creator: '',
          ),
          assetType: AssetType.arc200,
          amount: asset.amount,
          isFrozen: asset.isFrozen,
        );
      }).toList();
    } catch (e) {
      debugPrint('Error fetching ARC-0200 assets: $e');
      return []; // Return an empty list in case of errors
    }
  }
}
