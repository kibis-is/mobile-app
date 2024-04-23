import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:kibisis/common_widgets/custom_button.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/providers/login_controller_provider.dart';
import 'package:kibisis/providers/states/login_states.dart';
import 'package:kibisis/theme/color_palette.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:pin_input_text_field/pin_input_text_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  static String title = "Login";
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginControllerProvider);
    String kibisisLogo = Theme.of(context).brightness == Brightness.dark
        ? 'assets/images/kibisis-logo-dark.svg'
        : 'assets/images/kibisis-logo-light.svg';
    return Scaffold(
      body: LoadingOverlay(
        isLoading: loginState is LoginStateLoading,
        color: ColorPalette.darkThemeBlack,
        child: Padding(
          padding: const EdgeInsets.all(kScreenPadding * 2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SvgPicture.asset(kibisisLogo,
                  semanticsLabel: 'Kibisis Logo',
                  height: MediaQuery.of(context).size.height / 3),
              const SizedBox(height: kSizedBoxSpacing),
              Text(
                'Kibisis',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Text(
                'v0.0.1',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: kSizedBoxSpacing * 4),
              Text(
                'Welcome. First, let’s create a new pincode to secure this device.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: kSizedBoxSpacing),
              PinInputTextField(
                pinLength: 6,
                autoFocus: true,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: BoxLooseDecoration(
                  gapSpace: kScreenPadding / 2,
                  strokeColorBuilder: PinListenColorBuilder(
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.onBackground),
                  obscureStyle: ObscureStyle(
                    isTextObscure: true,
                  ),
                ),
                onSubmit: (value) {
                  GoRouter.of(context).go('/addAccount');
                  debugPrint('onSubmit');
                },
              ),
              const SizedBox(height: kSizedBoxSpacing * 4),
              CustomButton(
                text: "Next",
                isFullWidth: true,
                onPressed: () {
                  GoRouter.of(context).go('/addAccount');
                  debugPrint('onPressed');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
