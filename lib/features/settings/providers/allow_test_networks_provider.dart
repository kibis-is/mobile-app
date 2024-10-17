import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/providers/storage_provider.dart';

final allowTestNetworksProvider =
    StateNotifierProvider<AllowTestNetworksNotifier, bool>((ref) {
  return AllowTestNetworksNotifier(ref);
});

class AllowTestNetworksNotifier extends StateNotifier<bool> {
  Ref ref;

  AllowTestNetworksNotifier(this.ref) : super(false) {
    _initialize();
  }

  Future<void> _initialize() async {
    final storageService = ref.read(storageProvider);
    final showTestNetworks = storageService.getShowTestNetworks();
    state = showTestNetworks;
  }

  void toggleTestNetworks(bool newValue) {
    state = newValue;
    ref.read(storageProvider).setShowTestNetworks(newValue);
  }
}
