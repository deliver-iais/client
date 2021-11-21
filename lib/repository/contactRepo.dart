import 'package:deliver/box/dao/contact_dao.dart';
import 'package:deliver/box/contact.dart' as DB;
import 'package:deliver/box/dao/room_dao.dart';
import 'package:deliver/box/dao/uid_id_name_dao.dart';
import 'package:deliver/box/member.dart';
import 'package:deliver/box/room.dart';
import 'package:deliver/repository/roomRepo.dart';

import 'package:contacts_service/contacts_service.dart' as OsContact;
import 'package:deliver/services/check_permissions_service.dart';
import 'package:deliver/shared/methods/name.dart';
import 'package:deliver/shared/methods/phone.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pbenum.dart';

import 'package:deliver_public_protocol/pub/v1/models/contact.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/phone.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:deliver_public_protocol/pub/v1/profile.pb.dart';

import 'package:deliver_public_protocol/pub/v1/profile.pbgrpc.dart';
import 'package:deliver_public_protocol/pub/v1/query.pbgrpc.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:logger/logger.dart';
import 'package:synchronized/synchronized.dart';

class ContactRepo {
  final _logger = GetIt.I.get<Logger>();
  final _contactDao = GetIt.I.get<ContactDao>();
  final _roomDao = GetIt.I.get<RoomDao>();
  final _uidIdNameDao = GetIt.I.get<UidIdNameDao>();
  final _contactServices = GetIt.I.get<ContactServiceClient>();
  final _checkPermission = GetIt.I.get<CheckPermissionsService>();
  var requestLock = Lock();

  final QueryServiceClient _queryServiceClient =
      GetIt.I.get<QueryServiceClient>();
  final Map<PhoneNumber, String> _contactsDisplayName = Map();

  syncContacts() async {
    if (!requestLock.locked)
      requestLock.synchronized(() async {
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
              for (var p in phoneContact.phones!) {
                try {
                  String contactPhoneNumber = p.value.toString();
                  PhoneNumber phoneNumber = _getPhoneNumber(
                      contactPhoneNumber, phoneContact.displayName!);
                  _contactsDisplayName[phoneNumber] = phoneContact.displayName!;
                  Contact contact = Contact()
                    ..lastName = phoneContact.displayName!
                    ..phoneNumber = phoneNumber;
                  contacts.add(contact);
                } catch (e) {
                  _logger.e(e);
                }
              }
            }
          }
          sendContacts(contacts);
        }
      });
  }

  PhoneNumber _getPhoneNumber(String phone, String name) {
    PhoneNumber p = getPhoneNumber(phone);

    if (p == null) {
      throw Exception("Not Valid Number  $name ***** $phone");
    } else {
      return p;
    }
  }

  Future sendContacts(List<Contact> contacts) async {
    try {
      int i = 0;
      while (i <= contacts.length) {
        _sendContacts(contacts.sublist(
            i, contacts.length > i + 79 ? i + 79 : contacts.length));

        i = i + 80;
      }
      getContacts();
    } catch (e) {
      _logger.e(e);
    }
  }

  Future<bool> addContact(Contact contact) async {
    return _sendContacts([contact]);
  }

  Future<bool> _sendContacts(List<Contact> contacts) async {
    try {
      var sendContacts = SaveContactsReq();
      contacts.forEach((element) {
        sendContacts.contactList.add(element);
      });
      await _contactServices.saveContacts(sendContacts);
      return true;
    } catch (e) {
      _logger.e(e);
      return false;
    }
  }

  Stream<List<DB.Contact>> watchAll() => _contactDao.watchAll();

  Future<List<DB.Contact>> getAll() => _contactDao.getAll();

  Future getContacts() async {
    var result =
        await _contactServices.getContactListUsers(GetContactListUsersReq());

    for (var contact in result.userList) {
      _contactDao.save(DB.Contact(
          uid: contact.uid.asString(),
          countryCode: contact.phoneNumber.countryCode.toString(),
          nationalNumber: contact.phoneNumber.nationalNumber.toString(),
          firstName: contact.firstName,
          lastName: contact.lastName));

      if (contact.uid != null) {
        roomNameCache.set(contact.uid.asString(), contact.firstName);
        _uidIdNameDao.update(contact.uid.asString(),
            name: "${contact.firstName} ${contact.lastName ?? ""}");
        _roomDao.updateRoom(Room(uid: contact.uid.asString()));
      }
    }
  }

  Future<String?> getUserIdByUid(Uid uid) async {
    try {
      // For now, Group and Bot not supported in server side!!
      var result =
          await _queryServiceClient.getIdByUid(GetIdByUidReq()..uid = uid);
      _uidIdNameDao.update(uid.asString(), id: result.id);
      return result.id;
    } catch (e) {
      _logger.e(e);
      return null;
    }
  }

  Future<void> fetchMemberId(Member member) async {
    if (!member.memberUid.asUid().isUser()) return;
    var m = await _uidIdNameDao.getByUid(member.memberUid);
    if (m == null || m.id == null) getUserIdByUid(member.memberUid.asUid());
  }

  Future<List<Uid>> searchUser(String query) async {
    try {
      var result = await _queryServiceClient.searchUid(SearchUidReq()
        ..text = query
        ..justSearchInId = true
        ..category = Categories.USER
        ..filterByCategory = false);
      List<Uid> searchResult = [];
      for (var room in result.itemList) {
        searchResult.add(room.uid);
      }
      return searchResult;
    } catch (e) {
      _logger.e(e);
      return [];
    }
  }

  // TODO needs to be refactored!
  Future<DB.Contact?> getContact(Uid userUid) async {
    DB.Contact? contact = await _contactDao.getByUid(userUid.asString());
    return contact;
  }

  Future<bool> contactIsExist(String countryCode, String nationalNumber) async {
    var result = await _contactDao.get(countryCode, nationalNumber);
    return result != null;
  }

  Future<String?> getContactFromServer(Uid contactUid) async {
    try {
      var contact = await _contactServices
          .getUserByUid(GetUserByUidReq()..uid = contactUid);
      var name = buildName(contact.user.firstName, contact.user.lastName);
      _uidIdNameDao.update(contactUid.asString(), name: name);
      return name;
    } catch (e) {
      _logger.e(e);
      return null;
    }
  }
}
