import 'package:flutter/material.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/utils/theme_extensions.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String content;
  final String yesText;
  final String noText;
  final String okText;
  final bool isConfirmDialog;

  const ConfirmationDialog({
    super.key,
    this.title = 'Are you sure?',
    this.content = 'Do you want to proceed with this action?',
    this.yesText = 'Yes',
    this.noText = 'No',
    this.okText = 'OK',
    this.isConfirmDialog = true,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.all(kScreenPadding),
      title: Text(
        title,
        style: context.textTheme.titleMedium,
      ),
      content: Text(content, style: context.textTheme.bodySmall),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: isConfirmDialog
          ? _buildConfirmActions(context)
          : _buildOkAction(context),
    );
  }

  List<Widget> _buildConfirmActions(BuildContext context) {
    return [
      Expanded(
        child: TextButton(
          onPressed: () {
            Navigator.of(context).pop(true);
          },
          child: Text(
            yesText,
            style: context.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      Expanded(
        child: TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          child: Text(
            noText,
            style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: context.colorScheme.secondary),
          ),
        ),
      ),
    ];
  }

  List<Widget> _buildOkAction(BuildContext context) {
    return [
      TextButton(
        onPressed: () {
          Navigator.of(context).pop(true);
        },
        child: Text(
          okText, // Use the okText parameter
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ];
  }
}
