import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/providers/storage_provider.dart';

final showFrozenAssetsProvider =
    StateNotifierProvider<ShowFrozenAssetsProvider, bool>((ref) {
  return ShowFrozenAssetsProvider(ref);
});

class ShowFrozenAssetsProvider extends StateNotifier<bool> {
  final Ref ref;
  ShowFrozenAssetsProvider(this.ref) : super(false) {
    loadInitialState();
  }

  Future<void> loadInitialState() async {
    final storageService = ref.read(storageProvider);
    final savedState = storageService.getShowFrozenAssets();
    state = savedState ?? false;
  }

  void setShowFrozenAssets(bool showFrozenAssets) {
    state = showFrozenAssets;
    final storageService = ref.read(storageProvider);
    storageService.setShowFrozenAssets(showFrozenAssets);
  }

  void reset() {
    state = false;
  }
}
