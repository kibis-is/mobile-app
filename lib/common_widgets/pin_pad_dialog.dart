import 'package:flutter/material.dart';
import 'package:kibisis/common_widgets/pin_pad.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/utils/app_icons.dart';
import 'package:kibisis/utils/theme_extensions.dart';

class PinPadDialog extends StatelessWidget {
  final String title;
  final VoidCallback onPinVerified;

  const PinPadDialog({
    super.key,
    required this.title,
    required this.onPinVerified,
  });

  IconData _getIcon(BuildContext context) {
    switch (Theme.of(context).platform) {
      case TargetPlatform.iOS:
        return AppIcons.arrowBackIOS;
      case TargetPlatform.android:
      default:
        return AppIcons.arrowBackAndroid;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.zero,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width,
          maxHeight: MediaQuery.of(context).size.height,
        ),
        child: Scaffold(
          appBar: AppBar(
            title: Text(title),
            leading: IconButton(
              icon: AppIcons.icon(
                  icon: _getIcon(context),
                  size: AppIcons.medium,
                  color: context.colorScheme.onSurfaceVariant),
              onPressed: () => Navigator.of(context).pop(false),
            ),
          ),
          body: Column(
            children: [
              const SizedBox(height: kScreenPadding),
              Expanded(
                child: PinPad(
                  mode: PinPadMode.verifyTransaction,
                  onPinVerified: () {
                    onPinVerified();
                    Navigator.of(context).pop(true);
                  },
                ),
              ),
              const SizedBox(height: kScreenPadding),
            ],
          ),
        ),
      ),
    );
  }
}
