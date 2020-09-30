import 'package:deliver_flutter/db/dao/ContactDao.dart';
import 'package:deliver_flutter/db/dao/RoomDao.dart';
import 'package:deliver_flutter/db/database.dart' as myContact;
import 'package:deliver_flutter/repository/roomRepo.dart';

import 'package:deliver_flutter/repository/servicesDiscoveryRepo.dart';
import 'package:contacts_service/contacts_service.dart' as OsContact;

import 'package:deliver_public_protocol/pub/v1/models/contact.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/phone.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/user.pb.dart';

import 'package:deliver_public_protocol/pub/v1/profile.pbgrpc.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:grpc/grpc.dart';
import 'package:fixnum/fixnum.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';

import 'accountRepo.dart';
import 'messageRepo.dart';

class ContactRepo {
  static var servicesDiscoveryRepo = GetIt.I.get<ServicesDiscoveryRepo>();

  var accountRepo = GetIt.I.get<AccountRepo>();

  var contactDao = GetIt.I.get<ContactDao>();

  var roomDao = GetIt.I.get<RoomDao>();

  var messageRepo = GetIt.I.get<MessageRepo>();

  var roomRepo = GetIt.I.get<RoomRepo>();

  static ClientChannel clientChannel = ClientChannel(
      servicesDiscoveryRepo.contactServices.host,
      port: servicesDiscoveryRepo.contactServices.port,
      options: ChannelOptions(credentials: ChannelCredentials.insecure()));
  var contactServices = ContactServiceClient(clientChannel);

  syncContacts() async {
    List<Contact> contacts = new List();

    if (kDebugMode) {
      PhoneNumber p1 = PhoneNumber()
        ..countryCode = 98
        ..nationalNumber = Int64.parseInt("1111111111");
      contacts.add(Contact()
        ..phoneNumber = p1
        ..firstName = "Contact"
        ..lastName = "1");
      PhoneNumber p2 = PhoneNumber()
        ..countryCode = 98
        ..nationalNumber = Int64.parseInt("2222222222");
      contacts.add(Contact()
        ..phoneNumber = p2
        ..firstName = "Contact"
        ..lastName = "2");
      PhoneNumber p3 = PhoneNumber()
        ..countryCode = 98
        ..nationalNumber = Int64.parseInt("3333333333");
      contacts.add(Contact()
        ..phoneNumber = p3
        ..firstName = "Contact"
        ..lastName = "3");
      PhoneNumber p4 = PhoneNumber()
        ..countryCode = 98
        ..nationalNumber = Int64.parseInt("4444444444");
      contacts.add(Contact()
        ..phoneNumber = p4
        ..firstName = "Contact"
        ..lastName = "4");
      PhoneNumber p5 = PhoneNumber()
        ..countryCode = 98
        ..nationalNumber = Int64.parseInt("55555584455");
      contacts.add(Contact()
        ..phoneNumber = p5
        ..firstName = "Contact"
        ..lastName = "5");
      for (var contact in contacts) {
        contactDao.insetContact(myContact.Contact(
            phoneNumber: contact.phoneNumber.nationalNumber.toString(),
            firstName: contact.firstName,
            lastName: contact.lastName,
            isMute: true,
            isBlock: false));
      }
    }

    Iterable<OsContact.Contact> phoneContacts =
    await OsContact.ContactsService.getContacts();
    for (OsContact.Contact phoneContact in phoneContacts) {
      PhoneNumber phoneNumber = PhoneNumber()
        ..nationalNumber =
        Int64.parseInt(phoneContact.phones.elementAt(0).toString());
      Contact contact = Contact()
        ..lastName = phoneContact.displayName
        ..phoneNumber = phoneNumber;

      contacts.add(contact);
    }

    sendContacts(contacts);
  }

  Future<List<UserAsContact>> sendContacts(List<Contact> contacts) async {
    var sendContacts = SaveContactsReq();
    contacts.forEach((element) {
      sendContacts.contactList.add(element);
    });
    var result = await contactServices.saveContacts(sendContacts,
        options: CallOptions(
            metadata: {'accessToken': await accountRepo.getAccessToken()}));
    print(sendContacts.contactList.length.toString());
    return _getContacts(contacts);
  }

  Future<List<UserAsContact>> _getContacts(List<Contact> contacts) async {
    var result = await contactServices.getContactListUsers(
        GetContactListUsersReq(),
        options: CallOptions(
            metadata: {'accessToken': await accountRepo.getAccessToken()}));
    for (var contact in result.userList) {
      contactDao.insetContact(myContact.Contact(
        uid: contact.uid.string,
        phoneNumber: contact.phoneNumber.nationalNumber.toString(),
        firstName: contact.firstName,
        lastName: contact.lastName,
        isMute: true,
        isBlock: false,
      ));
      roomRepo.updateRoomName(
          contact.uid.string, contact.firstName + "\t" + contact.lastName);
      roomDao.insertRoom(myContact.Room(
          roomId: contact.uid.string, lastMessage: null, mentioned: false));
    }

    _getContactsDetails();
    return result.userList;
  }

  _getContactsDetails() async {
    var result = await contactServices.getContactList(GetContactListReq(),
        options: CallOptions(
            metadata: {'accessToken': await accountRepo.getAccessToken()}));

    for (var contact in result.contactList) {
      contactDao.insetContact(myContact.Contact(
          phoneNumber: contact.phoneNumber.nationalNumber.toString(),
          firstName: contact.firstName,
          lastName: contact.lastName,
          isMute: true,
          isBlock: false));
    }
  }
}
