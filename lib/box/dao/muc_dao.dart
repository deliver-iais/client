import 'package:deliver_flutter/box/muc.dart';
import 'package:hive/hive.dart';

abstract class MucDao {
  Future<Muc> get(String uid);

  Stream<Muc> watch(String uid);

  Future<void> save(Muc muc);

  Future<void> update(Muc muc);

  Future<void> delete(String uid);
}

class MucDaoImpl implements MucDao {
  Future<void> delete(String uid) async {
    var box = await _open();

    box.delete(uid);
  }

  Future<Muc> get(String uid) async {
    var box = await _open();

    return box.get(uid);
  }

  Future<void> save(Muc muc) async {
    var box = await _open();

    return box.put(muc.uid, muc);
  }

  Future<void> update(Muc muc) async {
    var box = await _open();

    var m = box.get(muc.uid) ?? Muc();

    return box.put(muc.uid, m.copy(muc));
  }

  @override
  Stream<Muc> watch(String uid) async* {
    var box = await _open();

    yield box.get(uid);

    yield* box.watch(key: uid).map((event) => box.get(uid));
  }

  static String _key() => "muc";

  static Future<Box<Muc>> _open() => Hive.openBox<Muc>(_key());
}
