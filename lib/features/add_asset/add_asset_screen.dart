import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kibisis/common_widgets/custom_text_field.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/providers/active_asset_provider.dart';
import 'package:kibisis/providers/algorand_provider.dart';
import 'package:kibisis/utils/theme_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:algorand_dart/algorand_dart.dart';

final searchProvider =
    StateNotifierProvider<SearchNotifier, AsyncValue<List<Asset>>>((ref) {
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
        final response = await ref.read(algorandServiceProvider).getAssets(
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

class AddAssetScreen extends ConsumerWidget {
  static String title = 'Add Asset';
  AddAssetScreen({super.key});
  final accountController = TextEditingController(text: '');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(searchProvider);
    final searchNotifier = ref.watch(searchProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: kScreenPadding),
        child: Column(
          children: [
            const SizedBox(height: kScreenPadding),
            Text(
              "Enter an assetID, name, asset, or symbol ID (for ARC-200).",
              style: context.textTheme.bodyMedium,
            ),
            const SizedBox(height: kScreenPadding),
            CustomTextField(
              controller: accountController,
              labelText: 'Search Query',
              onChanged: (value) {
                searchNotifier.searchAssets(value);
              },
            ),
            const SizedBox(height: kScreenPadding),
            Expanded(
              child: searchState.when(
                data: (assets) {
                  if (assets.isEmpty) {
                    return const Center(
                      child: Text('No assets found.'),
                    );
                  }
                  return ListView.builder(
                    itemCount: assets.length,
                    itemBuilder: (context, index) {
                      final asset = assets[index];
                      return ListTile(
                          title: Text(asset.params.name ?? 'No name'),
                          subtitle:
                              Text(asset.params.unitName ?? 'No Unit Name'),
                          onTap: () async {
                            final assetDetails = await ref
                                .read(algorandServiceProvider)
                                .getAssetById(asset.index);
                            ref
                                .read(activeAssetProvider.notifier)
                                .setActiveAsset(assetDetails);
                            if (context.mounted) {
                              GoRouter.of(context).go('/viewAsset/');
                            }
                          });
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, stack) => Center(child: Text('Error: $e')),
              ),
            ),
            const SizedBox(height: kScreenPadding),
          ],
        ),
      ),
    );
  }
}
