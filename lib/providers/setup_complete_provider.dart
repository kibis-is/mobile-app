import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final setupCompleteProvider =
    StateNotifierProvider<SetupCompleteNotifier, bool>(
  (ref) => SetupCompleteNotifier(),
);

class SetupCompleteNotifier extends StateNotifier<bool> {
  SetupCompleteNotifier() : super(false) {
    _loadFromPrefs();
  }

  SharedPreferences? _prefs;

  Future<void> _loadFromPrefs() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      final isSetupComplete = _prefs?.getBool('isSetupComplete') ?? false;
      state = isSetupComplete;
    } catch (e) {
      state = false;
    }
  }

  Future<void> setSetupComplete(bool isComplete) async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      await _prefs?.setBool('isSetupComplete', isComplete);
      state = isComplete;
    } catch (e) {
      debugPrint('Error setting setup complete: $e');
    }
  }

  void reset() {
    state = false;
  }
}
