import 'package:flutter/material.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/utils/theme_extensions.dart';

enum SnackType {
  neutral,
  success,
  error,
}

class TopSnackBar extends StatelessWidget {
  final SnackBar snackBar;

  const TopSnackBar({super.key, required this.snackBar});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      margin: EdgeInsets.only(
        bottom: MediaQuery.of(context).size.height - kScreenPadding,
      ),
      child: snackBar,
    );
  }
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

void showCustomSnackbar({
  required BuildContext context,
  required String message,
  SnackType snackType = SnackType.neutral,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    customSnackbar(
      context: context,
      message: message,
      snackType: snackType,
    ),
  );
}

void showTopSnackBar(BuildContext context, SnackBar snackBar) {
  OverlayEntry overlayEntry = OverlayEntry(
    builder: (context) => TopSnackBar(snackBar: snackBar),
  );

  Overlay.of(context).insert(overlayEntry);

  Future.delayed(snackBar.duration + const Duration(milliseconds: 500), () {
    overlayEntry.remove();
  });
}
