import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/providers/account_provider.dart';
import 'package:kibisis/providers/assets_provider.dart';

final fabVisibilityProvider = Provider<bool>((ref) {
  // Check if assets are loaded
  final assetsState = ref.watch(assetsProvider);
  bool assetsAreLoaded = assetsState is AsyncData;

  // Check if account is ready
  final accountState = ref.watch(accountProvider);
  bool accountIsReady = accountState.account != null;

  // Determine if the FloatingActionButton should be visible
  return assetsAreLoaded && accountIsReady;
});
