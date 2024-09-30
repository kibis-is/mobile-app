import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/models/select_item.dart';
import 'package:kibisis/providers/storage_provider.dart';
import 'package:kibisis/utils/app_icons.dart';

final List<SelectItem> networkOptions = [
  SelectItem(
    name: 'VOI',
    value: "network-voi",
    icon: AppIcons.voiIcon,
  ),
  // SelectItem(
  //   name: 'VOI TestNet',
  //   value: "network-voi-testnet",
  //   icon: AppIcons.voiIcon,
  // ),
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
  }
}
