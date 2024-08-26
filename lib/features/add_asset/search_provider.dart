import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/models/combined_asset.dart';
import 'package:kibisis/providers/algorand_provider.dart';
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
    const double minCurrency = 0;
    const double maxCurrency = 1e15; // Use a high but reasonable value
    const int limit = 5;

    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        if (searchQuery.length < 2) {
          state =
              const AsyncValue.data([]); // Clear results if query is too short
          return;
        }
        state = const AsyncValue.loading();
        final response = await ref.read(algorandServiceProvider).searchAssets(
              searchQuery,
              minCurrency,
              maxCurrency,
              limit,
            );

        final combinedAssets =
            response.assets.map(convertToCombinedAsset).toList();
        state = AsyncValue.data(combinedAssets);
      } on Exception catch (e) {
        debugPrint('Exception: $e');
        state = AsyncValue.error(e, StackTrace.current);
      }
    });
  }
}
