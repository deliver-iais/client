// ignore_for_file: file_names

import 'dart:async';

import 'package:contacts_service/contacts_service.dart' as contacts_service_pb;
import 'package:deliver/box/contact.dart' as contact_pb;
import 'package:deliver/box/dao/contact_dao.dart';
import 'package:deliver/box/dao/room_dao.dart';
import 'package:deliver/box/dao/uid_id_name_dao.dart';
import 'package:deliver/box/member.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/services/check_permissions_service.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/name.dart';
import 'package:deliver/shared/methods/phone.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pbenum.dart';
import 'package:deliver_public_protocol/pub/v1/models/contact.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/phone.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/user.pb.dart';
import 'package:deliver_public_protocol/pub/v1/profile.pbgrpc.dart';
import 'package:deliver_public_protocol/pub/v1/query.pbgrpc.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:synchronized/synchronized.dart';

class ContactRepo {
  final _logger = GetIt.I.get<Logger>();
  final _contactDao = GetIt.I.get<ContactDao>();
  final _roomDao = GetIt.I.get<RoomDao>();
  final _uidIdNameDao = GetIt.I.get<UidIdNameDao>();
  final _contactServices = GetIt.I.get<ContactServiceClient>();
  final _checkPermission = GetIt.I.get<CheckPermissionsService>();
  final _requestLock = Lock();

  final QueryServiceClient _queryServiceClient =
      GetIt.I.get<QueryServiceClient>();
  final Map<PhoneNumber, String> _contactsDisplayName = {};

  Future<void> syncContacts() async {
    if (_requestLock.locked) {
      return;
    }
    return _requestLock.synchronized(() async {
      if (await _checkPermission.checkContactPermission() ||
          isDesktop ||
          isIOS) {
        final contacts = <Contact>[];
        if (!isDesktop) {
          final Iterable<contacts_service_pb.Contact> phoneContacts =
              await contacts_service_pb.ContactsService.getContacts(
            withThumbnails: false,
            photoHighResolution: false,
            orderByGivenName: false,
            iOSLocalizedLabels: false,
          );

          for (final phoneContact in phoneContacts) {
            for (final p in phoneContact.phones!) {
              try {
                final contactPhoneNumber = p.value.toString();
                final phoneNumber = _getPhoneNumber(
                  contactPhoneNumber,
                  phoneContact.displayName!,
                );
                _contactsDisplayName[phoneNumber] = phoneContact.displayName!;
                final contact = Contact()
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
    final p = getPhoneNumber(phone);

    if (p == null) {
      throw Exception("Not Valid Number  $name ***** $phone");
    } else {
      return p;
    }
  }

  void sendContacts(List<Contact> contacts) {
    try {
      var i = 0;
      while (i <= contacts.length) {
        _sendContacts(
          contacts.sublist(
            i,
            contacts.length > i + 79 ? i + 79 : contacts.length,
          ),
        );

        i = i + 80;
      }
      getContacts();
    } catch (e) {
      _logger.e(e);
    }
  }

  Future<bool> sendNewContact(Contact contact) async {
    try {
      final res = await _contactServices.saveContacts(
        SaveContactsReq()
          ..contactList.add(contact)
          ..returnUserContactByPhoneNumberList.add(contact.phoneNumber),
      );
      _saveContact(res.userList);
      return res.userList.isNotEmpty;
    } catch (e) {
      _logger.e(e);
      return false;
    }
  }

  Future<bool> _sendContacts(List<Contact> contacts) async {
    try {
      final sendContacts = SaveContactsReq();
      for (final element in contacts) {
        sendContacts.contactList.add(element);
      }
      await _contactServices.saveContacts(sendContacts);
      return true;
    } catch (e) {
      _logger.e(e);
      return false;
    }
  }

  Stream<List<contact_pb.Contact>> watchAll() => _contactDao.watchAll();

  Future<List<contact_pb.Contact>> getAll() => _contactDao.getAll();

  Future<void> getContacts() async {
    try {
      final result =
          await _contactServices.getContactListUsers(GetContactListUsersReq());
      _saveContact(result.userList);
    } catch (e) {
      _logger.e(e);
    }
  }

  void _saveContact(List<UserAsContact> users) {
    for (final contact in users) {
      _contactDao.save(
        contact_pb.Contact(
          uid: contact.uid.asString(),
          countryCode: contact.phoneNumber.countryCode.toString(),
          nationalNumber: contact.phoneNumber.nationalNumber.toString(),
          firstName: contact.firstName,
          lastName: contact.lastName,
        ),
      );

      roomNameCache.set(contact.uid.asString(), contact.firstName);
      _uidIdNameDao.update(
        contact.uid.asString(),
        name: "${contact.firstName} ${contact.lastName}",
      );
      _roomDao.updateRoom(uid: contact.uid.asString());
    }
  }

  Future<void> getUserIdByUid(Uid uid) async {
    try {
      // For now, Group and Bot not supported in server side!!
      final result =
          await _queryServiceClient.getIdByUid(GetIdByUidReq()..uid = uid);
      return _uidIdNameDao.update(uid.asString(), id: result.id);
    } catch (e) {
      _logger.e(e);
    }
  }

  Future<void> fetchMemberId(Member member) async {
    if (!member.memberUid.asUid().isUser()) return;
    final m = await _uidIdNameDao.getByUid(member.memberUid);
    if (m == null || m.id == null) {
      return getUserIdByUid(member.memberUid.asUid());
    }
  }

  Future<List<Uid>> searchUser(String query) async {
    if (query.isEmpty) {
      return [];
    }

    try {
      final result = await _queryServiceClient.searchUid(
        SearchUidReq()
          ..text = query
          ..justSearchInId = true
          ..category = Categories.USER
          ..filterByCategory = false,
      );
      final searchResult = <Uid>[];
      for (final room in result.itemList) {
        searchResult.add(room.uid);
      }
      return searchResult;
    } catch (e) {
      _logger.e(e);
      return [];
    }
  }

  // TODO(hasan): we should merge getContact and getContactFromServer functions together and refactor usages too, https://gitlab.iais.co/deliver/wiki/-/issues/421
  Future<contact_pb.Contact?> getContact(Uid userUid) =>
      _contactDao.getByUid(userUid.asString());

  Future<String?> getContactFromServer(Uid contactUid) async {
    try {
      final contact = await _contactServices
          .getUserByUid(GetUserByUidReq()..uid = contactUid);
      final name = buildName(contact.user.firstName, contact.user.lastName);
      unawaited(_uidIdNameDao.update(contactUid.asString(), name: name));
      return name;
    } catch (e) {
      _logger.e(e);
      return null;
    }
  }

  Future<bool> contactIsExist(String countryCode, String nationalNumber) async {
    final result = await _contactDao.get(countryCode, nationalNumber);
    return result != null;
  }
}
