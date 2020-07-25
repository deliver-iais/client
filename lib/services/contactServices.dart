import 'package:contacts_service/contacts_service.dart';

class ContactServdices {
  sendMyPhoneContacts() async {
    List<Contact> contacts = await ContactsService.getContacts();




  }
}