import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:algorand_dart/algorand_dart.dart';
import 'package:kibisis/providers/algorand_provider.dart';

final searchProvider =
    StateNotifierProvider.autoDispose<SearchNotifier, AsyncValue<List<Asset>>>(
        (ref) {
  return SearchNotifier(ref);
});

class SearchNotifier extends StateNotifier<AsyncValue<List<Asset>>> {
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
        state = AsyncValue.data(response.assets);
      } on Exception catch (e) {
        debugPrint('Exception: $e');
        state = AsyncValue.error(e, StackTrace.current);
      }
    });
  }
}
