// TODO(any): change file name
// ignore_for_file: file_names

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:deliver/box/uid_id_name.dart';
import 'package:collection/collection.dart';
import 'package:deliver/box/contact.dart' as contact_model;
import 'package:deliver/box/dao/contact_dao.dart';
import 'package:deliver/box/dao/room_dao.dart';
import 'package:deliver/box/dao/uid_id_name_dao.dart';
import 'package:deliver/box/member.dart';
import 'package:deliver/repository/caching_repo.dart';
import 'package:deliver/repository/servicesDiscoveryRepo.dart';
import 'package:deliver/services/analytics_service.dart';
import 'package:deliver/services/check_permissions_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/string_extension.dart';
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
import 'package:fast_contacts/fast_contacts.dart' as fast_contact;
import 'package:file_picker/file_picker.dart';
import 'package:file_selector/file_selector.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
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
  final _analyticsService = GetIt.I.get<AnalyticsService>();
  final _cachingRepo = GetIt.I.get<CachingRepo>();
  final _requestLock = Lock();
  final BehaviorSubject<bool> isSyncingContacts = BehaviorSubject.seeded(false);
  final BehaviorSubject<double> sendContactProgress = BehaviorSubject.seeded(0);
  bool hasContactPermission = false;
  var _syncedContacts = <Contact>[];

  Future<void> syncContacts(BuildContext? context) async {
    if (_requestLock.locked) {
      return;
    }
    return _requestLock.synchronized(() async {
      final hasPermission = !hasContactCapability ||
          isIOSNative ||
          await _checkPermission.checkContactPermission(context: context);
      if (hasPermission) {
        if (hasContactCapability) {
          _syncedContacts = [];
          hasContactPermission = true;
          final phoneContacts = await fast_contact.FastContacts.getAllContacts(
            fields: [
              fast_contact.ContactField.displayName,
              fast_contact.ContactField.phoneNumbers
            ],
            batchSize: 100,
          );
          final contacts = await _filterPhoneContactsToSend(
            phoneContacts
                .map(
                  (p) => (p.phones.map((e) => e.number))
                      .toSet()
                      .map((phone) => _getPhoneNumber(phone))
                      .whereNotNull()
                      .map(
                        (e) => Contact()
                          ..firstName = p.displayName
                          ..phoneNumber = e,
                      ),
                )
                .expand((e) => e)
                .groupFoldBy<int, Contact>(
                  (element) => element.phoneNumber.nationalNumber.toInt(),
                  (previous, element) => element,
                )
                .values
                .toSet()
                .toList(),
          );

          if (contacts.isNotEmpty) {
            isSyncingContacts.add(true);
            await sendContacts(contacts);
            unawaited(getContacts());
            await _savePhoneContacts(
              contacts,
            );
            unawaited(sendNotSyncedContactInStartTime());
          } else {
            sendContactProgress.add(1);
            unawaited(getContacts());
          }
        } else {
          unawaited(getContacts());
        }
      }
    });
  }

  Future<void> _savePhoneContacts(List<Contact> contacts) async {
    for (final element in contacts) {
      try {
        await _contactDao.save(
          phoneNumber: element.phoneNumber,
          updateTime: _syncedContacts.contains(element)
              ? DateTime.now().millisecondsSinceEpoch
              : null,
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
    final contacts = await _contactDao.getAllContacts();

    for (final element in contacts) {
      phoneContacts.removeWhere(
        (pc) => (element.phoneNumber.nationalNumber.toInt() ==
                pc.phoneNumber.nationalNumber.toInt() &&
            ((element.uid != null &&
                    _contactHash(
                          name: pc.firstName,
                          nationalNumber: pc.phoneNumber.nationalNumber.toInt(),
                        ) ==
                        element.syncHash) ||
                (element.uid == null && element.updateTime > 0))),
      );
    }
    return phoneContacts;
  }

  int _contactHash({required String name, required int nationalNumber}) =>
      const DeepCollectionEquality().hash("$name$nationalNumber");

  Future<void> sendNotSyncedContactInStartTime() async {
    _syncedContacts = [];
    final contacts = await _contactDao.getNotMessengerContacts();
    if (contacts.isNotEmpty) {
      final filteredContacts = contacts
          .where(
            (element) => ((element.updateTime == 0)),
          )
          .toList()
          .map(
            (e) => Contact(
              phoneNumber: PhoneNumber(
                countryCode: e.phoneNumber.countryCode,
                nationalNumber: Int64(e.phoneNumber.nationalNumber.toInt()),
              ),
              firstName: e.firstName,
            ),
          )
          .toList();
      unawaited(
        sendContacts(filteredContacts, initProgressbar: false),
      );
      unawaited(_savePhoneContacts(filteredContacts));
    }
  }

  PhoneNumber? _getPhoneNumber(String phone) {
    final regex = RegExp(r'^[\u0600-\u06FF\s]+$');
    if (regex.hasMatch(phone)) {
      phone = phone.replaceFarsiNumber();
    }
    final p = getPhoneNumber(phone);

    if (p == null) {
      // _logger.e("Not Valid Number  $name ***** $phone");
      return null;
    } else {
      return p;
    }
  }

  Future<void> sendContacts(
    List<Contact> contacts, {
    bool initProgressbar = true,
  }) async {
    try {
      var i = 0;
      while (i <= contacts.length) {
        try {
          final end = contacts.length > i + MAX_CONTACT_SIZE_TO_SEND - 1
              ? i + MAX_CONTACT_SIZE_TO_SEND - 1
              : contacts.length;
          final contactsSubList = contacts.sublist(
            i,
            end,
          );
          if (initProgressbar) {
            sendContactProgress.add(end / contacts.length);
          }
          await _sendContacts(contactsSubList);
          i = i + MAX_CONTACT_SIZE_TO_SEND;
        } catch (e) {
          _logger.e(e);
          isSyncingContacts.add(false);
        }
      }
    } catch (e) {
      _logger.e(e);
    }
  }

  Future<String?> sendNewContact(Contact contact) async {
    try {
      final res = await _sdr.contactServiceClient.saveContacts(
        SaveContactsReq()
          ..contactList.add(contact)
          ..returnUserContactByPhoneNumberList.add(contact.phoneNumber),
      );
      _saveUserContact(res.userList);
      return res.userList.isNotEmpty ? res.userList.last.uid.asString() : null;
    } catch (e) {
      _logger.e(e);
      return null;
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
      _syncedContacts.addAll(contacts);
      return true;
    } catch (e) {
      _logger.e(e);
      // TODO(bitbeter): سینک شدن ادامه داره ولی چون ارور خوردیم میخواستیم لودینگ رو دیگه نشون ندیم ولی شاید این متغیر یه جای دیگه استفاده بشه که فالس کردنش باگ ایجاد کنه
      isSyncingContacts.add(false);
      return false;
    }
  }

  Stream<List<contact_model.Contact>> watchAllMessengerContacts() =>
      _contactDao.watchAllMessengerContacts();

  Future<List<contact_model.Contact>> getAllUserAsContact() =>
      _contactDao.getAllMessengerContacts();

  Future<List<contact_model.Contact>> getNotMessengerContacts() =>
      _contactDao.getNotMessengerContacts();

  Stream<List<contact_model.Contact>> watchNotMessengerContact() =>
      _contactDao.watchNotMessengerContacts();

  Stream<List<contact_model.Contact>> watchAll() => _contactDao.watchAll();

  Future<void> getContacts() async {
    isSyncingContacts.add(false);
    try {
      final result = await _sdr.contactServiceClient
          .getContactListUsers(GetContactListUsersReq());
      _saveUserContact(result.userList);
    } catch (e) {
      _logger.e(e);
    }
  }

  void _saveUserContact(List<UserAsContact> users) {
    for (final contact in users) {
      _contactDao.save(
        uid: contact.uid.asString(),
        phoneNumber: contact.phoneNumber,
        firstName: contact.firstName,
        lastName: contact.lastName,
        description: contact.description,
        syncHash: _contactHash(
          name: contact.firstName,
          nationalNumber: contact.phoneNumber.nationalNumber.toInt(),
        ),
      );

      _cachingRepo
        ..setName(
          contact.uid,
          buildName(contact.firstName, contact.lastName),
        )
        ..setRealName(
          contact.uid,
          buildName(contact.realFirstName, contact.realLastName),
        );
      _uidIdNameDao.update(
        contact.uid,
        isContact: true,
        realName: buildName(contact.realFirstName, contact.realLastName),
        name: buildName(contact.firstName, contact.lastName),
      );
      _roomDao.updateRoom(uid: contact.uid);
    }
  }

  Future<void> getUserIdByUid(Uid uid) async {
    try {
      // For now, Group and Bot not supported in server side!!
      final result =
          await _sdr.queryServiceClient.getIdByUid(GetIdByUidReq()..uid = uid);
      return _uidIdNameDao.update(
        uid,
        id: result.id,
        isContact: true,
      );
    } catch (e) {
      _logger.e(e);
    }
  }

  Future<void> fetchMemberId(Member member) async {
    if (!member.memberUid.isUser()) {
      return;
    }
    final m = await _uidIdNameDao.getByUid(member.memberUid);
    if (m == null || m.id == null) {
      return getUserIdByUid(member.memberUid);
    }
  }

  Future<List<UidIdName>> searchUser(String query) async {
    await _analyticsService.sendLogEvent(
      "globalSearchUser",
      parameters: {"term": query},
    );
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
      final searchResult = <UidIdName>[];
      for (final room in result.itemList) {
        searchResult
            .add(UidIdName(uid: room.uid, id: room.id, name: room.name));
      }
      return searchResult;
    } catch (e) {
      _logger.e(e);
      return [];
    }
  }

// TODO(hasan): we should merge getContact and getContactFromServer functions together and refactor usages too, https://gitlab.iais.co/deliver/wiki/-/issues/421
  Future<contact_model.Contact?> getContact(Uid userUid) =>
      _contactDao.getByUid(userUid);

  Future<({String? name, String? realName})> getContactFromServer(
    Uid contactUid, {
    bool ignoreInsertingOrUpdatingContactDao = false,
  }) async {
    try {
      final contact = await _sdr.contactServiceClient
          .getUserByUid(GetUserByUidReq()..uid = contactUid);
      final name = buildName(contact.user.firstName, contact.user.lastName);
      final realName =
          buildName(contact.user.realFirstName, contact.user.realLastName);

      // Update uidIdName table
      unawaited(
        _uidIdNameDao.update(
          contactUid,
          name: name,
          realName: realName,
        ),
      );
      _cachingRepo
        ..setName(contactUid, name)
        ..setRealName(contactUid, realName);
      if (!ignoreInsertingOrUpdatingContactDao) {
        // Update contact table
        unawaited(
          _contactDao.save(
            uid: contactUid.asString(),
            phoneNumber: contact.user.phoneNumber,
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
      return (name: name, realName: realName);
    } catch (e) {
      _logger.e(e);
      return (name: null, realName: null);
    }
  }

  Future<bool> contactIsExist(int countryCode, int nationalNumber) async {
    final result = await _contactDao.get(
      PhoneNumber()
        ..countryCode = countryCode
        ..nationalNumber = Int64(nationalNumber),
    );
    return result != null;
  }

  Future<void> importContactsFormVcard() async {
    try {
      if (isLinuxNative) {
        final typeGroup = <XTypeGroup>[
          const XTypeGroup(mimeTypes: ["vcf"])
        ];
        final result = await openFiles(acceptedTypeGroups: typeGroup);
        if (result.isNotEmpty) {
          unawaited(
            _getContactFromVcfFile(
              File(result.first.path).readAsStringSync(),
            ),
          );
        }
      } else {
        final result = await FilePicker.platform
            .pickFiles(type: FileType.custom, allowedExtensions: ["vcf"]);
        if (result != null && result.files.isNotEmpty) {
          if (isWeb) {
            unawaited(
              _getContactFromVcfFile(
                String.fromCharCodes(
                  result.files.first.bytes!,
                ),
              ),
            );
          } else {
            unawaited(
              _getContactFromVcfFile(
                File(result.files.first.path!).readAsStringSync(),
              ),
            );
          }
        }
      }
    } catch (e) {
      _logger.d(e.toString());
    }
  }

  Future<void> _getContactFromVcfFile(String contactsValue) async {
    try {
      final phoneContacts = <Contact>[];
      for (final contactInfo in contactsValue.split("BEGIN:VCARD")) {
        try {
          final tags = {};
          for (final contact in contactInfo.split("\n")) {
            try {
              final param = contact.replaceAll(";", "").split(":");
              if (param.length > 1) {
                if (param[0].contains("TEL")) {
                  tags["TEL"] = param[1];
                } else if (param[0].contains("FN")) {
                  tags["NAME"] = utf8.decode(
                    _decodeQuotedPrintable(param[1]).runes.toList(),
                  );
                }
              }
            } catch (_) {}
          }
          if (tags.isNotEmpty && tags["TEL"] != null && tags["NAME"] != null) {
            final phone = _getPhoneNumber(tags["TEL"]);
            if (phone != null) {
              phoneContacts.add(
                Contact()
                  ..firstName = tags["NAME"]
                  ..phoneNumber = phone,
              );
            }
          }
        } catch (_) {}
      }

      final contacts = await _filterPhoneContactsToSend(phoneContacts);
      if (contacts.isNotEmpty) {
        isSyncingContacts.add(true);
        await sendContacts(contacts);
        unawaited(_savePhoneContacts(contacts));
        isSyncingContacts.add(false);
      }
    } catch (e) {
      _logger.e(e);
    }
  }

  String _decodeQuotedPrintable(String input) {
    return input
        .replaceAll(RegExp(r'[\t\x20]$', multiLine: true), '')
        .replaceAll(RegExp(r'=(?:\r\n?|\n|$)', multiLine: true), '')
        .replaceAllMapped(RegExp(r'=([a-fA-F\d]{2})'), (match) {
      return String.fromCharCode(int.parse(match[1] ?? "", radix: 16));
    });
  }
}
