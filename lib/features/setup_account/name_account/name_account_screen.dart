import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/common_widgets/custom_button.dart';
import 'package:kibisis/common_widgets/custom_text_field.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/providers/account_provider.dart';
import 'package:kibisis/providers/authentication_provider.dart';
import 'package:kibisis/providers/loading_provider.dart';
import 'package:kibisis/providers/pin_provider.dart';
import 'package:kibisis/providers/setup_complete_provider.dart';
import 'package:kibisis/utils/storage_service.dart';

class NameAccountScreen extends ConsumerStatefulWidget {
  static String title = 'Name Account';
  const NameAccountScreen({super.key});

  @override
  NameAccountScreenState createState() => NameAccountScreenState();
}

class NameAccountScreenState extends ConsumerState<NameAccountScreen> {
  final formKey = GlobalKey<FormState>();
  late TextEditingController accountNameController;

  @override
  void initState() {
    super.initState();
    accountNameController = TextEditingController();
  }

  @override
  void dispose() {
    accountNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(NameAccountScreen.title),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.all(kScreenPadding),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: kScreenPadding),
                        Text(
                          'Name your account',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color:
                                    Theme.of(context).colorScheme.onSecondary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: kScreenPadding),
                        Text(
                          'Give your account a nickname. Don’t worry, you can change this later.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: kScreenPadding),
                        CustomTextField(
                          controller: accountNameController,
                          labelText: 'Account Name',
                          onChanged: (value) {},
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter some text';
                            }
                            return null;
                          },
                        ),
                        const Spacer(),
                        CustomButton(
                          text: 'Create',
                          isFullWidth: true,
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              try {
                                ref
                                    .read(loadingProvider.notifier)
                                    .startLoading();

                                final seedPhraseAsString = await ref
                                    .read(accountProvider.notifier)
                                    .getSeedPhraseAsString();
                                if (seedPhraseAsString.isNotEmpty) {
                                  await ref
                                      .read(storageProvider)
                                      .setSeedPhrase(seedPhraseAsString);
                                } else {
                                  throw Exception('Seed phrase is empty');
                                }

                                final privateKey = await ref
                                    .read(accountProvider.notifier)
                                    .getPrivateKey();
                                if (privateKey.isNotEmpty) {
                                  await ref
                                      .read(storageProvider)
                                      .setPrivateKey(privateKey);
                                } else {
                                  throw Exception('Private key is empty');
                                }

                                await ref
                                    .read(accountProvider.notifier)
                                    .setAccountName(accountNameController.text);

                                final accountState = ref.read(accountProvider);
                                if (accountState.accountName != null) {
                                  await ref
                                      .read(storageProvider)
                                      .setAccountName(
                                          accountState.accountName!);
                                } else {
                                  throw Exception('Account name is null');
                                }

                                final pin = await ref
                                    .read(storageProvider)
                                    .getPinHash();
                                await ref
                                    .read(storageProvider)
                                    .setPinHash(pin ?? '');

                                await ref.read(storageProvider).setBalance('0');
                                await ref.read(storageProvider).setError('');
                                ref.read(pinProvider.notifier).clearPinState();

                                // Ensure the latest state is fetched
                                await ref
                                    .refresh(storageProvider)
                                    .accountExists();

                                ref
                                    .read(setupCompleteProvider.notifier)
                                    .setSetupComplete(true);
                                ref
                                    .read(isAuthenticatedProvider.notifier)
                                    .state = true;
                                // Stop loading and navigate
                                ref
                                    .read(loadingProvider.notifier)
                                    .stopLoading();

                                // Navigate to the next screen or show success message
                              } catch (e) {
                                await ref
                                    .read(storageProvider)
                                    .setError(e.toString());
                              } finally {
                                ref
                                    .read(loadingProvider.notifier)
                                    .stopLoading();
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
