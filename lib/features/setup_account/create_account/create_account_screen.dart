import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/common_widgets/custom_button.dart';
import 'package:kibisis/constants/constants.dart';

class CreateAccountScreen extends ConsumerStatefulWidget {
  static String title = "Create Account";
  const CreateAccountScreen({super.key});

  @override
  ConsumerState<CreateAccountScreen> createState() =>
      _CreateAccountScreenState();
}

class _CreateAccountScreenState extends ConsumerState<CreateAccountScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create New Account"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(kScreenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Generate seed phrase',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSecondary,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: kScreenPadding,
            ),
            Text(
                'Here is your 25 word mnemonic seed phrase. Make sure you save this in a secure place.',
                style: Theme.of(context).textTheme.bodySmall),
            CustomButton(
              text: 'Copy',
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
