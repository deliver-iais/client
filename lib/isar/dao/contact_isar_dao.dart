import 'dart:async';

import 'package:deliver/box/contact.dart';
import 'package:deliver/box/dao/contact_dao.dart';
import 'package:deliver/box/dao/isar_manager.dart';
import 'package:deliver/isar/contact_isar.dart';
import 'package:deliver/isar/helpers.dart';
import 'package:deliver/shared/extensions/phone_number_extention.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver_public_protocol/pub/v1/models/phone.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:isar/isar.dart';

class ContactDaoImpl extends ContactDao {
  @override
  Future<Contact?> get(PhoneNumber phoneNumber) async {
    final box = await _openIsar();
    return (await box.contactIsars.get(fastHash(phoneNumber.asString())))
        ?.fromIsar();
  }

  @override
  Future<List<Contact>> getAllContacts() async {
    final box = await _openIsar();
    return (await box.contactIsars.where().findAll())
        .map((e) => e.fromIsar())
        .toList();
  }

  @override
  Future<List<Contact>> getAllMessengerContacts() async {
    final box = await _openIsar();
    return (await box.contactIsars.filter().uidIsNotNull().findAll())
        .map((e) => e.fromIsar())
        .toList();
  }

  @override
  Future<Contact?> getByUid(Uid uid) async {
    final box = await _openIsar();
    return (await box.contactIsars
            .filter()
            .uidEqualTo(uid.asString())
            .findFirst())
        ?.fromIsar();
  }

  @override
  Future<List<Contact>> getNotMessengerContacts() async {
    final box = await _openIsar();
    return (await box.contactIsars.filter().uidIsNull().findAll())
        .map((e) => e.fromIsar())
        .toList();
  }

  @override
  Future<void> save({
    required PhoneNumber phoneNumber,
    String? firstName,
    String? lastName,
    String? uid,
    String? description,
    int? syncHash,
    int? updateTime,
  }) async {
    final box = await _openIsar();
    final c = (await box.contactIsars.get(fastHash(phoneNumber.asString()))) ??
        ContactIsar(phoneNumber: phoneNumber.asString());

    unawaited(box.writeTxn(
      () async => box.contactIsars.put(
        ContactIsar(
          phoneNumber: phoneNumber.asString(),
          firstName: firstName ?? c.firstName,
          lastName: lastName ?? c.lastName,
          description: description ?? c.description,
          syncHash: syncHash ?? c.syncHash,
          uid: uid ?? c.uid,
          updateTime: updateTime ?? c.updateTime,
        ),
      ),
    ));
  }

  @override
  Stream<List<Contact>> watchAll() async* {
    final box = await _openIsar();

    yield (await box.contactIsars.where().findAll())
        .map((e) => e.fromIsar())
        .toList();

    yield* box.contactIsars
        .where()
        .watch()
        .map((event) => event.map((e) => e.fromIsar()).toList());
  }

  @override
  Stream<List<Contact>> watchAllMessengerContacts() async* {
    final box = await _openIsar();
    final query = box.contactIsars.filter().uidIsNotNull().build();

    yield (await query.findAll()).map((e) => e.fromIsar()).toList();

    yield* query.watch().map(
          (event) => event.map((e) => e.fromIsar()).toList(),
        );
  }

  @override
  Stream<List<Contact>> watchNotMessengerContacts() async* {
    final box = await _openIsar();
    final query = box.contactIsars.filter().uidIsNull().build();

    yield (await query.findAll()).map((e) => e.fromIsar()).toList();

    yield* query.watch().map(
          (event) => event.map((e) => e.fromIsar()).toList(),
        );
  }

  Future<Isar> _openIsar() => IsarManager.open();
}
