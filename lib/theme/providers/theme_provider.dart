import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/utils/theme_preferences.dart';

final themeProvider =
    StateNotifierProvider<ThemeProvider, bool>((ref) => ThemeProvider());

class ThemeProvider extends StateNotifier<bool> {
  ThemeProvider() : super(false) {
    loadTheme();
  }

  final ThemePreferences themePreferences = ThemePreferences();

  void toggleTheme() {
    state = !state;
    themePreferences.saveTheme(state);
  }

  Future<void> loadTheme() async {
    state = await themePreferences.getTheme();
  }
}
