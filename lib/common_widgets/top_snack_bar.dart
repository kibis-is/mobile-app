import 'package:flutter/material.dart';
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
        );
      case SnackType.error:
        return CustomSnackBar.error(
          message: message,
          backgroundColor: colorScheme.error,
          textStyle: textStyle,
        );
      case SnackType.neutral:
      default:
        return CustomSnackBar.info(
          message: message,
          backgroundColor: colorScheme.primary,
          textStyle: textStyle,
        );
    }
  }
}

void showCustomSnackBar({
  required BuildContext context,
  required SnackType snackType,
  required String message,
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
}
