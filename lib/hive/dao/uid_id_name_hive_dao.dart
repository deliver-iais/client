import 'package:clock/clock.dart';
import 'package:deliver/box/dao/uid_id_name_dao.dart';
import 'package:deliver/box/db_manager.dart';
import 'package:deliver/box/hive_plus.dart';
import 'package:deliver/box/uid_id_name.dart';
import 'package:deliver/hive/uid_id_name_hive.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:hive_flutter/adapters.dart';

class UidIdNameDaoImpl extends UidIdNameDao {
  @override
  Future<UidIdName?> getByUid(Uid uid) async {
    final box = await _open();

    return box.get(uid.asString())?.fromHive();
  }

  @override
  Future<String?> getUidById(String id) async {
    final box = await _open2();

    return box.get(id);
  }

  @override
  Future<void> update(
    Uid uid, {
    String? id,
    String? name,
    String? realName,
    bool? isContact,
  }) async {
    final lastUpdateTime = clock.now().millisecondsSinceEpoch;

    if (name != null) {
      name = name.trim();
    }

    final box = await _open();
    final box2 = await _open2();

    final byUid = box.get(uid.asString());
    if (byUid == null) {
      await box.put(
        uid.asString(),
        UidIdNameHive(
          uid: uid.asString(),
          id: id,
          name: name,
          isContact: isContact ?? false,
          realName: realName,
          lastUpdate: lastUpdateTime,
        ),
      );
    } else {
      await box.put(
        uid.asString(),
        byUid.copyWith(
          uid: uid.asString(),
          id: id,
          isContact: isContact ?? false,
          realName: realName,
          name: name,
          lastUpdate: lastUpdateTime,
        ),
      );
    }

    if (byUid != null && byUid.id != null && byUid.id != id) {
      await box2.delete(byUid.id);
    }

    if (id != null) {
      await box2.put(id, uid.asString());
    }
  }

  @override
  Future<List<UidIdName>> search(String term) async {
    final text = term.toLowerCase();
    final box = await _open();
    final res = box.values
        .where(
          (element) =>
              (element.id != null &&
                  element.id.toString().toLowerCase().contains(text)) ||
              (element.name != null &&
                  element.name!.toLowerCase().contains(text)),
        )
        .toList();
    return res.map((e) => e.fromHive()).toList();
  }

  @override
  Stream<String?> watchIdByUid(Uid uid) async* {
    final box = await _open();

    yield box.get(uid.asString())?.id;

    yield* box.watch().map(
          (event) => box.get(uid.asString())?.id,
        );
  }

  static String _key() => "uid-id-name";

  static String _key2() => "id-uid-name";

  Future<BoxPlus<UidIdNameHive>> _open() {
    DBManager.open(_key(), TableInfo.UID_ID_NAME_TABLE_NAME);
    return gen(Hive.openBox<UidIdNameHive>(_key()));
  }

  Future<BoxPlus<String>> _open2() {
    DBManager.open(_key2(), TableInfo.ID_UID_NAME_TABLE_NAME);
    return gen(Hive.openBox<String>(_key2()));
  }

  @override
  Future<List<UidIdName>> searchInContacts(String term) async {
    final text = term.toLowerCase();
    final box = await _open();
    final res = box.values
        .where(
          (element) =>
              element.isContact &&
              ((element.id != null &&
                      element.id.toString().toLowerCase().contains(text)) ||
                  (element.name != null &&
                      element.name!.toLowerCase().contains(text))),
        )
        .toList();
    return res.map((e) => e.fromHive()).toList();
  }
}
