import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/providers/platform_info/provider.dart';

class AboutScreen extends ConsumerWidget {
  static String title = 'About';
  const AboutScreen({super.key});

  // private methods

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

   // public methods

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const rowPadding = SizedBox(
      height: kScreenPadding,
    );
    final platformInfo = ref.watch(platformInfoProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: kScreenPadding),
        child: Column(
          children: [
            rowPadding,
            _createRow('Version:', 'v${platformInfo.version}'),
            rowPadding,
            _createRow('Build:', platformInfo.build),
            rowPadding,
            _createRow('Build Number:', platformInfo.buildNumber),
          ],
        ),
      ),
    );
  }
}
