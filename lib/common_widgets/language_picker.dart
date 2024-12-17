import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dash_flags/dash_flags.dart';
import 'package:kibisis/common_widgets/custom_bottom_sheet.dart';
import 'package:kibisis/common_widgets/custom_dropdown.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/generated/l10n.dart';
import 'package:kibisis/models/select_item.dart';
import 'package:kibisis/providers/locale_provider.dart';

class LanguagePicker extends ConsumerWidget {
  final bool isCompact;

  const LanguagePicker({super.key, this.isCompact = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    final availableLocales = S.delegate.supportedLocales;
    const flagSize = 24.0;

    List<SelectItem> languageList = availableLocales.map((locale) {
      String languageName = _getLanguageName(locale.languageCode);
      return SelectItem(
        name: languageName,
        icon: ClipOval(
          child: SizedBox(
            width: flagSize,
            height: flagSize,
            child: LanguageFlag(
              language: Language.fromCode(locale.languageCode),
              height: flagSize,
            ),
          ),
        ),
        value: locale.languageCode,
      );
    }).toList();

    final selectedItem = languageList.firstWhere(
      (item) => item.value == currentLocale?.languageCode,
      orElse: () => languageList.first,
    );

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          customBottomSheet(
            context: context,
            items: languageList,
            header: S.of(context).language,
            onPressed: (SelectItem selectedItem) {
              final newLocale = Locale(selectedItem.value);
              ref.read(localeProvider.notifier).setLocale(newLocale);
            },
          );
        },
        child: isCompact
            ? ClipOval(
                child: SizedBox(
                  width: flagSize + 8,
                  height: flagSize + 8,
                  child: LanguageFlag(
                    language: Language.fromCode(selectedItem.value),
                    height: flagSize,
                  ),
                ),
              )
            : AbsorbPointer(
                absorbing: true,
                child: CustomDropDown(
                  label: S.of(context).language,
                  items: languageList,
                  selectedValue: selectedItem,
                  onChanged: null,
                ),
              ),
      ),
    );
  }

  String _getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'es':
        return 'Español';
      case 'th':
        return 'ไทย';
      case 'tr':
        return 'Türkçe';
      case 'vi':
        return 'Tiếng Việt';
      default:
        return languageCode;
    }
  }
}
