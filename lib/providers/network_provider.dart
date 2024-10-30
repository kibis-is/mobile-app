import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/features/settings/providers/allow_test_networks_provider.dart';
import 'package:kibisis/models/select_item.dart';
import 'package:kibisis/providers/storage_provider.dart';
import 'package:kibisis/utils/app_icons.dart';

final List<SelectItem> networkOptions = [
  SelectItem(
    name: 'VOI',
    value: "network-voi-mainnet",
    icon: AppIcons.voiIcon,
  ),
  SelectItem(
    name: 'VOI TestNet',
    value: "network-voi-testnet",
    icon: AppIcons.voiIcon,
  ),
  SelectItem(
    name: 'Algorand',
    value: "network-algorand-mainnet",
    icon: AppIcons.algorandIcon,
  ),
  SelectItem(
    name: 'Algorand TestNet',
    value: "network-algorand-testnet",
    icon: AppIcons.algorandIcon,
  ),
];

final networkOptionsProvider = Provider<List<SelectItem>>((ref) {
  bool includeTestNetworks = ref.watch(allowTestNetworksProvider);
  return networkOptions.where((network) {
    return includeTestNetworks || !network.value.contains('testnet');
  }).toList();
});

void Function(String)? globalNetworkChangeHandler;

final networkProvider =
    StateNotifierProvider<NetworkNotifier, SelectItem?>((ref) {
  return NetworkNotifier(ref, (message) {
    if (globalNetworkChangeHandler != null) {
      globalNetworkChangeHandler!(message);
    }
  });
});

class NetworkNotifier extends StateNotifier<SelectItem?> {
  final Ref _ref;
  final Function(String) onNetworkChanged;

  NetworkNotifier(this._ref, this.onNetworkChanged) : super(null) {
    _init();
    _ref.listen<bool>(
        allowTestNetworksProvider, (_, __) => ensureValidNetwork());
  }

  Future<void> _init() async {
    final storage = _ref.read(storageProvider);
    String? defaultNetworkValue = storage.getDefaultNetwork();
    state = _getDefaultNetwork(defaultNetworkValue);
  }

  void ensureValidNetwork() {
    bool includeTestNetworks = _ref.read(allowTestNetworksProvider);
    if (!includeTestNetworks &&
        state != null &&
        state!.value.contains('testnet')) {
      String newNetworkValue = state!.value.replaceAll('testnet', 'mainnet');
      SelectItem newNetwork = _getDefaultNetwork(newNetworkValue);
      setNetwork(newNetwork);
    }
  }

  SelectItem _getDefaultNetwork(String? networkValue) {
    List<SelectItem> options = _ref.read(networkOptionsProvider);
    return options.firstWhere(
      (item) => item.value == networkValue,
      orElse: () => options.first,
    );
  }

  Future<bool> setNetwork(SelectItem network) async {
    try {
      final storage = _ref.read(storageProvider);
      if (state != network) {
        state = network;
        await storage.setDefaultNetwork(network.value);
        onNetworkChanged('Network changed to ${network.name}');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Failed to set network: $e');
      return false;
    }
  }
}
