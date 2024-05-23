import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kibisis/common_widgets/custom_button.dart';
import 'package:kibisis/common_widgets/custom_text_field.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/providers/account_provider.dart';
import 'package:kibisis/providers/authentication_provider.dart';
import 'package:kibisis/providers/loading_provider.dart';
import 'package:kibisis/providers/setup_complete_provider.dart';
import 'package:kibisis/providers/storage_provider.dart';
import 'package:kibisis/providers/temporary_account_provider.dart';
import 'package:kibisis/providers/active_account_provider.dart';

class NameAccountScreen extends ConsumerStatefulWidget {
  static String title = 'Name Account';
  final bool isSetupFlow;

  const NameAccountScreen({super.key, this.isSetupFlow = true});

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
                              await _handleAccountCreation();
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

  Future<void> _handleAccountCreation() async {
    try {
      ref.read(loadingProvider.notifier).startLoading();

      final accountName = accountNameController.text;

      // Finalize account creation
      await ref
          .read(accountProvider.notifier)
          .finalizeAccountCreation(accountName);

      // Set the newly created account as the active account
      final newAccountId =
          await ref.read(accountProvider.notifier).getAccountId();
      if (newAccountId != null) {
        await ref
            .read(activeAccountProvider.notifier)
            .setActiveAccount(newAccountId);
      }

      // Clear the temporary account state
      ref.read(temporaryAccountProvider.notifier).clear();

      // Ensure the latest state is fetched
      await ref.refresh(storageProvider).accountExists();

      // Set setup complete and authenticate the user
      if (widget.isSetupFlow) {
        ref.read(setupCompleteProvider.notifier).setSetupComplete(true);
        ref.read(isAuthenticatedProvider.notifier).state = true;
      }

      ref.read(loadingProvider.notifier).stopLoading();

      _navigateToHome();
    } catch (e) {
      await ref.read(storageProvider).setError(e.toString());
      ref.read(loadingProvider.notifier).stopLoading();
    }
  }

  void _navigateToHome() {
    if (!mounted) return;
    GoRouter.of(context).go('/');
  }
}
