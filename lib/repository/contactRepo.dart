import 'package:deliver_flutter/db/dao/ContactDao.dart';
import 'package:deliver_flutter/db/dao/RoomDao.dart';
import 'package:deliver_flutter/db/database.dart' as Database;

import 'package:deliver_flutter/repository/servicesDiscoveryRepo.dart';
import 'package:contacts_service/contacts_service.dart' as OsContact;
import 'package:deliver_flutter/services/check_permissions_service.dart';
import 'package:deliver_flutter/theme/constants.dart';

import 'package:deliver_public_protocol/pub/v1/models/contact.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/phone.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/user.pb.dart';
import 'package:deliver_public_protocol/pub/v1/profile.pb.dart';

import 'package:deliver_public_protocol/pub/v1/profile.pbgrpc.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:grpc/grpc.dart';
import 'package:fixnum/fixnum.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';

import 'accountRepo.dart';

class ContactRepo {
  var _accountRepo = GetIt.I.get<AccountRepo>();

  var _contactDao = GetIt.I.get<ContactDao>();

  var _roomDao = GetIt.I.get<RoomDao>();

  var _checkPermission = GetIt.I.get<CheckPermissionsService>();

  var contactServices = ContactServiceClient(ProfileServicesClientChannel);

  Map<PhoneNumber, String> _contactsDisplayName = Map();

  syncContacts() async {
    if (await _checkPermission.checkContactPermission() || isDesktop()) {
      List<Contact> contacts = new List();
      //
      // if (kDebugMode) {
      //   PhoneNumber p1 = PhoneNumber()
      //     ..countryCode = 98
      //     ..nationalNumber = Int64.parseInt("1111111111");
      //   contacts.add(Contact()
      //     ..phoneNumber = p1
      //     ..firstName = "Contact"
      //     ..lastName = "1");
      //   PhoneNumber p2 = PhoneNumber()
      //     ..countryCode = 98
      //     ..nationalNumber = Int64.parseInt("2222222222");
      //   contacts.add(Contact()
      //     ..phoneNumber = p2
      //     ..firstName = "Contact"
      //     ..lastName = "2");
      //   PhoneNumber p3 = PhoneNumber()
      //     ..countryCode = 98
      //     ..nationalNumber = Int64.parseInt("3333333333");
      //   contacts.add(Contact()
      //     ..phoneNumber = p3
      //     ..firstName = "Contact"
      //     ..lastName = "3");
      //   PhoneNumber p4 = PhoneNumber()
      //     ..countryCode = 98
      //     ..nationalNumber = Int64.parseInt("4444444444");
      //   contacts.add(Contact()
      //     ..phoneNumber = p4
      //     ..firstName = "Contact"
      //     ..lastName = "4");
      //   PhoneNumber p5 = PhoneNumber()
      //     ..countryCode = 98
      //     ..nationalNumber = Int64.parseInt("55555584455");
      //   contacts.add(Contact()
      //     ..phoneNumber = p5
      //     ..firstName = "Contact"
      //     ..lastName = "5");
      //   for (var contact in contacts) {
      //     _contactDao.insertContact(Database.Contact(
      //         phoneNumber: contact.phoneNumber.nationalNumber.toString(),
      //         firstName: contact.firstName,
      //         lastName: contact.lastName,
      //         isMute: true,
      //         isBlock: false));
      //   }
      // }
      if (!isDesktop()) {
        Iterable<OsContact.Contact> phoneContacts =
            await OsContact.ContactsService.getContacts(withThumbnails: false,photoHighResolution: false,orderByGivenName: false,iOSLocalizedLabels: false);

        for (OsContact.Contact phoneContact in phoneContacts) {
          try {
            String contactPhoneNumber = phoneContact.phones.first.value
                .toString()
                .replaceAll(' ', '')
                .replaceAll('+', '')
                .replaceAll('(', '')
                .replaceAll(')', '')
                .replaceAll('-', '');

            PhoneNumber phoneNumber = _getPhoneNumber(contactPhoneNumber);
            _contactsDisplayName[phoneNumber] = phoneContact.displayName;
            Contact contact = Contact()
              ..lastName = phoneContact.displayName
              ..phoneNumber = phoneNumber;
            contacts.add(contact);
          } catch (e) {
            print("ContactRepo");
          }
        }
      }
      sendContacts(contacts);
    }
  }

  PhoneNumber _getPhoneNumber(String phone) {
    PhoneNumber phoneNumber = PhoneNumber();
    switch (phone.length) {
      case 11:
        phoneNumber.countryCode = 98;
        phoneNumber.nationalNumber = Int64.parseInt(phone.substring(1, 11));
        return phoneNumber;
        break;
      case 12:
        phoneNumber.countryCode = int.parse(phone.substring(0, 2));
        phoneNumber.nationalNumber = Int64.parseInt(phone.substring(2, 12));
        return phoneNumber;
      case 10:
        phoneNumber.countryCode = 98;
        phoneNumber.nationalNumber = Int64.parseInt(phone.substring(0, 10));
        return phoneNumber;
    }
    throw Exception("Not Valid Number $phone");
  }

  Future sendContacts(List<Contact> contacts) async {
    int i = 0;
    while (i < contacts.length) {
      _sendContacts(contacts.sublist(
          i, contacts.length > i + 49 ? i + 49 : contacts.length));
      i = i + 50;
    }
    getContacts();
  }

  _sendContacts(List<Contact> contacts) async {
    var sendContacts = SaveContactsReq();
    contacts.forEach((element) {
      sendContacts.contactList.add(element);
    });
    await contactServices.saveContacts(sendContacts,
        options: CallOptions(
            metadata: {'accessToken': await _accountRepo.getAccessToken()}));
  }

  Future getContacts() async {
    var result = await contactServices.getContactListUsers(
        GetContactListUsersReq(),
        options: CallOptions(
            metadata: {'accessToken': await _accountRepo.getAccessToken()}));

    for (var contact in result.userList) {
      _contactDao.insertContact(Database.Contact(
        uid: contact.uid.asString(),
        phoneNumber: contact.phoneNumber.nationalNumber.toString(),
        username: contact.username,
        firstName: _contactsDisplayName[contact.phoneNumber]!= null?_contactsDisplayName[contact.phoneNumber]:"${contact.firstName} ${contact.lastName.isNotEmpty?contact.lastName:" "}" ,
        isMute: true,
        isBlock: false,
      ));
      if (contact.uid != null) {
        _roomDao.insertRoomCompanion(
            Database.RoomsCompanion.insert(roomId: contact.uid.asString()));
      }
    }
  }



  Future<UserAsContact> searchUserByUid(Uid uid) async {
    try {
      var result = await contactServices.getUserByUid(
          GetUserByUidReq()..uid = uid,
          options: CallOptions(
              timeout: Duration(seconds: 2),
              metadata: {'accessToken': await _accountRepo.getAccessToken()}));
      return result.user;
    } catch (e) {
      return null;
    }
  }

  Future<UserAsContact> searchUserByUsername(String username) async {
    var result = await contactServices.getUserByUsername(
        GetUserByUsernameReq()..username = username,
        options: CallOptions(
            metadata: {'accessToken': await _accountRepo.getAccessToken()}));

    return result.user;
  }

  Future<List<UserAsContact>> searchUser(String query) async {
    var result = await contactServices.userSearch(UserSearchReq()..text = query,
        options: CallOptions(
            metadata: {'accessToken': await _accountRepo.getAccessToken()}));
    return result.userList;
  }

  Future<Database.Contact> getContact(Uid userUid) async {
    Database.Contact contact =
        await _contactDao.getContactByUid(userUid.asString());
    return contact;
  }

  Future <bool>ContactIsExist(String number) async  {
    var result = await _contactDao.getContact(number);
    return result!=null;
  }
}
