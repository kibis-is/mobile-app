import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kibisis/common_widgets/custom_button.dart';
import 'package:kibisis/common_widgets/custom_text_field.dart';
import 'package:kibisis/common_widgets/top_snack_bar.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/generated/l10n.dart';
import 'package:kibisis/providers/temporary_account_provider.dart';
import 'package:kibisis/utils/app_icons.dart';
import 'package:kibisis/utils/media_query_helper.dart';

class ImportSeedScreen extends ConsumerStatefulWidget {
  static String title = S.current.importSeed;
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
    final mediaQueryHelper = MediaQueryHelper(context);
    final bool isWideScreen = mediaQueryHelper.isWideScreen();
    final int columnCount = isWideScreen ? 3 : 2;

    return Scaffold(
      appBar: AppBar(
        title: Text(ImportSeedScreen.title),
        actions: [
          IconButton(
            icon: AppIcons.icon(icon: AppIcons.refresh),
            onPressed: () {
              for (var controller in seedPhraseControllers) {
                controller.clear();
              }
              formKey.currentState?.reset();
            },
          ),
          IconButton(
            icon: AppIcons.icon(icon: AppIcons.paste),
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
                Text(
                  S.of(context).enterSeedPhrasePrompt,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: kScreenPadding),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final double itemWidth =
                        constraints.maxWidth / columnCount -
                            (kScreenPadding * (columnCount - 1)) / columnCount;

                    return GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columnCount,
                        crossAxisSpacing: kScreenPadding / 2,
                        mainAxisSpacing: kScreenPadding / 2,
                        childAspectRatio: itemWidth / 60,
                      ),
                      itemCount:
                          25 + (columnCount - (25 % columnCount)) % columnCount,
                      itemBuilder: (context, index) {
                        if (index >= 25) {
                          return const SizedBox.shrink();
                        }
                        return SizedBox(
                          width: itemWidth,
                          child: CustomTextField(
                            controller: seedPhraseControllers[index],
                            focusNode: focusNodes[index],
                            labelText: '${index + 1}',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return S.of(context).enterWord(index + 1);
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
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: kScreenPadding * 2),
                CustomButton(
                  text: S.of(context).next,
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
      showCustomSnackBar(
        context: context,
        snackType: SnackType.error,
        message: e.toString(),
      );
    }
  }
}
