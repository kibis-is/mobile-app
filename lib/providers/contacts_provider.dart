import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/generated/l10n.dart';
import 'package:kibisis/models/contact.dart';
import 'package:kibisis/providers/storage_provider.dart';
import 'package:kibisis/utils/first_or_where_null.dart';

final contactsListProvider =
    StateNotifierProvider<ContactsListNotifier, ContactsListState>((ref) {
  return ContactsListNotifier(ref);
});

class ContactsListState {
  final List<Contact> contacts;
  final bool isLoading;
  final String? error;

  ContactsListState({
    required this.contacts,
    required this.isLoading,
    this.error,
  });

  ContactsListState copyWith({
    List<Contact>? contacts,
    bool? isLoading,
    String? error,
  }) {
    return ContactsListState(
      contacts: contacts ?? this.contacts,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class ContactsListNotifier extends StateNotifier<ContactsListState> {
  final Ref ref;

  ContactsListNotifier(this.ref)
      : super(ContactsListState(contacts: [], isLoading: true)) {
    loadContacts();
  }

  Future<void> loadContacts() async {
    try {
      final storageService = ref.read(storageProvider);
      final contacts = await storageService.getContacts();

      debugPrint('loadContacts() length: ${contacts.length}');

      state = state.copyWith(contacts: contacts, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<Contact?> getContactByPublicKey(String publicKey) async {
    final contacts = await ref.read(storageProvider).getContacts();
    return contacts
        .firstWhereOrNull((contact) => contact.publicKey == publicKey);
  }

  Future<void> removeContact(String contactId) async {
    final storageService = ref.read(storageProvider);
    final contacts = await storageService.getContacts();

    contacts.removeWhere((contact) => contact.id == contactId);
    await storageService.saveContacts(contacts);

    await loadContacts();
  }

  Future<void> updateContact(Contact updatedContact) async {
    final storageService = ref.read(storageProvider);
    final contacts = await storageService.getContacts();

    final index =
        contacts.indexWhere((contact) => contact.id == updatedContact.id);
    if (index != -1) {
      contacts[index] = updatedContact;
    } else {
      throw Exception(S.current.contactNotFound);
    }

    await storageService.saveContacts(contacts);
    state = state.copyWith(contacts: contacts);
  }

  Future<void> clearAllContacts() async {
    final storageService = ref.read(storageProvider);
    await storageService.saveContacts([]);

    state = state.copyWith(contacts: []);
  }

  Future<void> addOrUpdateContact(Contact contact) async {
    final storageService = ref.read(storageProvider);
    final contacts = await storageService.getContacts();
    final index = contacts.indexWhere((c) => c.publicKey == contact.publicKey);

    if (index != -1) {
      contacts[index] = contact;
    } else {
      contacts.add(contact);
    }
    await storageService.saveContacts(contacts);
    state = state.copyWith(contacts: contacts);
  }
}
