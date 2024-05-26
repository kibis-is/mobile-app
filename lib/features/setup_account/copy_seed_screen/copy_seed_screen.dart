import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kibisis/common_widgets/custom_button.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/features/setup_account/copy_seed_screen/widgets/custom_seed_chip.dart';
import 'package:kibisis/features/setup_account/name_account/providers/checkbox_provider.dart';
import 'package:kibisis/providers/temporary_account_provider.dart';
import 'package:kibisis/utils/copy_to_clipboard.dart';

class CopySeedScreen extends ConsumerStatefulWidget {
  final AccountFlow accountFlow;

  const CopySeedScreen({super.key, required this.accountFlow});

  @override
  CopySeedScreenState createState() => CopySeedScreenState();
}

class CopySeedScreenState extends ConsumerState<CopySeedScreen> {
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Reset the checkbox provider state when the screen is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(checkboxProvider.notifier).state = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Copy Seed"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(kScreenPadding),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Generate seed phrase',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: kScreenPadding),
                const Text(
                    'Here is your 25 word mnemonic seed phrase. Make sure you save this in a secure place.'),
                const SizedBox(height: kScreenPadding),
                Consumer(
                  builder: (context, ref, child) {
                    return FutureBuilder<String>(
                      future: ref
                          .read(temporaryAccountProvider.notifier)
                          .getSeedPhraseAsString(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else if (snapshot.hasData) {
                          return Container(
                            width: double.infinity,
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              alignment: Alignment.centerRight,
                              icon: const Icon(Icons.copy),
                              onPressed: () =>
                                  copyToClipboard(context, snapshot.data!),
                            ),
                          );
                        } else {
                          return const Text('No seed phrase available.');
                        }
                      },
                    );
                  },
                ),
                Consumer(
                  builder: (context, ref, child) {
                    return FutureBuilder<List<String>>(
                      future: ref
                          .read(temporaryAccountProvider.notifier)
                          .getSeedPhraseAsList(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else if (snapshot.hasData) {
                          return Wrap(
                            spacing: kScreenPadding / 2,
                            runSpacing: kScreenPadding / 2,
                            children:
                                snapshot.data!.asMap().entries.map((word) {
                              return CustomSeedChip(
                                word: word.value,
                                index: word.key,
                              );
                            }).toList(),
                          );
                        } else {
                          return const Text('No seed phrase available.');
                        }
                      },
                    );
                  },
                ),
                const SizedBox(
                  height: kScreenPadding * 2,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Transform.scale(
                      scale: 1.5,
                      child: Consumer(
                        builder: (context, ref, child) {
                          final checkboxValue = ref.watch(checkboxProvider);
                          return FormField<bool>(
                            initialValue: checkboxValue,
                            validator: (value) {
                              if (value == false) {
                                return 'You must confirm you have made a backup of your seed phrase.';
                              }
                              return null;
                            },
                            builder: (FormFieldState<bool> state) {
                              return Checkbox(
                                value: checkboxValue,
                                onChanged: (bool? value) {
                                  state.didChange(value);
                                  ref.read(checkboxProvider.notifier).state =
                                      value!;
                                },
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(
                      width: kScreenPadding,
                    ),
                    Expanded(
                      child: Text(
                        'Please confirm you have stored a backup of your seed phrase in a secure location.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: kScreenPadding * 2,
                ),
                Consumer(
                  builder: (context, ref, child) {
                    final checkboxValue = ref.watch(checkboxProvider);
                    return CustomButton(
                      text: 'Next',
                      isFullWidth: true,
                      onPressed: checkboxValue
                          ? () {
                              if (formKey.currentState?.validate() ?? false) {
                                ref.read(checkboxProvider.notifier).state =
                                    false;
                                GoRouter.of(context).push(
                                    widget.accountFlow == AccountFlow.setup
                                        ? '/setup/setupNameAccount'
                                        : '/addAccount/addAccountNameAccount');
                              }
                            }
                          : null,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
