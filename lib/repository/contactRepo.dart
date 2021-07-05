import 'package:deliver_flutter/box/dao/contact_dao.dart';
import 'package:deliver_flutter/box/contact.dart' as DB;
import 'package:deliver_flutter/box/dao/room_dao.dart';
import 'package:deliver_flutter/box/dao/uid_id_name_dao.dart';
import 'package:deliver_flutter/box/room.dart';
import 'package:deliver_flutter/repository/roomRepo.dart';

import 'package:deliver_flutter/repository/servicesDiscoveryRepo.dart';
import 'package:contacts_service/contacts_service.dart' as OsContact;
import 'package:deliver_flutter/services/check_permissions_service.dart';
import 'package:deliver_flutter/theme/constants.dart';

import 'package:deliver_public_protocol/pub/v1/models/contact.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/phone.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:deliver_public_protocol/pub/v1/profile.pb.dart';

import 'package:deliver_public_protocol/pub/v1/profile.pbgrpc.dart';
import 'package:deliver_public_protocol/pub/v1/query.pbgrpc.dart';
import 'package:get_it/get_it.dart';
import 'package:grpc/grpc.dart';
import 'package:fixnum/fixnum.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';

import 'accountRepo.dart';

class ContactRepo {
  final _accountRepo = GetIt.I.get<AccountRepo>();

  final _contactDao = GetIt.I.get<ContactDao>();

  final _roomDao = GetIt.I.get<RoomDao>();

  final _checkPermission = GetIt.I.get<CheckPermissionsService>();

  final _contactServices = ContactServiceClient(ProfileServicesClientChannel);

  final _uidIdNameDao = GetIt.I.get<UidIdNameDao>();

  final QueryServiceClient _queryServiceClient =
      GetIt.I.get<QueryServiceClient>();

  final Map<PhoneNumber, String> _contactsDisplayName = Map();

  syncContacts() async {
    if (await _checkPermission.checkContactPermission() ||
        isDesktop() ||
        isIOS()) {
      List<Contact> contacts = [];
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
      await _contactServices.saveContacts(sendContacts,
          options: CallOptions(
              metadata: {'access_token': await _accountRepo.getAccessToken()}));
    } catch (e) {
      print(e.toString());
    }
  }

  Stream<List<DB.Contact>> watchAll() => _contactDao.watchAll();

  Future<List<DB.Contact>> getAll() => _contactDao.getAll();

  Future getContacts() async {
    var result = await _contactServices.getContactListUsers(
        GetContactListUsersReq(),
        options: CallOptions(
            metadata: {'access_token': await _accountRepo.getAccessToken()}));

    for (var contact in result.userList) {
      _contactDao.save(DB.Contact(
          uid: contact.uid.asString(),
          phoneNumber: contact.phoneNumber.nationalNumber.toString(),
          firstName: contact.firstName,
          lastName: contact.lastName));

      if (contact.uid != null) {
        roomNameCache.set(contact.uid.asString(), contact.firstName);
        _roomDao.updateRoom(Room(uid: contact.uid.asString()));
      }
    }
  }

  Future<String> getIdByUid(Uid uid) async {
    try {
      var result = await _queryServiceClient.getIdByUid(
          GetIdByUidReq()..uid = uid,
          options: CallOptions(
              metadata: {'access_token': await _accountRepo.getAccessToken()}));
      _uidIdNameDao.update(uid.asString(), id: result.id);
      return result.id;
    } catch (e) {
      return null;
    }
  }

  Future<List<Uid>> searchUser(String query) async {
    var result = await _queryServiceClient.searchUid(
        SearchUidReq()..text = query,
        options: CallOptions(
            metadata: {'access_token': await _accountRepo.getAccessToken()}));
    List<Uid> searchResult = [];
    for (var room in result.itemList) {
      searchResult.add(room.uid);
    }
    return searchResult;
  }

  // TODO needs to be refactored!
  Future<DB.Contact> getContact(Uid userUid) async {
    DB.Contact contact = await _contactDao.getByUid(userUid.asString());
    return contact;
  }

  Future<bool> contactIsExist(String number) async {
    var result = await _contactDao.get(number);
    return result != null;
  }
}
