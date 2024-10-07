import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/contact.dart';
import '../providers/storage_provider.dart';

// Define the provider for contacts management
final contactsListProvider =
    StateNotifierProvider<ContactsListNotifier, ContactsListState>((ref) {
  return ContactsListNotifier(ref);
});

// Define the state class to represent the contacts state
class ContactsListState {
  final List<Contact> contacts;
  final bool isLoading;
  final String? error;

  ContactsListState({
    required this.contacts,
    required this.isLoading,
    this.error,
  });

  // Copy with method for immutability
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

// Define the StateNotifier to handle business logic for managing contacts
class ContactsListNotifier extends StateNotifier<ContactsListState> {
  final Ref ref;

  ContactsListNotifier(this.ref)
      : super(ContactsListState(contacts: [], isLoading: true)) {
    loadContacts();
  }

  // Load all contacts from storage
  Future<void> loadContacts() async {
    try {
      final storageService = ref.read(storageProvider);
      final contacts = await storageService.getContacts();

      state = state.copyWith(contacts: contacts, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  // Add a new contact to the storage and update the state
  Future<void> addContact(Contact contact) async {
    final storageService = ref.read(storageProvider);
    final contacts = await storageService.getContacts();

    // Check for duplicates (name or public key)
    final duplicate = contacts
        .any((c) => c.publicKey == contact.publicKey || c.name == contact.name);
    if (duplicate) {
      throw Exception(
          'A contact with the same name or address already exists.');
    }

    // Add the contact and save the updated list
    contacts.add(contact);
    await storageService.saveContacts(contacts);

    // Update the state with the new list of contacts
    state = state.copyWith(contacts: contacts);
  }

  // Remove a contact by its ID
  Future<void> removeContact(String contactId) async {
    final storageService = ref.read(storageProvider);
    final contacts = await storageService.getContacts();

    // Remove the contact from the list
    contacts.removeWhere((contact) => contact.id == contactId);
    await storageService.saveContacts(contacts);

    // Reload the updated list of contacts
    await loadContacts();
  }

  // Update an existing contact's name
  Future<void> updateContact(String contactId, String newName) async {
    final storageService = ref.read(storageProvider);
    final contacts = await storageService.getContacts();

    // Find the contact and update the name
    final index = contacts.indexWhere((contact) => contact.id == contactId);
    if (index != -1) {
      contacts[index] = Contact(
          id: contactId, name: newName, publicKey: contacts[index].publicKey);
      await storageService.saveContacts(contacts);

      // Update the state with the updated contact list
      state = state.copyWith(contacts: contacts);
    }
  }

  // Clear all contacts
  Future<void> clearAllContacts() async {
    final storageService = ref.read(storageProvider);
    await storageService.saveContacts([]);

    // Update the state to reflect the empty contacts list
    state = state.copyWith(contacts: []);
  }
}
