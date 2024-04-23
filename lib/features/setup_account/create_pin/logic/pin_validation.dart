import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kibisis/constants/constants.dart';

class PinValidation {
  static void pinValidation(String pin, BuildContext context) {
    if (pin.length == kPinLength) {
      debugPrint('pin ok');
      GoRouter.of(context).go('/addAccount');
    } else {
      debugPrint('invalid pin');
    }
  }
}
