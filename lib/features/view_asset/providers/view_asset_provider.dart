import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/models/detailed_asset.dart';
import 'package:kibisis/providers/account_provider.dart';
import 'package:kibisis/providers/active_asset_provider.dart';
import 'package:kibisis/providers/algorand_provider.dart';

final assetDetailsProvider = FutureProvider<DetailedAsset>((ref) async {
  final account = ref.read(accountProvider).account;
  final activeAssetId = ref.read(activeAssetProvider)?.assetId;
  if (account == null ||
      account.publicAddress.isEmpty ||
      activeAssetId == null) {
    throw Exception(
        "Account is not available, public address is not set, or asset ID is not set.");
  }
  return await ref
      .read(algorandServiceProvider)
      .getDetailedAsset(activeAssetId.toString(), account.publicAddress);
});

final publicAddressProvider =
    StateProvider<String>((ref) => 'initial-public-address');

final viewMoreProvider = StateProvider<bool>((ref) => false);
