import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/features/dashboard/widgets/assets_tab.dart';
import 'package:kibisis/providers/account_provider.dart';
import 'package:kibisis/providers/algorand_provider.dart';
import 'package:kibisis/providers/network_provider.dart';
import 'package:kibisis/utils/arc200_service.dart';
import 'package:kibisis/providers/storage_provider.dart';
import '../models/combined_asset.dart';

final assetsProvider = StateNotifierProvider.family<AssetsNotifier,
    AsyncValue<List<CombinedAsset>>, String>(
  (ref, publicAddress) => AssetsNotifier(ref, publicAddress),
);

class AssetsNotifier extends StateNotifier<AsyncValue<List<CombinedAsset>>> {
  final Ref ref;
  final String publicAddress;
  List<CombinedAsset> _allAssets = [];
  String _filter = '';
  bool _showFrozen = false;
  Sorting? _sorting;
  Timer? _arc200BalanceTimer;
  bool _isFetching = false;

  AssetsNotifier(this.ref, this.publicAddress)
      : super(const AsyncValue.loading()) {
    fetchAssets();
    _startArc200Polling();
  }

  String get filterText => _filter;

  @override
  void dispose() {
    _arc200BalanceTimer?.cancel();
    super.dispose();
  }

  Future<void> fetchAssets() async {
    if (_isFetching) {
      return;
    }

    _isFetching = true;

    if (publicAddress.isEmpty) {
      state = const AsyncValue.data([]);
      _isFetching = false;
      return;
    }

    state = const AsyncValue.loading();

    try {
      final algorandService = ref.read(algorandServiceProvider);
      final network = ref.read(networkProvider);

      // Fetch ASA assets
      final standardAssets =
          await algorandService.getAccountAssets(publicAddress);
      final standardCombinedAssets = standardAssets.map((asset) {
        return CombinedAsset(
          index: asset.index,
          params: asset.params,
          createdAtRound: asset.createdAtRound,
          deleted: asset.deleted,
          destroyedAtRound: asset.destroyedAtRound,
          assetType: AssetType.standard,
          amount: asset.amount,
          isFrozen: asset.isFrozen,
        );
      }).toList();

      _allAssets = standardCombinedAssets;

      if (network?.value.startsWith('network-voi') ?? false) {
        final arc200Service = Arc200Service(ref);
        final activeArc200Assets =
            await arc200Service.fetchArc200Assets(publicAddress);

        final accountId =
            await ref.read(accountProvider.notifier).getAccountId();
        if (accountId != null) {
          final followedArc200Assets = await ref
              .read(storageProvider)
              .getFollowedArc200Assets(accountId);

          final unmatchedFollowedAssets = <CombinedAsset>[];

          for (final asset in followedArc200Assets) {
            if (!activeArc200Assets.any((a) => a.index == asset.contractId)) {
              unmatchedFollowedAssets.add(
                CombinedAsset(
                  index: asset.contractId,
                  params: CombinedAssetParameters(
                    name: asset.name,
                    unitName: asset.symbol,
                    decimals: asset.decimals,
                    creator: '',
                    total: 0,
                  ),
                  assetType: AssetType.arc200,
                  amount: asset.balance.toInt(),
                  isFrozen: false,
                ),
              );
            }
          }

          _allAssets
              .addAll([...activeArc200Assets, ...unmatchedFollowedAssets]);
        }
      }

      state = AsyncValue.data(_filteredAssets());
    } catch (e, stack) {
      debugPrint('Exception in fetchAssets: $e');
      state = AsyncValue.error(e, stack);
    } finally {
      _isFetching = false;
    }
  }

  void _startArc200Polling() {
    _arc200BalanceTimer ??= Timer.periodic(const Duration(seconds: 30), (_) {
      _pollArc200Balances();
    });
  }

  Future<void> _pollArc200Balances() async {
    try {
      final arc200Service = Arc200Service(ref);
      final accountId = await ref.read(accountProvider.notifier).getAccountId();

      if (accountId != null) {
        // Retrieve followed assets from local storage

        // Filter only active ARC200 assets (from indexer, not storage placeholders)
        final activeArc200Assets = _allAssets.where((asset) {
          return asset.assetType == AssetType.arc200 &&
              asset.amount > 0; // Exclude placeholder assets with 0 balance
        }).toList();

        for (final asset in activeArc200Assets) {
          try {
            final balance = await arc200Service.getArc200Balance(
              contractId: asset.index,
              publicAddress: publicAddress,
            );
            _updateAssetInList(asset.index, balance);
          } catch (e) {
            debugPrint(
                'Failed to fetch balance for ARC200 asset ${asset.index}: $e');
          }
        }

        state = AsyncValue.data(_filteredAssets());
      }
    } catch (e) {
      debugPrint('Error during ARC200 polling: $e');
    }
  }

  void _updateAssetInList(int contractId, BigInt balance) {
    final index = _allAssets.indexWhere(
      (a) => a.index == contractId && a.assetType == AssetType.arc200,
    );

    if (index != -1) {
      // Update balance of the existing ARC200 asset
      _allAssets[index] = _allAssets[index].copyWith(amount: balance.toInt());
    } else {
      debugPrint(
          'ARC200 asset $contractId not found in _allAssets during update.');
    }
  }

  void setFilter(String filter) {
    _filter = filter;
    state = AsyncValue.data(_filteredAssets());
  }

  void setShowFrozen(bool showFrozen) {
    _showFrozen = showFrozen;
    state = AsyncValue.data(_filteredAssets());
  }

  void sortAssets(Sorting sorting) {
    _sorting = sorting;

    _allAssets.sort((a, b) {
      if (a.params.defaultFrozen != b.params.defaultFrozen) {
        return a.params.defaultFrozen ?? false ? 1 : -1;
      }

      switch (sorting) {
        case Sorting.assetId:
          return a.index.compareTo(b.index);
        case Sorting.name:
          return (a.params.name ?? '')
              .toLowerCase()
              .compareTo((b.params.name ?? '').toLowerCase());
        default:
          return 0;
      }
    });

    state = AsyncValue.data(_filteredAssets());
  }

  List<CombinedAsset> _filteredAssets() {
    return _allAssets.where((asset) {
      final name = asset.params.name?.toLowerCase() ?? '';
      final matchesFilter =
          _filter.isEmpty || name.contains(_filter.toLowerCase());
      final isNotFrozen = _showFrozen || !(asset.params.defaultFrozen ?? false);
      return matchesFilter && isNotFrozen;
    }).toList()
      ..sort((a, b) {
        final frozenA = a.params.defaultFrozen ?? false;
        final frozenB = b.params.defaultFrozen ?? false;

        if (frozenA != frozenB) {
          return frozenA ? 1 : -1;
        }

        switch (_sorting) {
          case Sorting.assetId:
            return a.index.compareTo(b.index);
          case Sorting.name:
            return (a.params.name ?? '')
                .toLowerCase()
                .compareTo((b.params.name ?? '').toLowerCase());
          default:
            return 0;
        }
      });
  }

  void reset() {
    _filter = '';
    _showFrozen = false;
    _sorting = null;
    state = AsyncValue.data(_filteredAssets());
  }
}
