import 'package:flutter/material.dart';
import 'package:kibisis/common_widgets/custom_button.dart';
import 'package:kibisis/common_widgets/custom_text_field.dart';
import 'package:kibisis/constants/constants.dart';

class AddNetwork extends StatelessWidget {
  static String title = 'Add Network';
  AddNetwork({super.key});
  final networkController = TextEditingController(text: '');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: kScreenPadding),
        child: Column(
          children: [
            const SizedBox(height: kScreenPadding),
            Expanded(
              child: CustomTextField(
                controller: networkController,
                labelText: 'Name',
              ),
            ),
            const SizedBox(height: kScreenPadding),
            CustomButton(text: 'Add', isFullWidth: true, onPressed: () {}),
            const SizedBox(height: kScreenPadding),
          ],
        ),
      ),
    );
  }
}
