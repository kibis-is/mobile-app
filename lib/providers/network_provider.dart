import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/common_widgets/custom_dropdown.dart';
import 'package:kibisis/providers/storage_provider.dart';
import 'package:kibisis/utils/app_icons.dart';

// Network options
final List<SelectItem> networkOptions = [
  SelectItem(
    name: 'VOI',
    value: "network-voi",
    icon: AppIcons.voiIcon,
  ),
  SelectItem(
    name: 'Algorand',
    value: "network-algorand",
    icon: AppIcons.algorandIcon,
  ),
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
