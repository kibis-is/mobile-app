import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/common_widgets/custom_dropdown.dart';
import 'package:kibisis/providers/storage_provider.dart';

// Network options
final List<SelectItem> networkOptions = [
  SelectItem(name: 'VOI', value: 0, icon: 'assets/images/voi-asset-icon.svg'),
  SelectItem(
      name: 'Algorand', value: 1, icon: 'assets/images/algorand-logo.svg'),
];

final networkProvider =
    StateNotifierProvider<NetworkNotifier, SelectItem?>((ref) {
  return NetworkNotifier(ref);
});

class NetworkNotifier extends StateNotifier<SelectItem?> {
  final Ref _ref;

  NetworkNotifier(this._ref) : super(null) {
    _init();
  }

  Future<void> _init() async {
    final storage = _ref.read(storageProvider);
    String? defaultNetworkName = storage.getDefaultNetwork();
    state = _getDefaultNetwork(defaultNetworkName);
  }

  SelectItem _getDefaultNetwork(String? defaultNetworkName) {
    return networkOptions.firstWhere(
      (item) => item.name == defaultNetworkName,
      orElse: () => networkOptions.first,
    );
  }

  void setNetwork(SelectItem network) async {
    final storage = _ref.read(storageProvider);
    state = network;
    await storage.setDefaultNetwork(network.name);
    debugPrint("Changed network to ${network.name}");
  }
}
