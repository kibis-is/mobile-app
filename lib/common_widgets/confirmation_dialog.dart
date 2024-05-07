import 'package:flutter/material.dart';
import 'package:kibisis/constants/constants.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String content;
  final String yesText;
  final String noText;

  const ConfirmationDialog({
    super.key,
    this.title = 'Are you sure?',
    this.content = 'Do you want to proceed with this action?',
    this.yesText = 'Yes',
    this.noText = 'No',
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.all(kScreenPadding),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge,
      ),
      actionsPadding: const EdgeInsets.all(0),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      content: Text(content, style: Theme.of(context).textTheme.bodySmall),
      actions: <Widget>[
        Expanded(
          child: TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: Padding(
              padding: const EdgeInsets.all(kScreenPadding),
              child: Text(
                yesText,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          child: Padding(
            padding: const EdgeInsets.all(kScreenPadding),
            child: Text(
              noText,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.secondary),
            ),
          ),
        ),
      ],
    );
  }
}