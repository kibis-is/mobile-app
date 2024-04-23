import 'package:flutter/material.dart' hide Orientation;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/features/setup_account/create_pin/logic/pin_validation.dart';
import 'package:kibisis/providers/login_controller_provider.dart';
import 'package:kibisis/providers/states/login_states.dart';
import 'package:kibisis/theme/color_palette.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:pin_input_text_field/pin_input_text_field.dart';

class CreatePinScreen extends ConsumerStatefulWidget {
  static String title = "Login";
  const CreatePinScreen({super.key});

  @override
  ConsumerState<CreatePinScreen> createState() => _CreatePinScreenState();
}

class _CreatePinScreenState extends ConsumerState<CreatePinScreen> {
  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginControllerProvider);
    TextEditingController pinEditingController =
        TextEditingController(text: '');
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
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SvgPicture.asset(kibisisLogo,
                        semanticsLabel: 'Kibisis Logo',
                        height: MediaQuery.of(context).size.height / 5),
                    const SizedBox(height: kSizedBoxSpacing),
                    Text(
                      'Kibisis',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    Text(
                      'v0.0.1',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
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
                        SizedBox(
                          height: kInputHeight,
                          child: PinInputTextField(
                            controller: pinEditingController,
                            pinLength: kPinLength,
                            autoFocus: true,
                            textInputAction: TextInputAction.done,
                            cursor: Cursor(
                              orientation: Orientation.vertical,
                              height: kInputHeight / 2,
                              width: 2,
                              color: Theme.of(context).colorScheme.primary,
                              radius: const Radius.circular(1),
                              enabled: true,
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            decoration: BoxLooseDecoration(
                              gapSpace: kScreenPadding / 2,
                              strokeColorBuilder: PinListenColorBuilder(
                                  Theme.of(context).colorScheme.primary,
                                  Theme.of(context).colorScheme.onBackground),
                              obscureStyle: ObscureStyle(
                                isTextObscure: true,
                              ),
                            ),
                            onChanged: (pin) {
                              pin.length == kPinLength
                                  ? PinValidation.pinValidation(
                                      pin, context, ref)
                                  : null;
                            },
                            onSubmit: (pin) {
                              debugPrint('submit via Input Field:$pin');
                              PinValidation.pinValidation(pin, context, ref);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
