import 'package:ellipsized_text/ellipsized_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/generated/l10n.dart';
import 'package:kibisis/models/contact.dart';
import 'package:kibisis/providers/contacts_provider.dart';
import 'package:kibisis/utils/app_icons.dart';
import 'package:kibisis/utils/theme_extensions.dart';
import 'package:kibisis/common_widgets/confirmation_dialog.dart';

class ContactsDialog extends ConsumerWidget {
  final List<Map<String, String>> accounts;
  final List<Contact> contacts;
  final Function(Map<String, String>) onAccountSelected;
  final Function(Contact) onContactSelected;
  final VoidCallback onCancel;

  const ContactsDialog({
    required this.accounts,
    required this.contacts,
    required this.onAccountSelected,
    required this.onContactSelected,
    required this.onCancel,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: _getTabCount(),
      child: Dialog(
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(
          horizontal: kScreenPadding,
          vertical: kScreenPadding,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kWidgetRadius),
        ),
        backgroundColor: context.colorScheme.background,
        child: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTabBar(context),
                SizedBox(
                  height: 400,
                  child: _buildTabBarView(context, setState, ref),
                ),
                _buildCancelButton(context),
              ],
            );
          },
        ),
      ),
    );
  }

  int _getTabCount() {
    return contacts.isNotEmpty ? 2 : 1;
  }

  Widget _buildTabBar(BuildContext context) {
    return TabBar(
      tabAlignment: TabAlignment.start,
      isScrollable: true,
      indicatorColor: Colors.transparent,
      labelColor: context.colorScheme.primary,
      unselectedLabelColor: context.colorScheme.onBackground,
      tabs: [
        if (contacts.isNotEmpty) Tab(text: S.of(context).contactsTab),
        Tab(text: S.of(context).myAccountsTab),
      ],
    );
  }

  Widget _buildTabBarView(
    BuildContext context,
    StateSetter setState,
    WidgetRef ref,
  ) {
    return TabBarView(
      children: [
        if (contacts.isNotEmpty) _buildContactList(context, setState, ref),
        _buildAccountList(context),
      ],
    );
  }

  Widget _buildContactList(
    BuildContext context,
    StateSetter setState,
    WidgetRef ref,
  ) {
    return ListView.builder(
      itemCount: contacts.length,
      itemBuilder: (context, index) {
        final contact = contacts[index];
        return ListTile(
          tileColor: Colors.transparent,
          title: EllipsizedText(
            contact.name,
            style: context.textTheme.displayMedium,
          ),
          subtitle: EllipsizedText(
            contact.publicKey,
            type: EllipsisType.middle,
          ),
          leading: CircleAvatar(
            backgroundColor: context.colorScheme.primary,
            child: Text(
              contact.name[0].toUpperCase(),
              style: context.textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          trailing: IconButton(
              icon: AppIcons.icon(
                icon: AppIcons.cross,
                color: context.colorScheme.onBackground,
                size: AppIcons.medium,
              ),
              onPressed: () async {
                final confirm = await _confirmDeleteContact(context, contact);
                if (confirm) {
                  await _deleteContact(ref, contact);
                  await ref.read(contactsListProvider.notifier).loadContacts();

                  if (!context.mounted) return;
                  showDialog(
                    context: context,
                    builder: (context) {
                      return ContactsDialog(
                        accounts: accounts,
                        contacts: ref.read(contactsListProvider).contacts,
                        onAccountSelected: onAccountSelected,
                        onContactSelected: onContactSelected,
                        onCancel: onCancel,
                      );
                    },
                  );
                }
              }),
          onTap: () {
            onContactSelected(contact);
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  Widget _buildAccountList(BuildContext context) {
    return ListView.builder(
      itemCount: accounts.length,
      itemBuilder: (context, index) {
        final account = accounts[index];
        return _buildListTile(
          context,
          title: account['accountName']!,
          subtitle: account['publicKey']!,
          onTap: () => onAccountSelected(account),
        );
      },
    );
  }

  Widget _buildCancelButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: kScreenPadding / 2),
      child: TextButton(
        onPressed: onCancel,
        child: Text(
          S.of(context).cancel,
          style: context.textTheme.displayMedium
              ?.copyWith(color: context.colorScheme.onBackground),
        ),
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      tileColor: Colors.transparent,
      title: EllipsizedText(
        title,
        style: context.textTheme.displayMedium,
      ),
      subtitle: EllipsizedText(
        subtitle,
        type: EllipsisType.middle,
      ),
      leading: CircleAvatar(
        backgroundColor: context.colorScheme.primary,
        child: Text(
          title[0].toUpperCase(),
          style: context.textTheme.titleLarge
              ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      onTap: () {
        onTap();
        Navigator.pop(context);
      },
    );
  }

  Future<void> _deleteContact(WidgetRef ref, Contact contact) async {
    await ref.read(contactsListProvider.notifier).removeContact(contact.id);
    await ref.read(contactsListProvider.notifier).loadContacts();
  }

  Future<bool> _confirmDeleteContact(
      BuildContext context, Contact contact) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return ConfirmationDialog(
          title: S.of(context).deleteContactTitle,
          content: S.of(context).deleteContactMessage(contact.name),
        );
      },
    );

    if (result == true && context.mounted) {
      Navigator.of(context).pop();
    }

    return result ?? false;
  }
}
