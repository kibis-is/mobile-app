import 'package:algorand_dart/algorand_dart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/providers/assets_provider.dart';

final minimumBalanceProvider = Provider<double>((ref) {
  final assetsAsyncValue = ref.watch(assetsProvider);

  return assetsAsyncValue.maybeWhen(
    data: (List<Asset> assets) => 0.1 + (assets.length * 0.1),
    orElse: () =>
        0.1, // Default to the base requirement if not loaded or on error
  );
});
