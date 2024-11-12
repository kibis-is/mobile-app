import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/providers/storage_provider.dart';

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale?>((ref) {
  final storageService = ref.watch(storageProvider);
  return LocaleNotifier(
    storageService,
    initialLocale: Locale(storageService.getPreferredLanguage() ?? 'en'),
  );
});

class LocaleNotifier extends StateNotifier<Locale?> {
  final StorageService _storageService;

  LocaleNotifier(this._storageService, {Locale? initialLocale})
      : super(initialLocale);

  void setLocale(Locale locale) {
    state = locale;
    _storageService.setPreferredLanguage(locale.languageCode);
  }

  void resetLocale() {
    state = const Locale('en');
    _storageService.setPreferredLanguage('en');
  }
}
