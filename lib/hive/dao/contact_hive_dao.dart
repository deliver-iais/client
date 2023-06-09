import 'package:deliver/box/contact.dart';
import 'package:deliver/box/dao/contact_dao.dart';
import 'package:deliver/box/db_manager.dart';
import 'package:deliver/box/hive_plus.dart';
import 'package:deliver/hive/contact_hive.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver_public_protocol/pub/v1/models/phone.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:hive/hive.dart';

class ContactDaoImpl extends ContactDao {
  @override
  Future<Contact?> get(PhoneNumber phoneNumber) async {
    final box = await _open();

    try {
      box.values.firstWhere(
        (element) =>
            element.countryCode == phoneNumber.countryCode &&
            element.nationalNumber == phoneNumber.nationalNumber.toInt(),
      );
    } catch (e) {
      return null;
    }
    return null;
  }

  @override
  Future<Contact?> getByUid(Uid uid) async {
    try {
      final box = await _open();

      return box.values
          .where(
              (element) => element.uid != null && element.uid == uid.asString(),)
          .first
          .fromHive();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Contact>> getAllContacts() async {
    final box = await _open();

    return box.values.map((e) => e.fromHive()).toList();
  }

  @override
  Future<List<Contact>> getAllMessengerContacts() async {
    final box = await _open();
    return box.values
        .where((element) => element.uid != null)
        .map((e) => e.fromHive())
        .toList();
  }

  @override
  Stream<List<Contact>> watchAllMessengerContacts() async* {
    final box = await _open();

    yield box.values
        .where((element) => element.uid != null)
        .map((e) => e.fromHive())
        .toList();

    yield* box.watch().map(
          (event) => box.values
              .where((element) => element.uid != null)
              .map((e) => e.fromHive())
              .toList(),
        );
  }

  static String _key() => "contact";

  Future<BoxPlus<ContactHive>> _open() {
    DBManager.open(_key(), TableInfo.CONTACT_TABLE_NAME);
    return gen(Hive.openBox<ContactHive>(_key()));
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
    final box = await _open();

    final clone = box.get(phoneNumber.nationalNumber.toString()) ??
        ContactHive(
            countryCode: phoneNumber.countryCode,
            nationalNumber: phoneNumber.nationalNumber.toInt(),);

    final c = clone.copyWith(
      nationalNumber: phoneNumber.nationalNumber.toInt(),
      countryCode: phoneNumber.countryCode,
      firstName: firstName,
      lastName: lastName,
      description: description,
      updateTime: updateTime,
      uid: uid,
      syncHash: syncHash,
    );
    if (c != clone) {
      return box.put(phoneNumber.nationalNumber.toString(), c);
    }
  }

  @override
  Future<List<Contact>> getNotMessengerContacts() async {
    try {
      final box = await _open();
      return box.values
          .where((element) => element.uid == null)
          .map((e) => e.fromHive())
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Stream<List<Contact>> watchNotMessengerContacts() async* {
    final box = await _open();

    yield box.values
        .where((element) => element.uid == null)
        .map((e) => e.fromHive())
        .toList();

    yield* box.watch().map(
          (event) => box.values
              .where((element) => element.uid == null)
              .map((e) => e.fromHive())
              .toList(),
        );
  }

  @override
  Stream<List<Contact>> watchAll() async* {
    try {
      final box = await _open();

      yield box.values.map((e) => e.fromHive()).toList();

      yield* box.watch().map(
            (event) => box.values.map((e) => e.fromHive()).toList(),
          );
    } catch (_) {
      yield [];
    }
  }
}
