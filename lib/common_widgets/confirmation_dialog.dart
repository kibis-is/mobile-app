import 'package:flutter/material.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/generated/l10n.dart'; // Import localization
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
    this.title = '',
    this.content = '',
    this.yesText = '',
    this.noText = '',
    this.okText = '',
    this.isConfirmDialog = true,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.all(kScreenPadding),
      title: Text(
        title.isNotEmpty ? title : S.of(context).defaultConfirmationTitle,
        style: context.textTheme.titleMedium,
        textAlign: TextAlign.center,
      ),
      content: Text(
        content.isNotEmpty ? content : S.of(context).defaultConfirmationContent,
        style: context.textTheme.bodySmall,
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: isConfirmDialog
          ? _buildConfirmActions(context)
          : _buildOkAction(context),
    );
  }

  List<Widget> _buildConfirmActions(BuildContext context) {
    return [
      TextButton(
        onPressed: () {
          Navigator.of(context).pop(true);
        },
        child: Text(
          yesText.isNotEmpty ? yesText : S.of(context).yes,
          style: context.textTheme.bodyMedium?.copyWith(),
        ),
      ),
      TextButton(
        onPressed: () {
          Navigator.of(context).pop(false);
        },
        child: Text(
          noText.isNotEmpty ? noText : S.of(context).no,
          style: context.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: context.colorScheme.secondary),
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
          okText.isNotEmpty ? okText : S.of(context).ok,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ];
  }
}
