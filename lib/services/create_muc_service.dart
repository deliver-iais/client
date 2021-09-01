import 'package:we/box/contact.dart';
import 'package:rxdart/rxdart.dart';

class CreateMucService {
  BehaviorSubject<int> _membersLength = BehaviorSubject.seeded(0);
  List<Contact> contacts = [];

  void reset() {
    contacts = [];
    _membersLength.add(contacts.length);
  }

  void addContact(Contact contact) {
    contacts.add(contact);
    _membersLength.add(contacts.length);
  }

  void deleteContact(Contact contact) {
    contacts.removeWhere((c) =>
        c.nationalNumber == contact.nationalNumber &&
        c.countryCode == contact.countryCode);
    _membersLength.add(contacts.length);
  }

  Stream<int> selectedLengthStream() => _membersLength.stream;

  bool isSelected(Contact contact) => contacts.any((c) =>
      c.nationalNumber == contact.nationalNumber &&
      c.countryCode == contact.countryCode);
}
