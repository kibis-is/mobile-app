import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/common_widgets/custom_button.dart';
import 'package:kibisis/common_widgets/custom_text_field.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/features/setup_account/create_account/providers/checkbox_provider.dart';
import 'package:kibisis/providers/mnemonic_provider.dart';

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
    AsyncValue<List<String>> mnemonic = ref.watch(mnemonicProvider);
    final isChecked = ref.watch(checkboxProvider);
    TextEditingController accountNameController = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create New Account"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(kScreenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
              const SizedBox(
                height: kScreenPadding,
              ),
              mnemonic.when(
                loading: () => const CircularProgressIndicator(),
                error: (e, stack) => Text('Error: $e'),
                data: (List<String> words) => Wrap(
                  spacing: kScreenPadding / 2,
                  runSpacing: kScreenPadding / 2,
                  children: words.asMap().entries.map((entry) {
                    return Container(
                      width: (MediaQuery.of(context).size.width / 2) - 20,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface, //
                        borderRadius: BorderRadius.circular(100.0),
                      ),
                      child: Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          Center(
                            child: Text(
                              entry.value,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: kScreenPadding / 2),
                            child: Text(
                              (entry.key + 1).toString(),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                      color: Theme.of(context).disabledColor),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(
                height: kScreenPadding,
              ),
              CustomButton(
                isSecondary: true,
                text: 'Copy',
                onPressed: () {},
              ),
              const SizedBox(
                height: kScreenPadding * 4,
              ),
              Text(
                'Name your account',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSecondary,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: kScreenPadding,
              ),
              Text(
                  'Give your account a nickname. Don’t worry, you can change this later.',
                  style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(
                height: kScreenPadding,
              ),
              CustomTextField(
                controller: accountNameController,
                labelText: 'Account Name',
              ),
              const SizedBox(
                height: kScreenPadding * 4,
              ),
              Text(
                'Confirm',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSecondary,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: kScreenPadding,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Transform.scale(
                    scale: 1.5,
                    child: Checkbox(
                      value: isChecked,
                      onChanged: (bool? value) {
                        ref.read(checkboxProvider.notifier).state = value!;
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: kScreenPadding,
                  ),
                  Expanded(
                    child: Text(
                        'Finally, we just need you to confirm you have stored a backup of your seed phrase in a secure location.',
                        style: Theme.of(context).textTheme.bodySmall),
                  ),
                ],
              ),
              const SizedBox(
                height: kScreenPadding * 4,
              ),
              CustomButton(
                text: 'Create',
                onPressed: () {},
              ),
              const SizedBox(
                height: kScreenPadding,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
