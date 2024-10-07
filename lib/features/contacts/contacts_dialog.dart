import 'package:ellipsized_text/ellipsized_text.dart';
import 'package:flutter/material.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/models/contact.dart';
import 'package:kibisis/utils/theme_extensions.dart';

class AddressBookDialog extends StatelessWidget {
  final List<Map<String, String>> accounts;
  final List<Contact> contacts;
  final Function(Map<String, String>) onAccountSelected;
  final Function(Contact) onContactSelected;
  final VoidCallback onCancel;

  const AddressBookDialog({
    required this.accounts,
    required this.contacts,
    required this.onAccountSelected,
    required this.onContactSelected,
    required this.onCancel,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTabBar(context),
            SizedBox(
              height: 400,
              child: _buildTabBarView(context),
            ),
            _buildCancelButton(context),
          ],
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
        if (contacts.isNotEmpty) const Tab(text: 'Contacts'),
        const Tab(text: 'My Accounts'),
      ],
    );
  }

  Widget _buildTabBarView(BuildContext context) {
    return TabBarView(
      children: [
        if (contacts.isNotEmpty) _buildContactList(context),
        _buildAccountList(context),
      ],
    );
  }

  Widget _buildContactList(BuildContext context) {
    return ListView.builder(
      itemCount: contacts.length,
      itemBuilder: (context, index) {
        final contact = contacts[index];
        return _buildListTile(
          context,
          title: contact.name,
          subtitle: contact.publicKey,
          onTap: () => onContactSelected(contact),
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
          'Cancel',
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
      onTap: onTap,
    );
  }
}
