import 'package:deliver_flutter/db/dao/ContactDao.dart';
import 'package:deliver_flutter/db/dao/RoomDao.dart';
import 'package:deliver_flutter/db/dao/UserInfoDao.dart';
import 'package:deliver_flutter/db/database.dart' as Database;

import 'package:deliver_flutter/repository/servicesDiscoveryRepo.dart';
import 'package:contacts_service/contacts_service.dart' as OsContact;
import 'package:deliver_flutter/services/check_permissions_service.dart';
import 'package:deliver_flutter/theme/constants.dart';
import 'package:deliver_flutter/utils/log.dart';

import 'package:deliver_public_protocol/pub/v1/models/contact.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/phone.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/user.pb.dart';
import 'package:deliver_public_protocol/pub/v1/profile.pb.dart';

import 'package:deliver_public_protocol/pub/v1/profile.pbgrpc.dart';
import 'package:deliver_public_protocol/pub/v1/query.pbgrpc.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:grpc/grpc.dart';
import 'package:fixnum/fixnum.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';
import 'package:moor/moor.dart';

import 'accountRepo.dart';

class ContactRepo {
  var _accountRepo = GetIt.I.get<AccountRepo>();

  var _contactDao = GetIt.I.get<ContactDao>();

  var _roomDao = GetIt.I.get<RoomDao>();

  var _checkPermission = GetIt.I.get<CheckPermissionsService>();

  var contactServices = ContactServiceClient(ProfileServicesClientChannel);

  var _userInfoDao = GetIt.I.get<UserInfoDao>();

  final QueryServiceClient _queryServiceClient =
      GetIt.I.get<QueryServiceClient>();

  Map<PhoneNumber, String> _contactsDisplayName = Map();

  syncContacts() async {
    //  _getPhoneNumber("+989124131853", "");

    if (await _checkPermission.checkContactPermission() ||
        isDesktop() ||
        isIOS()) {
      List<Contact> contacts = new List();
      if (!isDesktop()) {
        Iterable<OsContact.Contact> phoneContacts =
            await OsContact.ContactsService.getContacts(
                withThumbnails: false,
                photoHighResolution: false,
                orderByGivenName: false,
                iOSLocalizedLabels: false);

        for (OsContact.Contact phoneContact in phoneContacts) {
          for (var p in phoneContact.phones) {
            try {
              String contactPhoneNumber = p.value
                  .toString()
                  .replaceAll(new RegExp(r"\s+\b|\b\s"), '')
                  .replaceAll('+', '')
                  .replaceAll('(', '')
                  .replaceAll(')', '')
                  .replaceAll('-', '');
              PhoneNumber phoneNumber =
                  _getPhoneNumber(contactPhoneNumber, phoneContact.displayName);
              _contactsDisplayName[phoneNumber] = phoneContact.displayName;
              Contact contact = Contact()
                ..lastName = phoneContact.displayName
                ..phoneNumber = phoneNumber;
              contacts.add(contact);
              // debug("+++++++++++++++++++++++++++++++++++++");
              // debug("${p.value} +++++ ${phoneContact.displayName}");
            } catch (e) {
              // debug("______________________________");
              // debug(e.toString());
              // debug("${phoneContact.displayName} ______${p.value}");
            }
          }
        }
      }
      sendContacts(contacts);
    }
  }

  PhoneNumber _getPhoneNumber(String phone, String name) {
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
    throw Exception("Not Valid Number  $name ***** $phone");
  }

  Future sendContacts(List<Contact> contacts) async {
    getContacts();
    try {
      int i = 0;
      while (i <= contacts.length) {
        _sendContacts(contacts.sublist(
            i, contacts.length > i + 79 ? i + 79 : contacts.length));

        i = i + 80;
      }
      getContacts();
    } catch (e) {
      print(e.toString());
    }
  }

  Future addContact(Contact contact) async {
    _sendContacts([contact]);
  }

  _sendContacts(List<Contact> contacts) async {
    try {
      var sendContacts = SaveContactsReq();
      contacts.forEach((element) {
        sendContacts.contactList.add(element);
      });
      await contactServices.saveContacts(sendContacts,
          options: CallOptions(
              metadata: {'access_token': await _accountRepo.getAccessToken()}));
    } catch (e) {
      print(e.toString());
    }
  }

  Future getContacts() async {
    var result = await contactServices.getContactListUsers(
        GetContactListUsersReq(),
        options: CallOptions(
            metadata: {'access_token': await _accountRepo.getAccessToken()}));

    for (var contact in result.userList) {
      _contactDao.insertContact(Database.ContactsCompanion(
        uid: Value(contact.uid.asString()),
        phoneNumber: Value(contact.phoneNumber.nationalNumber.toString()),
        firstName: Value(_contactsDisplayName[contact.phoneNumber] != null
            ? _contactsDisplayName[contact.phoneNumber]
            : "${contact.firstName} ${contact.lastName.isNotEmpty ? contact.lastName : " "}"),
        isMute: Value(true),
        isBlock: Value(false),
      ));

      if (contact.uid != null) {
        _roomDao.insertRoomCompanion(
            Database.RoomsCompanion.insert(roomId: contact.uid.asString()));
      }
      getUsername(contact);
    }
  }

  Future<String> searchUserByUid(Uid uid) async {
    try {
      var result = await _queryServiceClient.getIdByUid(
          GetIdByUidReq()..uid = uid,
          options: CallOptions(
              metadata: {'access_token': await _accountRepo.getAccessToken()}));
      _userInfoDao.upsertUserInfo(
          Database.UserInfo(uid: uid.asString(), username: result.id));
      return result.id;
    } catch (e) {
      return null;
    }
  }

  Future<Uid> searchUserByUsername(String username) async {
    var result = await _queryServiceClient.getUidById(
        GetUidByIdReq()..id = username,
        options: CallOptions(
            metadata: {'access_token': await _accountRepo.getAccessToken()}));

    return result.uid;
  }

  Future<List<Uid>> searchUser(String query) async {
    var result = await _queryServiceClient.searchUid(
        SearchUidReq()..text = query,
        options: CallOptions(
            metadata: {'access_token': await _accountRepo.getAccessToken()}));
    List<Uid> searchResult = List();
    for (var room in result.itemList) {
      searchResult.add(room.uid);
    }
    return searchResult;
  }

  Future<Database.Contact> getContact(Uid userUid) async {
    Database.Contact contact =
        await _contactDao.getContactByUid(userUid.asString());
    return contact;
  }

  Future<bool> ContactIsExist(String number) async {
    var result = await _contactDao.getContact(number);
    return result != null;
  }

  void getUsername(UserAsContact contact) async {
    var username = await searchUserByUid(contact.uid);
    if (username != null) {
      _contactDao.insertContact(Database.ContactsCompanion(
          phoneNumber: Value(contact.phoneNumber.nationalNumber.toString()),
          username: Value(username),
          uid: Value(contact.uid.asString())));
    }
  }
}
