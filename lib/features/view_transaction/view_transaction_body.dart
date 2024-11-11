import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:algorand_dart/algorand_dart.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/generated/l10n.dart';
import 'package:kibisis/models/contact.dart';
import 'package:kibisis/models/select_item.dart';
import 'package:kibisis/providers/contacts_provider.dart';
import 'package:kibisis/providers/accounts_list_provider.dart';
import 'package:kibisis/providers/network_provider.dart';
import 'package:kibisis/utils/app_icons.dart';
import 'package:kibisis/utils/number_shortener.dart';
import 'package:kibisis/utils/theme_extensions.dart';
import 'package:kibisis/common_widgets/custom_text_field.dart';
import 'package:kibisis/utils/copy_to_clipboard.dart';
import 'dart:convert';

final fromFieldToggleProvider = StateProvider<bool>((ref) => false);
final toFieldToggleProvider = StateProvider<bool>((ref) => false);

class ViewTransactionBody extends ConsumerStatefulWidget {
  final Transaction transaction;

  const ViewTransactionBody({
    super.key,
    required this.transaction,
  });

  @override
  ViewTransactionBodyState createState() => ViewTransactionBodyState();
}

class ViewTransactionBodyState extends ConsumerState<ViewTransactionBody> {
  String _decodeNote() {
    try {
      return utf8.decode(base64.decode(widget.transaction.note ?? ''));
    } catch (e) {
      debugPrint('Error decoding note: $e');
      return 'Invalid note format';
    }
  }

  String _getDisplayName(String publicKey) {
    final contacts = ref.read(contactsListProvider).contacts;
    final accounts = ref.read(accountsListProvider).accounts;

    final contact = contacts.firstWhere(
      (contact) => contact.publicKey == publicKey,
      orElse: () => Contact(publicKey: publicKey, name: '', id: ''),
    );
    if (contact.name.isNotEmpty) {
      return contact.name;
    }

    final account = accounts.firstWhere(
      (account) => account['publicKey'] == publicKey,
      orElse: () => <String, String>{},
    );
    return account.isNotEmpty ? account['accountName']! : publicKey;
  }

  TransactionDirection _getTransactionDirection(
      String sender, String? receiver) {
    if (receiver == null || receiver.isEmpty || sender == receiver) {
      return TransactionDirection.unknown;
    }
    final accounts = ref.read(accountsListProvider).accounts;
    final isSender = accounts.any((account) => account['publicKey'] == sender);

    return isSender
        ? TransactionDirection.outgoing
        : TransactionDirection.incoming;
  }

  @override
  Widget build(BuildContext context) {
    final sender = widget.transaction.sender;
    final receiver = widget.transaction.paymentTransaction?.receiver;
    final transactionType = widget.transaction.type;
    final note = _decodeNote();
    SelectItem? currentNetwork = ref.watch(networkProvider);

    final senderDisplayName = _getDisplayName(sender);
    final receiverDisplayName = _getDisplayName(receiver ?? '');

    final amountInAlgos =
        Algo.fromMicroAlgos(widget.transaction.paymentTransaction?.amount ?? 0);
    final feeInAlgos = Algo.fromMicroAlgos(widget.transaction.fee);

    final direction = _getTransactionDirection(sender, receiver);
    Color avatarColor = direction == TransactionDirection.outgoing
        ? context.colorScheme.error
        : direction == TransactionDirection.incoming
            ? context.colorScheme.secondary
            : context.colorScheme.primary;

    IconData avatarIcon = direction == TransactionDirection.outgoing
        ? AppIcons.outgoing
        : direction == TransactionDirection.incoming
            ? AppIcons.incoming
            : AppIcons.sendToSelf;

    final title = direction == TransactionDirection.outgoing
        ? S.current.sentTransactionTitle
        : direction == TransactionDirection.incoming
            ? S.current.receivedTransactionTitle
            : S.current.selfTransferTitle;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: kScreenPadding / 2,
          vertical: kScreenPadding,
        ),
        child: Column(
          children: [
            Hero(
              tag: '${widget.transaction.id}-icon',
              child: CircleAvatar(
                radius: 50.0,
                backgroundColor: avatarColor,
                child: AppIcons.icon(
                  size: AppIcons.xxlarge,
                  icon: avatarIcon,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: kScreenPadding),
            Text(
              title,
              textAlign: TextAlign.center,
              style: context.textTheme.displayMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: kScreenPadding / 2),
            Text(
              transactionType,
              style: context.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: kScreenPadding / 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  NumberFormatter.formatWithCommas(amountInAlgos.toString()),
                  style: context.textTheme.displayMedium?.copyWith(
                    color: avatarColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                AppIcons.icon(
                  icon: currentNetwork?.icon,
                  size: AppIcons.medium,
                  color: avatarColor,
                ),
              ],
            ),
            const SizedBox(height: kScreenPadding),
            _buildToggleableField(
                labelText: S.current.fromField,
                displayName: senderDisplayName,
                publicKey: sender,
                toggleProvider: fromFieldToggleProvider,
                icon: AppIcons.outgoing),
            const SizedBox(height: kScreenPadding / 2),
            if (receiver != null && receiver.isNotEmpty)
              _buildToggleableField(
                  labelText: S.current.toField,
                  displayName: receiverDisplayName,
                  publicKey: receiver,
                  toggleProvider: toFieldToggleProvider,
                  icon: AppIcons.incoming),
            const SizedBox(height: kScreenPadding / 2),
            CustomTextField(
              leadingIcon: AppIcons.money,
              controller: TextEditingController(
                text: feeInAlgos.toString(),
              ),
              labelText: S.current.fee,
              isEnabled: false,
            ),
            const SizedBox(height: kScreenPadding / 2),
            CustomTextField(
              leadingIcon: AppIcons.time,
              controller: TextEditingController(
                text: DateTime.fromMillisecondsSinceEpoch(
                        widget.transaction.roundTime! * 1000)
                    .toString(),
              ),
              labelText: S.current.date,
              isEnabled: false,
            ),
            const SizedBox(height: kScreenPadding / 2),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    leadingIcon: AppIcons.info,
                    controller: TextEditingController(
                      text: widget.transaction.id ?? S.of(context).unknown,
                    ),
                    labelText: S.current.transactionId,
                    isEnabled: false,
                  ),
                ),
                IconButton(
                  icon: const Icon(AppIcons.copy),
                  onPressed: () {
                    copyToClipboard(context, widget.transaction.id ?? '');
                  },
                ),
              ],
            ),
            if (note.isNotEmpty) ...[
              const SizedBox(height: kScreenPadding / 2),
              CustomTextField(
                leadingIcon: AppIcons.text,
                controller: TextEditingController(
                  text: note,
                ),
                labelText: S.current.note,
                isEnabled: false,
                maxLines: 7,
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildToggleableField({
    required String labelText,
    required String displayName,
    required String publicKey,
    required StateProvider<bool> toggleProvider,
    required IconData icon,
  }) {
    final isToggled = ref.watch(toggleProvider);
    final hasSavedContact = displayName != publicKey;

    return Row(
      children: [
        Expanded(
          child: CustomTextField(
            leadingIcon: icon,
            controller: TextEditingController(
              text: isToggled ? publicKey : displayName,
            ),
            labelText: labelText,
            isEnabled: false,
          ),
        ),
        if (hasSavedContact)
          IconButton(
            icon: Icon(
              isToggled ? Icons.visibility : Icons.visibility_off,
            ),
            onPressed: () {
              ref.read(toggleProvider.notifier).state = !isToggled;
            },
          ),
        IconButton(
          icon: const Icon(AppIcons.copy),
          onPressed: () {
            copyToClipboard(context, publicKey);
          },
        ),
      ],
    );
  }
}
