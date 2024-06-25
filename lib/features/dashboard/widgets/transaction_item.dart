import 'package:algorand_dart/algorand_dart.dart';
import 'package:ellipsized_text/ellipsized_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/common_widgets/top_snack_bar.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/features/settings/appearance/providers/dark_mode_provider.dart';
import 'package:kibisis/providers/network_provider.dart';
import 'package:kibisis/utils/app_icons.dart';
import 'package:kibisis/utils/theme_extensions.dart';

class TransactionItem extends ConsumerWidget {
  final Transaction transaction;
  final bool isOutgoing;
  final String otherPartyAddress;
  final String? amount;
  final String note;
  final String type;
  final String? assetName;

  const TransactionItem({
    super.key,
    required this.transaction,
    required this.isOutgoing,
    required this.otherPartyAddress,
    this.amount,
    required this.note,
    required this.type,
    this.assetName,
  });

  Widget _getTransactionIcon(
      BuildContext context, bool isDarkMode, String network) {
    dynamic iconData;

    switch (type) {
      case 'pay':
        iconData =
            network == 'network-voi' ? AppIcons.voiIcon : AppIcons.algorandIcon;
        break;
      case 'axfer':
        iconData = AppIcons.asset;
        break;
      default:
        iconData = AppIcons.error;
        break;
    }

    return Container(
      padding: type == 'pay' ? const EdgeInsets.all(kScreenPadding / 4) : null,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          width: 3,
          color: context.colorScheme.primary,
        ),
      ),
      child: AppIcons.icon(
          icon: iconData,
          size: type == 'pay' ? AppIcons.medium : AppIcons.large,
          color: context.colorScheme.primary),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(isDarkModeProvider);
    final network = ref.watch(networkProvider)?.value ?? 'network-voi';
    return Column(
      children: [
        Material(
          child: Stack(
            children: [
              if (transaction.roundTime != null)
                Positioned(
                  bottom: kScreenPadding / 4,
                  right: kScreenPadding,
                  child: Text(
                    _formatDateTime(transaction.roundTime!),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ListTile(
                horizontalTitleGap: kScreenPadding * 2,
                onTap: () {
                  Clipboard.setData(
                      ClipboardData(text: transaction.id ?? 'No ID'));
                  showCustomSnackBar(
                    context: context,
                    snackType: SnackType.neutral,
                    message: 'Transaction ID Copied',
                  );
                },
                leading: _getTransactionIcon(context, isDarkMode, network),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    EllipsizedText(
                      type: EllipsisType.end,
                      ellipsis: '...',
                      type == 'pay' ? 'Payment' : assetName ?? 'Asset Transfer',
                      style: context.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    EllipsizedText(
                      type: EllipsisType.middle,
                      ellipsis: '...',
                      otherPartyAddress,
                      style: context.textTheme.bodyMedium,
                    ),
                    EllipsizedText(
                      type: EllipsisType.end,
                      ellipsis: '...',
                      note,
                      style: context.textTheme.bodySmall,
                    ),
                  ],
                ),
                trailing: Text(
                  '${amount == '0' ? '0.' : (isOutgoing ? '-' : '+')}$amount',
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: amount == '0'
                        ? context.colorScheme.onSurface
                        : isOutgoing
                            ? context.colorScheme.error
                            : context.colorScheme.secondary,
                  ),
                ),
              ),
            ],
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
