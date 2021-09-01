import 'package:we/box/uid_id_name.dart';
import 'package:hive/hive.dart';

abstract class UidIdNameDao {
  Future<UidIdName> getByUid(String uid);

  Future<String> getUidById(String id);

  Future<void> update(String uid, {String id, String name});

  Future<List<UidIdName>> search(String text);
}

class UidIdNameDaoImpl implements UidIdNameDao {
  Future<UidIdName> getByUid(String uid) async {
    var box = await _open();

    return box.get(uid);
  }

  Future<String> getUidById(String id) async {
    var box = await _open2();

    return box.get(id);
  }

  Future<void> update(String uid, {String id, String name}) async {
    var box = await _open();
    var box2 = await _open2();

    var byUid = box.get(uid);
    if (byUid == null) {
      box.put(uid, UidIdName(uid: uid, id: id, name: name));
    } else {
      box.put(uid, byUid.copyWith(uid: uid, id: id, name: name));
    }

    if (byUid != null && byUid.id != null && byUid.id != id) {
      box2.delete(byUid.id);
    }

    if (id != null) {
      box2.put(id, uid);
    }
  }

  static String _key() => "uid-id-name";

  static String _key2() => "id-uid-name";

  static Future<Box<UidIdName>> _open() => Hive.openBox<UidIdName>(_key());

  static Future<Box<String>> _open2() => Hive.openBox<String>(_key2());

  @override
  Future<List<UidIdName>> search(String term) async {
    var text = term.toLowerCase();
    var box = await _open();
    var res = box.values
        .where((element) =>
            (element.id != null &&
                element.id.toString().toLowerCase().contains(text)) ||
            (element.name != null && element.name.toLowerCase().contains(text)))
        .toList();
    return res;
  }
}
