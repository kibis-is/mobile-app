import 'package:flutter/material.dart' hide Orientation;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:kibisis/common_widgets/custom_button.dart';
import 'package:kibisis/common_widgets/language_picker.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/features/pin_pad/providers/pin_title_provider.dart';
import 'package:kibisis/generated/l10n.dart';
import 'package:kibisis/providers/platform_info/provider.dart';
import 'package:kibisis/utils/theme_extensions.dart';

class WelcomeScreen extends ConsumerWidget {
  static String title = S.current.welcomeTitle;
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String kibisisLogo = Theme.of(context).brightness == Brightness.dark
        ? 'assets/images/kibisis-logo-dark.svg'
        : 'assets/images/kibisis-logo-light.svg';
    final platformInfo = ref.watch(platformInfoProvider);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(kScreenPadding * 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                LanguagePicker(isCompact: true),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(kibisisLogo,
                    height: MediaQuery.of(context).size.height / 5),
                const SizedBox(height: kSizedBoxSpacing),
                Text(
                  'Kibisis',
                  style: context.textTheme.headlineMedium,
                ),
                Text(
                  'v${platformInfo.version}',
                  style: context.textTheme.bodySmall,
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Column(
                  children: [
                    const SizedBox(
                      height: kSizedBoxSpacing,
                    ),
                    Text(
                      S.of(context).welcomeMessage,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(
                      height: kSizedBoxSpacing,
                    ),
                    CustomButton(
                      text: S.of(context).createPin,
                      isFullWidth: true,
                      onPressed: () {
                        ref.read(pinTitleProvider.notifier).setCreatePinTitle();
                        GoRouter.of(context).push('/setup/pinPadSetup');
                      },
                    )
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
