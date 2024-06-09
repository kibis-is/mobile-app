import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kibisis/common_widgets/custom_button.dart';
import 'package:kibisis/common_widgets/custom_snackbar.dart';
import 'package:kibisis/common_widgets/custom_text_field.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/main.dart';
import 'package:kibisis/providers/temporary_account_provider.dart';

class ImportSeedScreen extends ConsumerStatefulWidget {
  static String title = 'Import Seed';
  final AccountFlow accountFlow;

  const ImportSeedScreen({super.key, required this.accountFlow});

  @override
  ImportSeedScreenState createState() => ImportSeedScreenState();
}

class ImportSeedScreenState extends ConsumerState<ImportSeedScreen> {
  final formKey = GlobalKey<FormState>();
  late List<TextEditingController> seedPhraseControllers;
  late List<FocusNode> focusNodes;

  @override
  void initState() {
    super.initState();
    seedPhraseControllers = List.generate(25, (_) => TextEditingController());
    focusNodes = List.generate(25, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (var controller in seedPhraseControllers) {
      controller.dispose();
    }
    for (var node in focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void pasteSeedPhrase(String seedPhrase) {
    List<String> words = seedPhrase.contains(',')
        ? seedPhrase.split(',')
        : seedPhrase.split(' ');

    for (int i = 0; i < words.length && i < 25; i++) {
      seedPhraseControllers[i].text = words[i].trim();
    }
  }

  @override
  Widget build(BuildContext context) {
    final double itemWidth =
        (MediaQuery.of(context).size.width - 3 * kScreenPadding) / 2;

    return Scaffold(
      appBar: AppBar(
        title: Text(ImportSeedScreen.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              for (var controller in seedPhraseControllers) {
                controller.clear();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.paste),
            onPressed: () async {
              ClipboardData? clipData = await Clipboard.getData('text/plain');
              if (clipData != null) {
                pasteSeedPhrase(clipData.text ?? '');
              }
            },
          ),
        ],
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
                  'Add your seed phrase to import your account.',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: kScreenPadding),
                Wrap(
                  spacing: kScreenPadding,
                  runSpacing: kScreenPadding,
                  children: List.generate(
                    25,
                    (index) => SizedBox(
                      width: itemWidth,
                      child: CustomTextField(
                        controller: seedPhraseControllers[index],
                        focusNode: focusNodes[index],
                        labelText: '${index + 1}',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter word';
                          }
                          return null;
                        },
                        onFieldSubmitted: (value) {
                          if (index < 24) {
                            FocusScope.of(context)
                                .requestFocus(focusNodes[index + 1]);
                          } else {
                            if (formKey.currentState!.validate()) {
                              _importAccount();
                            }
                          }
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: kScreenPadding * 2),
                CustomButton(
                  text: 'Next',
                  isFullWidth: true,
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      await _importAccount();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _importAccount() async {
    final seedPhrase = seedPhraseControllers
        .map((controller) => controller.text.trim())
        .toList();
    try {
      await ref
          .read(temporaryAccountProvider.notifier)
          .restoreAccountFromSeedPhrase(seedPhrase);
      if (!mounted) return;
      GoRouter.of(context).push(widget.accountFlow == AccountFlow.setup
          ? '/setup/setupNameAccount'
          : '/addAccount/addAccountNameAccount');
    } catch (e) {
      rootScaffoldMessengerKey.currentState?.showSnackBar(
        customSnackbar(
          context: context,
          message: e.toString(),
          snackType: SnackType.error,
        ),
      );
    }
  }
}
