import 'package:flutter/material.dart';
import 'package:flutter_confetti/flutter_confetti.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';

enum SnackType {
  neutral,
  success,
  error,
}

class SnackBarService {
  static CustomSnackBar _buildSnackBar({
    required SnackType snackType,
    required String message,
    required ColorScheme colorScheme,
    required TextStyle textStyle,
  }) {
    switch (snackType) {
      case SnackType.success:
        return CustomSnackBar.success(
          message: message,
          backgroundColor: colorScheme.secondary,
          textStyle: textStyle,
          borderRadius: BorderRadius.circular(kWidgetRadius),
        );
      case SnackType.error:
        return CustomSnackBar.error(
          message: message,
          backgroundColor: colorScheme.error,
          textStyle: textStyle,
          borderRadius: BorderRadius.circular(kWidgetRadius),
        );
      case SnackType.neutral:
      default:
        return CustomSnackBar.info(
          message: message,
          backgroundColor: colorScheme.primary,
          textStyle: textStyle,
          borderRadius: BorderRadius.circular(kWidgetRadius),
        );
    }
  }
}

void showCustomSnackBar({
  required BuildContext context,
  required SnackType snackType,
  required String message,
  bool showConfetti = false,
}) {
  final colorScheme = Theme.of(context).colorScheme;
  final textStyle = Theme.of(context).textTheme.displayMedium!.copyWith(
        color: snackType == SnackType.error
            ? colorScheme.onError
            : snackType == SnackType.success
                ? colorScheme.onSecondary
                : colorScheme.onPrimary,
      );

  final snackBar = SnackBarService._buildSnackBar(
    snackType: snackType,
    message: message,
    colorScheme: colorScheme,
    textStyle: textStyle,
  );

  showTopSnackBar(
    Overlay.of(context),
    snackBar,
  );

  if (showConfetti) {
    Confetti.launch(
      context,
      options: const ConfettiOptions(
        spread: 90,
        particleCount: 72,
        startVelocity: 30,
        gravity: 0.7,
        ticks: 300,
        x: 0.5,
        y: 0.2,
      ),
    );
  }
}
