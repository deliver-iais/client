import 'package:contacts_service/contacts_service.dart';

class ContactServices {
  sendMyPhoneContacts() async {

    List<Contact> contacts = await ContactsService.getContacts();

  }
}