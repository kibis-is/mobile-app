import 'package:flutter/material.dart';
import 'package:kibisis/common_widgets/custom_button.dart';
import 'package:kibisis/common_widgets/custom_text_field.dart';
import 'package:kibisis/constants/constants.dart';

class AddAsset extends StatelessWidget {
  static String title = 'Add Asset';
  AddAsset({super.key});
  final accountController = TextEditingController(text: '');

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
            Text("Enter an assetID, name, asset, or symbol ID (for ARC-200).",
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: kScreenPadding),
            Expanded(
              child: CustomTextField(
                controller: accountController,
                labelText: 'Account',
              ),
            ),
            CustomButton(text: 'Add', isFullWidth: true, onPressed: () {}),
            const SizedBox(height: kScreenPadding),
          ],
        ),
      ),
    );
  }
}
