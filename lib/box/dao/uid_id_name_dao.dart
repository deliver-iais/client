import 'package:clock/clock.dart';
import 'package:deliver/box/db_manager.dart';
import 'package:deliver/box/hive_plus.dart';
import 'package:deliver/box/uid_id_name.dart';
import 'package:hive/hive.dart';

abstract class UidIdNameDao {
  Future<UidIdName?> getByUid(String uid);

  Stream<String?> watchIdByUid(String uid);

  Future<String?> getUidById(String id);

  Future<void> update(String uid, {String? id, String? name});

  Future<List<UidIdName>> search(String term);
}

class UidIdNameDaoImpl extends UidIdNameDao {
  @override
  Future<UidIdName?> getByUid(String uid) async {
    final box = await _open();

    return box.get(uid);
  }

  @override
  Future<String?> getUidById(String id) async {
    final box = await _open2();

    return box.get(id);
  }

  @override
  Future<void> update(String uid, {String? id, String? name}) async {
    final lastUpdateTime = clock.now().millisecondsSinceEpoch;

    if (name != null) {
      name = name.trim();
    }

    final box = await _open();
    final box2 = await _open2();

    final byUid = box.get(uid);
    if (byUid == null) {
      await box.put(
        uid,
        UidIdName(uid: uid, id: id, name: name, lastUpdate: lastUpdateTime),
      );
    } else {
      await box.put(
        uid,
        byUid.copyWith(
          uid: uid,
          id: id,
          name: name,
          lastUpdate: lastUpdateTime,
        ),
      );
    }

    if (byUid != null && byUid.id != null && byUid.id != id) {
      await box2.delete(byUid.id);
    }

    if (id != null) {
      await box2.put(id, uid);
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
    return res;
  }

  @override
  Stream<String?> watchIdByUid(String uid) async* {
    final box = await _open();

    yield box.get(uid)?.id;

    yield* box.watch().map(
          (event) => box.get(uid)?.id,
        );
  }

  static String _key() => "uid-id-name";

  static String _key2() => "id-uid-name";

  Future<BoxPlus<UidIdName>> _open() {
    DBManager.open(_key(), TableInfo.UID_ID_NAME_TABLE_NAME);
    return gen(Hive.openBox<UidIdName>(_key()));
  }

  Future<BoxPlus<String>> _open2() {
    DBManager.open(_key2(), TableInfo.ID_UID_NAME_TABLE_NAME);
    return gen(Hive.openBox<String>(_key2()));
  }
}
