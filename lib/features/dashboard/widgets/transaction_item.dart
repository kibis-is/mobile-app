import 'package:algorand_dart/algorand_dart.dart';
import 'package:ellipsized_text/ellipsized_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/common_widgets/top_snack_bar.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/features/settings/appearance/providers/dark_mode_provider.dart';
import 'package:kibisis/generated/l10n.dart';
import 'package:kibisis/providers/accounts_list_provider.dart';
import 'package:kibisis/providers/network_provider.dart';
import 'package:kibisis/utils/app_icons.dart';
import 'package:kibisis/utils/number_shortener.dart';
import 'package:kibisis/utils/theme_extensions.dart';

class TransactionItem extends ConsumerWidget {
  final Transaction transaction;
  final TransactionDirection direction;
  final String otherPartyAddress;
  final String? amount;
  final String note;
  final String type;
  final String? assetName;
  final bool isNew;
  final VoidCallback? onPressed;

  const TransactionItem({
    super.key,
    required this.transaction,
    required this.direction,
    required this.otherPartyAddress,
    this.amount,
    required this.note,
    required this.type,
    this.assetName,
    this.isNew = false,
    this.onPressed,
  });

  Widget _getTransactionIcon(
      BuildContext context, bool isDarkMode, String network) {
    return Hero(
      tag: '${transaction.id}',
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: direction == TransactionDirection.outgoing
              ? context.colorScheme.error
              : direction == TransactionDirection.incoming
                  ? context.colorScheme.secondary
                  : context.colorScheme.primary,
        ),
        child: AppIcons.icon(
          icon: direction == TransactionDirection.outgoing
              ? AppIcons.outgoing
              : direction == TransactionDirection.incoming
                  ? AppIcons.incoming
                  : AppIcons.sendToSelf,
          size: AppIcons.xlarge,
          color: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(isDarkModeProvider);
    final network = ref.watch(networkProvider)?.value ?? '';

    final accounts = ref.watch(accountsListProvider).accounts;
    final account = accounts.firstWhere(
      (account) => account['publicKey'] == otherPartyAddress,
      orElse: () => <String, String>{},
    );

    final accountName = account.isNotEmpty ? account['accountName'] : null;
    final displayName = accountName ?? otherPartyAddress;

    final shortenedAmount =
        NumberFormatter.shortenNumber(double.parse(amount ?? '0'));

    final shortenedAmountWithDirection =
        NumberFormatter.applyDirectionSign(shortenedAmount, direction);

    return Column(
      children: [
        Material(
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: isNew
                      ? Color.alphaBlend(
                          context.colorScheme.primary.withOpacity(0.2),
                          context.colorScheme.background)
                      : context.colorScheme.background,
                  border: Border.symmetric(
                    horizontal: BorderSide(
                      width: 1,
                      color: context.colorScheme.surface,
                    ),
                  ),
                ),
                child: ListTile(
                  onTap: onPressed,
                  onLongPress: () {
                    Clipboard.setData(
                      ClipboardData(text: transaction.id ?? 'No ID'),
                    );
                    showCustomSnackBar(
                      context: context,
                      snackType: SnackType.neutral,
                      message: S.of(context).transactionIdCopied,
                    );
                  },
                  leading: _getTransactionIcon(context, isDarkMode, network),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      EllipsizedText(
                        type == 'pay'
                            ? S.of(context).payment
                            : assetName ?? S.of(context).assetTransfer,
                        ellipsis: '...',
                        style: context.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      EllipsizedText(
                        displayName,
                        ellipsis: '...',
                        type: EllipsisType.middle,
                        style: context.textTheme.bodyMedium,
                      ),
                      if (note.isNotEmpty)
                        EllipsizedText(
                          note,
                          ellipsis: '...',
                          type: EllipsisType.end,
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colorScheme.secondary,
                          ),
                        ),
                    ],
                  ),
                  trailing: Padding(
                    padding: const EdgeInsets.only(right: kScreenPadding / 2),
                    child: Text(
                      shortenedAmountWithDirection,
                      style: context.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color:
                            (amount == null || amount == '0' || type == 'appl')
                                ? context.colorScheme.onSurface
                                : direction == TransactionDirection.outgoing
                                    ? context.colorScheme.error
                                    : direction == TransactionDirection.incoming
                                        ? context.colorScheme.secondary
                                        : context.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ),
              if (transaction.roundTime != null)
                Positioned(
                  bottom: kScreenPadding / 4,
                  right: kScreenPadding,
                  child: Text(
                    _formatDateTime(transaction.roundTime!),
                    style: Theme.of(context).textTheme.labelSmall,
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
    return '${dateTime.day.toString().padLeft(2, '0')}/'
        '${dateTime.month.toString().padLeft(2, '0')}/'
        '${dateTime.year}, '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}:'
        '${dateTime.second.toString().padLeft(2, '0')}';
  }

  TransactionItem copyWith({
    Transaction? transaction,
    TransactionDirection? direction,
    String? otherPartyAddress,
    String? amount,
    String? note,
    String? type,
    String? assetName,
    bool? isNew,
    VoidCallback? onPressed,
  }) {
    return TransactionItem(
      transaction: transaction ?? this.transaction,
      direction: direction ?? this.direction,
      otherPartyAddress: otherPartyAddress ?? this.otherPartyAddress,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      type: type ?? this.type,
      assetName: assetName ?? this.assetName,
      isNew: isNew ?? this.isNew,
      onPressed: onPressed ?? this.onPressed,
    );
  }
}
