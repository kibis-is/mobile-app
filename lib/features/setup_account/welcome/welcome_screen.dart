import 'package:flutter/material.dart' hide Orientation;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:kibisis/common_widgets/custom_button.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/features/pin_pad/providers/pin_title_provider.dart';
import 'package:kibisis/utils/theme_extensions.dart';

class WelcomeScreen extends ConsumerWidget {
  static String title = "Login";
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String kibisisLogo = Theme.of(context).brightness == Brightness.dark
        ? 'assets/images/kibisis-logo-dark.svg'
        : 'assets/images/kibisis-logo-light.svg';
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(kScreenPadding * 2),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(kibisisLogo,
                    semanticsLabel: 'Kibisis Logo',
                    height: MediaQuery.of(context).size.height / 5),
                const SizedBox(height: kSizedBoxSpacing),
                Text(
                  'Kibisis',
                  style: context.textTheme.headlineMedium,
                ),
                Text(
                  kVersionNumber,
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
                      'Welcome. First, let’s create a new pincode to secure this device.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(
                      height: kSizedBoxSpacing,
                    ),
                    CustomButton(
                      text: 'Create Pin',
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
