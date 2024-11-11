import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/generated/l10n.dart'; // Import localization
import 'package:kibisis/providers/platform_info/provider.dart';

class AboutScreen extends ConsumerWidget {
  static String title = S.current.about;

  const AboutScreen({super.key});

  Row _createRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          width: kScreenPadding,
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.normal),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const rowPadding = SizedBox(
      height: kScreenPadding,
    );
    final platformInfo = ref.watch(platformInfoProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).about),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: kScreenPadding),
        child: Column(
          children: [
            rowPadding,
            _createRow(S.of(context).version, 'v${platformInfo.version}'),
            rowPadding,
            _createRow(S.of(context).build, platformInfo.build),
            rowPadding,
            _createRow(S.of(context).buildNumber, platformInfo.buildNumber),
          ],
        ),
      ),
    );
  }
}
