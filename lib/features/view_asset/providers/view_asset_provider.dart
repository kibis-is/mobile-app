import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/models/detailed_asset.dart';
import 'package:kibisis/providers/account_provider.dart';
import 'package:kibisis/providers/algorand_provider.dart';

final assetDetailsProvider =
    FutureProvider.family<DetailedAsset, String>((ref, assetId) async {
  final account = ref.read(accountProvider).account;
  if (account == null || account.publicAddress.isEmpty) {
    throw Exception("Account is not available or public address is not set.");
  }
  return await ref
      .read(algorandServiceProvider)
      .getDetailedAsset(assetId, account.publicAddress);
});

final publicAddressProvider =
    StateProvider<String>((ref) => 'initial-public-address');

final viewMoreProvider = StateProvider<bool>((ref) => false);
