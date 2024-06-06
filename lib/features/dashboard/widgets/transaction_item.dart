import 'package:algorand_dart/algorand_dart.dart';
import 'package:ellipsized_text/ellipsized_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kibisis/common_widgets/custom_snackbar.dart';

import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/theme/color_palette.dart';
import 'package:kibisis/utils/theme_extensions.dart';

class TransactionItem extends ConsumerWidget {
  final Transaction transaction;
  final bool isOutgoing;
  final String otherPartyAddress;
  final double amountInAlgos;

  const TransactionItem({
    super.key,
    required this.transaction,
    required this.isOutgoing,
    required this.otherPartyAddress,
    required this.amountInAlgos,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Material(
          child: ListTile(
            horizontalTitleGap: kScreenPadding * 2,
            onTap: () {
              Clipboard.setData(ClipboardData(text: transaction.id ?? 'No ID'));
              ScaffoldMessenger.of(context).showSnackBar(
                customSnackbar(
                  context: context,
                  message: 'Transaction ID Copied',
                ),
              );
            },
            leading: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: ColorPalette.voiPurple,
              ),
              child: Padding(
                padding: const EdgeInsets.all(kScreenPadding),
                child: SvgPicture.asset(
                  'assets/images/voi-asset-icon.svg',
                  semanticsLabel: 'VOI Logo',
                  width: kScreenPadding,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcATop,
                  ),
                ),
              ),
            ),
            title: EllipsizedText(
              type: EllipsisType.middle,
              ellipsis: '...',
              otherPartyAddress,
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: transaction.roundTime != null
                ? Text(
                    _formatDateTime(transaction.roundTime!),
                    style: context.textTheme.bodySmall,
                  )
                : null,
            trailing: Text(
              '${isOutgoing ? '-' : '+'}$amountInAlgos',
              style: context.textTheme.bodySmall?.copyWith(
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
