import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/models/network.dart';

final networkProvider = Provider<NetworkNotifier>((ref) {
  return NetworkNotifier();
});

class NetworkNotifier extends StateNotifier<List<Network>> {
  NetworkNotifier() : super([]);

  List<Network> getNetworks() {
    List<Network> networks = [
      Network(name: 'VOI', icon: 'assets/images/algorand-logo.svg'),
      Network(name: 'Algorand', icon: 'assets/images/algorand-logo.svg'),
    ];
    return networks;
  }
}
