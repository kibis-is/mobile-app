import 'package:flutter/material.dart' hide Orientation;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kibisis/constants/constants.dart';

class CreatePinScreen extends ConsumerStatefulWidget {
  static String title = "Login";
  const CreatePinScreen({super.key});

  @override
  ConsumerState<CreatePinScreen> createState() => _CreatePinScreenState();
}

class _CreatePinScreenState extends ConsumerState<CreatePinScreen> {
  @override
  Widget build(BuildContext context) {
    String kibisisLogo = Theme.of(context).brightness == Brightness.dark
        ? 'assets/images/kibisis-logo-dark.svg'
        : 'assets/images/kibisis-logo-light.svg';
    return Scaffold(
      body: Padding(
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
                      // PinPad(
                      //     pinEditingController: pinEditingController, ref: ref),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
