import 'package:deliver_flutter/box/uid_id_name.dart';
import 'package:hive/hive.dart';

abstract class UidIdNameDao {
  Future<UidIdName> getByUid(String uid);

  Future<UidIdName> getById(String id);

  Future<void> save(UidIdName uidIdName);
}

class UidIdNameDaoImpl implements UidIdNameDao {
  Future<UidIdName> getByUid(String uid) async {
    var box = await _open();

    return box.get(uid);
  }

  Future<UidIdName> getById(String id) async {
    var box = await _open2();

    return box.get(id);
  }

  Future<void> save(UidIdName uidIdName) async {
    var box = await _open();
    var box2 = await _open2();

    box.put(uidIdName.uid, uidIdName);
    box2.put(uidIdName.id, uidIdName);
  }

  static String _key() => "uid-id-name";

  static String _key2() => "id-uid-name";

  static Future<Box<UidIdName>> _open() => Hive.openBox<UidIdName>(_key());

  static Future<Box<UidIdName>> _open2() => Hive.openBox<UidIdName>(_key2());
}
