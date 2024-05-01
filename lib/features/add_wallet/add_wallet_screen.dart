import 'package:flutter/material.dart';
import 'package:kibisis/common_widgets/custom_button.dart';
import 'package:kibisis/common_widgets/custom_text_field.dart';
import 'package:kibisis/constants/constants.dart';

class AddWalletScreen extends StatelessWidget {
  static String title = 'Add Wallet';
  AddWalletScreen({super.key});
  final walletController = TextEditingController(text: '');

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
                controller: walletController,
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
