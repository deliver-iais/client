// ignore_for_file: file_names

import 'dart:async';

import 'package:collection/collection.dart';
import 'package:contacts_service/contacts_service.dart' as contacts_service_pb;
import 'package:deliver/box/contact.dart' as contact_model;
import 'package:deliver/box/dao/contact_dao.dart';
import 'package:deliver/box/dao/room_dao.dart';
import 'package:deliver/box/dao/uid_id_name_dao.dart';
import 'package:deliver/box/member.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/repository/servicesDiscoveryRepo.dart';
import 'package:deliver/services/check_permissions_service.dart';
import 'package:deliver/shared/constants.dart';
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
import 'package:fixnum/fixnum.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:rxdart/rxdart.dart';
import 'package:synchronized/synchronized.dart';

class ContactRepo {
  final _logger = GetIt.I.get<Logger>();
  final _contactDao = GetIt.I.get<ContactDao>();
  final _roomDao = GetIt.I.get<RoomDao>();
  final _uidIdNameDao = GetIt.I.get<UidIdNameDao>();
  final _sdr = GetIt.I.get<ServicesDiscoveryRepo>();
  final _checkPermission = GetIt.I.get<CheckPermissionsService>();
  final _requestLock = Lock();
  final BehaviorSubject<bool> isSyncingContacts = BehaviorSubject.seeded(false);
  final BehaviorSubject<double> sendContactProgress = BehaviorSubject.seeded(0);

  Future<void> syncContacts() async {
    isSyncingContacts.add(true);
    if (_requestLock.locked) {
      return;
    }
    return _requestLock.synchronized(() async {
      if (await _checkPermission.checkContactPermission() ||
          isDesktop ||
          isIOS) {
        var contacts = <Contact>[];
        if (!isDesktop) {
          final Iterable<contacts_service_pb.Contact> phoneContacts =
              await contacts_service_pb.ContactsService.getContacts(
            withThumbnails: false,
            photoHighResolution: false,
            orderByGivenName: false,
            iOSLocalizedLabels: false,
          );

          for (final phoneContact in phoneContacts) {
            if (phoneContact.phones != null) {
              for (final p in phoneContact.phones!.toSet().toList()) {
                try {
                  final contactPhoneNumber = p.value.toString();
                  final phoneNumber = _getPhoneNumber(
                    contactPhoneNumber,
                    phoneContact.displayName ?? "",
                  );
                  final contact = Contact()
                    ..firstName = phoneContact.displayName ?? ""
                    ..phoneNumber = phoneNumber;
                  contacts.add(contact);
                } catch (e) {
                  _logger.e(e);
                }
              }
            }
          }
          final contactsMap = <int, Contact>{};
          for (final contact in contacts) {
            contactsMap[contact.phoneNumber.nationalNumber.toInt()] = contact;
          }
          contacts = await _filterPhoneContactsToSend(
            contactsMap.values.toSet().toList(),
          );
          if (contacts.isNotEmpty) {
            _savePhoneContacts(contacts);
            sendContacts(contacts);
          } else {
            unawaited(getContacts());
          }
        } else {
          await getContacts();
        }
      }
    });
  }

  void _savePhoneContacts(
    List<Contact> contacts, {
    int? expTime,
  }) {
    for (final element in contacts) {
      try {
        _contactDao.save(
          countryCode: element.phoneNumber.countryCode,
          nationalNumber: element.phoneNumber.nationalNumber.toInt(),
          updateTime: expTime,
          firstName: element.firstName,
        );
      } catch (e) {
        _logger.e(e);
      }
    }
  }

  Future<List<Contact>> _filterPhoneContactsToSend(
    List<Contact> phoneContacts,
  ) async {
    final contacts = await _contactDao.getAll();
    for (final element in contacts) {
      phoneContacts.removeWhere(
        (pc) => (element.nationalNumber ==
                pc.phoneNumber.nationalNumber.toInt() &&
            ((element.uid != null &&
                    _contactHash(
                          name: pc.firstName,
                          nationalNumber: pc.phoneNumber.nationalNumber.toInt(),
                        ) ==
                        element.syncHash) ||
                (element.uid == null &&
                    element.updateTime != null &&
                    _sendContactTimeExpire(element.updateTime!)))),
      );
    }
    return phoneContacts;
  }

  int _contactHash({required String name, required int nationalNumber}) =>
      const DeepCollectionEquality().hash("$name$nationalNumber");

  Future<void> sendNotSyncedContactInStartTime() async {
    final contacts = await _contactDao.getNotMessengerContact();
    if (contacts != null && contacts.isNotEmpty) {
      unawaited(
        _sendContacts(
          contacts
              .where(
                (element) => ((element.updateTime == null ||
                    _sendContactWithStartTimeExpire(element.updateTime!))),
              )
              .toList()
              .map(
                (e) => Contact(
                  phoneNumber: PhoneNumber(
                    countryCode: e.countryCode,
                    nationalNumber: Int64(e.nationalNumber),
                  ),
                  firstName: e.firstName,
                ),
              )
              .toList(),
        ),
      );
    }
  }

  bool _sendContactTimeExpire(int expTime) =>
      DateTime.now().millisecondsSinceEpoch - expTime <
      MAX_SEND_CONTACT_TIME_EXPIRE;

  bool _sendContactWithStartTimeExpire(int updateTime) =>
      DateTime.now().millisecondsSinceEpoch - updateTime <
      MAX_SEND_CONTACT_START_TIME_EXPIRE;

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
        final end = contacts.length > i + MAX_CONTACT_SIZE_TO_SEND - 1
            ? i + MAX_CONTACT_SIZE_TO_SEND - 1
            : contacts.length;
        final contactsSubList = contacts.sublist(
          i,
          end,
        );
        sendContactProgress.add(end / contacts.length);
        _sendContacts(contactsSubList);
        i = i + MAX_CONTACT_SIZE_TO_SEND;
      }
      getContacts();
    } catch (e) {
      _logger.e(e);
    }
  }

  Future<bool> sendNewContact(Contact contact) async {
    try {
      final res = await _sdr.contactServiceClient.saveContacts(
        SaveContactsReq()
          ..contactList.add(contact)
          ..returnUserContactByPhoneNumberList.add(contact.phoneNumber),
      );
      _saveUserContact(res.userList);
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
        sendContacts.returnUserContactByPhoneNumberList
            .add(element.phoneNumber);
      }
      final saveContactRes =
          await _sdr.contactServiceClient.saveContacts(sendContacts);
      _saveUserContact(saveContactRes.userList);
      _savePhoneContacts(
        contacts,
        expTime: DateTime.now().millisecondsSinceEpoch,
      );

      return true;
    } catch (e) {
      _logger.e(e);
      return false;
    }
  }

  Stream<List<contact_model.Contact>> watchAll() => _contactDao.watchAll();

  Future<List<contact_model.Contact>?> getAllUserAsContact() =>
      _contactDao.getAllUserAsContact();

  Stream<List<contact_model.Contact>?> getNotMessengerContactAsStream() =>
      _contactDao.getNotMessengerContactAsStream();

  Future<void> getContacts() async {
    try {
      final result = await _sdr.contactServiceClient
          .getContactListUsers(GetContactListUsersReq());
      _saveUserContact(result.userList);
    } catch (e) {
      _logger.e(e);
    }
    isSyncingContacts.add(false);
  }

  void _saveUserContact(List<UserAsContact> users) {
    for (final contact in users) {
      _contactDao.save(
        uid: contact.uid.asString(),
        countryCode: contact.phoneNumber.countryCode,
        nationalNumber: contact.phoneNumber.nationalNumber.toInt(),
        firstName: contact.firstName,
        lastName: contact.lastName,
        description: contact.description,
        syncHash: _contactHash(
          name: contact.firstName,
          nationalNumber: contact.phoneNumber.nationalNumber.toInt(),
        ),
      );

      roomNameCache.set(
        contact.uid.asString(),
        buildName(contact.firstName, contact.lastName),
      );
      _uidIdNameDao.update(
        contact.uid.asString(),
        name: buildName(contact.firstName, contact.lastName),
      );
      _roomDao.updateRoom(uid: contact.uid.asString());
    }
  }

  Future<void> getUserIdByUid(Uid uid) async {
    try {
      // For now, Group and Bot not supported in server side!!
      final result =
          await _sdr.queryServiceClient.getIdByUid(GetIdByUidReq()..uid = uid);
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
      final result = await _sdr.queryServiceClient.searchUid(
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
  Future<contact_model.Contact?> getContact(Uid userUid) =>
      _contactDao.getByUid(userUid.asString());

  Future<String?> getContactFromServer(
    Uid contactUid, {
    bool ignoreInsertingOrUpdatingContactDao = false,
  }) async {
    try {
      final contact = await _sdr.contactServiceClient
          .getUserByUid(GetUserByUidReq()..uid = contactUid);
      final name = buildName(contact.user.firstName, contact.user.lastName);

      // Update uidIdName table
      unawaited(_uidIdNameDao.update(contactUid.asString(), name: name));
      if (!ignoreInsertingOrUpdatingContactDao) {
        // Update contact table
        unawaited(
          _contactDao.save(
            uid: contactUid.asString(),
            countryCode: contact.user.phoneNumber.countryCode,
            nationalNumber: contact.user.phoneNumber.nationalNumber.toInt(),
            firstName: contact.user.firstName,
            lastName: contact.user.lastName,
            description: contact.user.description,
            syncHash: _contactHash(
              name: contact.user.firstName,
              nationalNumber: contact.user.phoneNumber.nationalNumber.toInt(),
            ),
          ),
        );
      }
      return name;
    } catch (e) {
      _logger.e(e);
      return null;
    }
  }

  Future<bool> contactIsExist(int countryCode, int nationalNumber) async {
    final result = await _contactDao.get(countryCode, nationalNumber);
    return result != null;
  }
}
