import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/models/combined_asset.dart';
import 'package:kibisis/providers/assets_provider.dart';

final minimumBalanceProvider = Provider<double>((ref) {
  final assetsAsyncValue = ref.watch(assetsProvider);

  return assetsAsyncValue.maybeWhen(
    data: (List<CombinedAsset> assets) => 0.1 + (assets.length * 0.1),
    orElse: () => 0.1,
  );
});
