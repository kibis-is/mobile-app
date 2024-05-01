import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/common_widgets/custom_button.dart';
import 'package:kibisis/common_widgets/custom_text_field.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/features/setup_account/create_account/providers/checkbox_provider.dart';
import 'package:kibisis/features/setup_account/create_pin/providers/pin_provider.dart';
import 'package:kibisis/providers/account_provider.dart';
import 'package:kibisis/providers/login_controller_provider.dart';
import 'package:kibisis/providers/mnemonic_provider.dart';
import 'package:kibisis/providers/states/login_states.dart';
import 'package:kibisis/theme/color_palette.dart';
import 'package:kibisis/utils/copy_to_clipboard.dart';
import 'package:loading_overlay/loading_overlay.dart';

class CreateAccountScreen extends ConsumerStatefulWidget {
  static String title = "Create Account";
  const CreateAccountScreen({super.key});

  @override
  ConsumerState<CreateAccountScreen> createState() =>
      _CreateAccountScreenState();
}

class _CreateAccountScreenState extends ConsumerState<CreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController accountNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final checkboxValue = ref.watch(checkboxProvider);
    final mnemonicList = ref.watch(mnemonicProvider);
    final loginState = ref.watch(loginControllerProvider);

    return LoadingOverlay(
      isLoading: loginState is LoginStateLoading,
      color: ColorPalette.darkThemeBlack,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Create New Account"),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(kScreenPadding),
            child: Form(
              key: _formKey,
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
                  mnemonicList.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                          child: Wrap(
                            spacing: kScreenPadding / 2,
                            runSpacing: kScreenPadding / 2,
                            children: mnemonicList.asMap().entries.map((word) {
                              return Container(
                                width: (MediaQuery.of(context).size.width / 2) -
                                    20,
                                padding: const EdgeInsets.symmetric(
                                    vertical: kScreenPadding / 4,
                                    horizontal: kScreenPadding / 4),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.surface,
                                  borderRadius: BorderRadius.circular(100.0),
                                ),
                                alignment: Alignment.center,
                                child: Stack(
                                  alignment: Alignment.centerLeft,
                                  children: [
                                    Center(
                                      child: Text(
                                        word.value,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: kScreenPadding / 2),
                                      child: Text(
                                        (word.key + 1).toString(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                                color: Theme.of(context)
                                                    .disabledColor),
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
                    onPressed: () {
                      String mnemonicString = ref
                          .read(mnemonicProvider.notifier)
                          .getConcatenatedMnemonic();
                      copyToClipboard(context, mnemonicString);
                    },
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
                    onChanged: (value) {
                      ref.read(accountProvider.notifier).state = value;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
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
                        child: FormField<bool>(
                          initialValue: checkboxValue,
                          validator: (value) {
                            if (value == false) {
                              return 'You must accept the terms and conditions';
                            }
                            return null;
                          },
                          builder: (FormFieldState<bool> state) {
                            return Checkbox(
                              value: state.value,
                              onChanged: (bool? value) {
                                state.didChange(value);

                                ref.read(checkboxProvider.notifier).state =
                                    value!;
                                state.validate();
                              },
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            );
                          },
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
                    onPressed: checkboxValue
                        ? () {
                            if (_formKey.currentState!.validate()) {
                              ref.read(loginControllerProvider.notifier).login(
                                    ref.read(pinProvider),
                                    ref.read(accountProvider),
                                    ref
                                        .read(mnemonicProvider.notifier)
                                        .getConcatenatedMnemonic(),
                                  );
                            }
                          }
                        : null,
                  ),
                  const SizedBox(
                    height: kScreenPadding,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
