import 'package:flutter/material.dart';
import 'package:kibisis/common_widgets/custom_button.dart';

class SendVOIScreen extends StatelessWidget {
  static String title = 'Send VOI';
  const SendVOIScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: Column(
          children: [
            const Text('Dashboard'),
            CustomButton(
              text: 'Send VOI',
              onPressed: () {},
            )
          ],
        ));
  }
}
