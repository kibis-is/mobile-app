import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/utils/theme_extensions.dart';

class SettingsToggle extends ConsumerWidget {
  final String title;
  final StateProvider<bool> provider;
  final String? description;

  const SettingsToggle({
    super.key,
    required this.title,
    required this.provider,
    this.description,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSwitchedOn = ref.watch(provider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
                child: Text(title, style: context.textTheme.displayMedium)),
            Switch(
              value: isSwitchedOn,
              onChanged: (newValue) {
                ref.read(provider.notifier).state = newValue;
              },
            ),
          ],
        ),
        if (description != null) ...[
          const SizedBox(height: kScreenPadding / 2),
          Text(description!, style: context.textTheme.bodySmall),
        ],
      ],
    );
  }
}
