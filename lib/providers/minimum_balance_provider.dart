import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/models/combined_asset.dart';
import 'package:kibisis/providers/account_provider.dart';
import 'package:kibisis/providers/assets_provider.dart';

final minimumBalanceProvider = Provider<double>((ref) {
  final publicAddress = ref.watch(accountProvider).account?.publicAddress;

  if (publicAddress == null || publicAddress.isEmpty) {
    return 0.1;
  }

  final assetsAsyncValue = ref.watch(assetsProvider(publicAddress));

  return assetsAsyncValue.maybeWhen(
    data: (List<CombinedAsset> assets) => 0.1 + (assets.length * 0.1),
    orElse: () => 0.1,
  );
});
