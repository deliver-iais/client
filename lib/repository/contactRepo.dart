import 'dart:wasm';

import 'package:deliver_flutter/repository/servicesDiscoveryRepo.dart';
import 'package:contacts_service/contacts_service.dart' as PhoneContact;
import 'package:deliver_public_protocol/pub/v1/models/contact.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/phone.pb.dart';
import 'package:deliver_public_protocol/pub/v1/profile.pbgrpc.dart';
import 'package:get_it/get_it.dart';
import 'package:grpc/grpc.dart';
import 'package:fixnum/fixnum.dart';

class ContactRepo {
  static var servicesDiscoveryRepo = GetIt.I.get<ServicesDiscoveryRepo>();

  static ClientChannel clientChannel = ClientChannel(
      servicesDiscoveryRepo.contactServies.host,
      port: servicesDiscoveryRepo.contactServies.port,
      options: ChannelOptions(credentials: ChannelCredentials.insecure()));
  var contactServices = ContactServiceClient(clientChannel);

  syncContacts() async {
    List<PhoneContact.Contact> phoneContacts =
        await PhoneContact.ContactsService.getContacts();
    List<Contact> contacts = new List(phoneContacts.length);
    for (PhoneContact.Contact phoneContact in phoneContacts) {
      PhoneNumber phoneNumber = PhoneNumber()
        ..nationalNumber =
            Int64.parseInt(phoneContact.phones.elementAt(0).toString());
      Contact contact = Contact()
        ..lastName = phoneContact.displayName
        ..phoneNumber = phoneNumber;
      contacts.add(contact);
    }

    var sendContacts = SaveContactsReq();
    contacts.forEach((element) {
      sendContacts.contactList.add(element);
    });
    contactServices.saveContacts(sendContacts);
    print("contacts send");
  }


 getContacts () async {
      return contactServices.getContactList(GetContactListReq());
  }
}
