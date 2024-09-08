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
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: context.colorScheme.primary,
      ),
      child: Padding(
        padding: const EdgeInsets.all(kScreenPadding / 3),
        child: AppIcons.icon(
            icon: network == 'network-voi'
                ? AppIcons.voiCircleIcon
                : AppIcons.algorandIcon,
            size: AppIcons.xlarge,
            color: context.colorScheme.onPrimary),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(isDarkModeProvider);
    final network = ref.watch(networkProvider)?.value ?? '';
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
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
              Material(
                child: Container(
                  decoration: BoxDecoration(
                    color: context.colorScheme.background,
                    border: Border.symmetric(
                      horizontal: BorderSide(
                          width: 1, color: context.colorScheme.surface),
                    ),
                  ),
                  child: ListTile(
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
                          type == 'pay'
                              ? 'Payment'
                              : assetName ?? 'Asset Transfer',
                          style: context.textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (otherPartyAddress != '')
                          EllipsizedText(
                            type: EllipsisType.middle,
                            ellipsis: '...',
                            otherPartyAddress,
                            style: context.textTheme.bodyMedium,
                          ),
                        if (note != '')
                          EllipsizedText(
                            type: EllipsisType.end,
                            ellipsis: '...',
                            note,
                            style: context.textTheme.bodySmall?.copyWith(
                                color: context.colorScheme.secondary),
                          ),
                      ],
                    ),
                    trailing: Text(
                      type == 'appl'
                          ? '$amount'
                          : (amount != null &&
                                  amount != '0' &&
                                  !(amount?.startsWith('0') ?? false))
                              ? '${isOutgoing ? '-' : '+'}$amount'
                              : '$amount',
                      style: context.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: (amount == null ||
                                amount == '0' ||
                                amount?.startsWith('0') == true ||
                                type == 'appl')
                            ? context.colorScheme.onSurface
                            : isOutgoing
                                ? context.colorScheme.error
                                : context.colorScheme.secondary,
                      ),
                    ),
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
    // Convert seconds since epoch to DateTime object in milliseconds
    final dateTime = DateTime.fromMillisecondsSinceEpoch(roundTime * 1000);

    // Format the DateTime object into a readable string
    return '${dateTime.day.toString().padLeft(2, '0')}/'
        '${dateTime.month.toString().padLeft(2, '0')}/'
        '${dateTime.year}, '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}:'
        '${dateTime.second.toString().padLeft(2, '0')}';
  }
}
