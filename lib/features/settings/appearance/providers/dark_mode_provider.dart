import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/providers/storage_provider.dart';

final isDarkModeStateAdapter = StateProvider<bool>((ref) {
  return ref.watch(isDarkModeProvider);
});

final isDarkModeProvider =
    StateNotifierProvider<IsDarkModeNotifier, bool>((ref) {
  return IsDarkModeNotifier(ref);
});

class IsDarkModeNotifier extends StateNotifier<bool> {
  final Ref ref;
  IsDarkModeNotifier(this.ref) : super(true) {
    loadInitialState();
  }

  void loadInitialState() async {
    final storageService = ref.read(storageProvider);
    state = storageService.getIsDarkMode() ?? true;
  }

  void setIsDarkMode(bool isDarkMode) {
    state = isDarkMode;
    final storageService = ref.read(storageProvider);
    storageService.setIsDarkMode(isDarkMode);
  }
}
