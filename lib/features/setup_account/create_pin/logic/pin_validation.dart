import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kibisis/constants/constants.dart';

class PinValidation {
  static void pinValidation(String pin, BuildContext context, ref) {
    if (pin.length == kPinLength) {
      debugPrint('pin ok');
      //ref.read(loginControllerProvider.notifier).login(pin);

      GoRouter.of(context).go('/setup/addAccount');
    } else {
      debugPrint('invalid pin');
    }
  }
}
