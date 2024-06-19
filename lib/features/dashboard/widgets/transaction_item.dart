import 'package:algorand_dart/algorand_dart.dart';
import 'package:ellipsized_text/ellipsized_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/common_widgets/top_snack_bar.dart';

import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/utils/theme_extensions.dart';

class TransactionItem extends ConsumerWidget {
  final Transaction transaction;
  final bool isOutgoing;
  final String otherPartyAddress;
  final double amountInAlgos;
  final String note;

  const TransactionItem(
      {super.key,
      required this.transaction,
      required this.isOutgoing,
      required this.otherPartyAddress,
      required this.amountInAlgos,
      required this.note});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Material(
          child: ListTile(
            horizontalTitleGap: kScreenPadding * 2,
            onTap: () {
              Clipboard.setData(ClipboardData(text: transaction.id ?? 'No ID'));
              showCustomSnackBar(
                context: context,
                snackType: SnackType.neutral,
                message: 'Transaction ID Copied',
              );
            },
            leading: Container(
              padding: const EdgeInsets.all(kScreenPadding / 2),
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      width: 2.0,
                      color: isOutgoing
                          ? context.colorScheme.error
                          : context.colorScheme.secondary)),
              child: isOutgoing
                  ? Icon(Icons.arrow_upward_rounded,
                      color: isOutgoing
                          ? context.colorScheme.error
                          : context.colorScheme.secondary)
                  : Icon(Icons.arrow_downward_rounded,
                      color: isOutgoing
                          ? context.colorScheme.error
                          : context.colorScheme.secondary),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (transaction.roundTime != null)
                  Text(
                    _formatDateTime(transaction.roundTime!),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                EllipsizedText(
                  type: EllipsisType.middle,
                  ellipsis: '...',
                  otherPartyAddress,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            subtitle: Text(note),
            trailing: Text(
              '${isOutgoing ? '-' : '+'}$amountInAlgos',
              style: context.textTheme.bodyMedium?.copyWith(
                color: isOutgoing
                    ? context.colorScheme.error
                    : context.colorScheme.secondary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatDateTime(int roundTime) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(roundTime * 1000);
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}, ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
  }
}
