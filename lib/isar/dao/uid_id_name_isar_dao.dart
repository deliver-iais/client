import 'dart:async';

import 'package:clock/clock.dart';
import 'package:deliver/box/dao/isar_manager.dart';
import 'package:deliver/box/dao/uid_id_name_dao.dart';
import 'package:deliver/box/uid_id_name.dart';
import 'package:deliver/isar/helpers.dart';
import 'package:deliver/isar/uid_id_name_isar.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:isar/isar.dart';

class UidIdNameDaoImpl extends UidIdNameDao {
  @override
  Future<UidIdName?> getByUid(Uid uid) async {
    try {
      final box = await _openIsar();
      return (await box.uidIdNameIsars.get(fastHash(uid.asString())))
          ?.fromIsar();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<String?> getUidById(String id) async {
    try {
      final box = await _openIsar();
      return (await box.uidIdNameIsars.filter().idEqualTo(id).findFirst())?.uid;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<UidIdName>> search(String term) async {
    final box = await _openIsar();
    return (await box.uidIdNameIsars
            .filter()
            .nameContains(term, caseSensitive: false)
            .or()
            .idContains(term, caseSensitive: false)
            .findAll())
        .map((e) => e.fromIsar())
        .toList();
  }

  @override
  Future<void> update(
    Uid uid, {
    String? id,
    String? name,
    String? realName,
    bool? isContact,
  }) async {
    try {
      final lastUpdateTime = clock.now().millisecondsSinceEpoch;
      final box = await _openIsar();
      await box.writeTxn(() async {
        final uidName = (await box.uidIdNameIsars
                .filter()
                .uidEqualTo(uid.asString())
                .findFirst()) ??
            UidIdNameIsar(uid: uid.asString());
        await box.uidIdNameIsars.put(
          UidIdNameIsar(
            uid: uid.asString(),
            realName: realName ?? uidName.realName,
            name: name ?? uidName.name,
            id: id ?? uidName.id,
            isContact: isContact ?? uidName.isContact,
            lastUpdateTime: lastUpdateTime,
          ),
        );
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Stream<String?> watchIdByUid(Uid uid) async* {
    final box = await _openIsar();

    final query =
        box.uidIdNameIsars.filter().uidEqualTo(uid.asString()).build();
    yield (await query.findFirst())?.fromIsar().id;

    yield* query.watch().map((event) => event.firstOrNull?.fromIsar().id);
  }

  Future<Isar> _openIsar() => IsarManager.open();

  @override
  Future<List<UidIdName>> searchInContacts(String term) async {
    final box = await _openIsar();
    return (await box.uidIdNameIsars
            .filter()
            .isContactEqualTo(true)
            .and()
            .group(
              (q) => q
                  .nameContains(term, caseSensitive: false)
                  .or()
                  .idContains(term, caseSensitive: false),
            )
            .findAll())
        .map((e) => e.fromIsar())
        .toList();
  }
}
