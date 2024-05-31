import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/common_widgets/custom_button.dart';
import 'package:kibisis/providers/network_provider.dart';

class SendVOIScreen extends ConsumerWidget {
  static String title = 'Send Currency';
  const SendVOIScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: Column(
          children: [
            CustomButton(
              isFullWidth: true,
              text: 'Send VOI',
              onPressed: () {},
            )
          ],
        ));
  }
}
