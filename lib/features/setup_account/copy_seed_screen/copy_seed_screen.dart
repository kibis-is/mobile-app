import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kibisis/common_widgets/custom_button.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/features/setup_account/copy_seed_screen/widgets/custom_seed_chip.dart';
import 'package:kibisis/features/setup_account/name_account/providers/checkbox_provider.dart';
import 'package:kibisis/generated/l10n.dart';
import 'package:kibisis/providers/temporary_account_provider.dart';
import 'package:kibisis/utils/app_icons.dart';
import 'package:kibisis/utils/copy_to_clipboard.dart';
import 'package:kibisis/utils/theme_extensions.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(checkboxProvider.notifier).state = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.current.copySeed),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(kScreenPadding),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  S.of(context).generateSeedPhrase,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: kScreenPadding),
                Text(S.of(context).seedPhraseDescription),
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
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Text(
                              '${S.of(context).error}: ${snapshot.error}');
                        } else if (snapshot.hasData) {
                          return Container(
                            width: double.infinity,
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              alignment: Alignment.centerRight,
                              icon: AppIcons.icon(icon: AppIcons.copy),
                              onPressed: () =>
                                  copyToClipboard(context, snapshot.data!),
                            ),
                          );
                        } else {
                          return Text(S.of(context).noSeedPhraseAvailable);
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
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Text(
                              '${S.of(context).error} : ${snapshot.error}');
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
                          return Text(S.of(context).noSeedPhraseAvailable);
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
                                return S.of(context).backupConfirmationRequired;
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
                                shape: const CircleBorder(),
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
                        S.of(context).backupConfirmationPrompt,
                        style: context.textTheme.bodySmall,
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
                      text: S.of(context).next,
                      isFullWidth: true,
                      buttonType: checkboxValue
                          ? ButtonType.secondary
                          : ButtonType.disabled,
                      onPressed: checkboxValue
                          ? () {
                              if (formKey.currentState?.validate() ?? false) {
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
