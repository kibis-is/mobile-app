import 'package:flutter/material.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/utils/theme_extensions.dart';

enum SnackType {
  neutral,
  success,
  error,
}

SnackBar customSnackbar({
  required BuildContext context,
  required String message,
  SnackType snackType = SnackType.neutral, // Default to neutral if not provided
}) {
  IconData icon;
  Color color;
  String title = 'Info';

  switch (snackType) {
    case SnackType.success:
      icon = Icons.check;
      color = context.colorScheme.secondary;
      title = 'Success';
      break;
    case SnackType.error:
      icon = Icons.error;
      color = context.colorScheme.error;
      title = 'Error';
      break;
    case SnackType.neutral:
    default:
      icon = Icons.info;
      color = context.colorScheme.primary;
      title = 'Info';
      break;
  }

  return SnackBar(
    backgroundColor: color,
    behavior: SnackBarBehavior.floating,
    dismissDirection: DismissDirection.up,
    margin: EdgeInsets.only(
        bottom: MediaQuery.of(context).size.height - 120,
        left: kScreenPadding / 2,
        right: kScreenPadding / 2),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(kWidgetRadius),
    ),
    duration: const Duration(seconds: 5),
    padding: const EdgeInsets.all(16),
    elevation: kScreenPadding,
    content: InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      },
      child: Row(
        children: [
          Icon(
            icon,
            color: context.colorScheme.onPrimary,
            size: kScreenPadding * 2,
          ),
          const SizedBox(width: kScreenPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: context.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: kScreenPadding / 2),
                Text(
                  message,
                  style: TextStyle(color: context.colorScheme.onPrimary),
                  maxLines: null,
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.close,
              color: context.colorScheme.onPrimary,
              size: kScreenPadding * 2,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ],
      ),
    ),
  );
}
