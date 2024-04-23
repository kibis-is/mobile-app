import 'package:shared_preferences/shared_preferences.dart';

class ThemePreferences {
  final String key = "isDarkMode";
  late SharedPreferences prefs;

  void saveTheme(bool isDarkMode) async {
    prefs = await SharedPreferences.getInstance();
    prefs.setBool(key, isDarkMode);
  }

  Future<bool> getTheme() async {
    prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? false;
  }
}
