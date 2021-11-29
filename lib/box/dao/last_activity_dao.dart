import 'package:deliver/box/last_activity.dart';
import 'package:hive/hive.dart';

abstract class LastActivityDao {
  Future<LastActivity?> get(String uid);

  Stream<LastActivity?> watch(String uid);

  Future<void> save(LastActivity lastActivity);
}

class LastActivityDaoImpl implements LastActivityDao {
  @override
  Future<LastActivity?> get(String uid) async {
    var box = await _open();

    return box.get(uid);
  }

  @override
  Stream<LastActivity?> watch(String uid) async* {
    var box = await _open();

    yield box.get(uid);

    yield* box.watch(key: uid).map((event) => box.get(uid));
  }

  @override
  Future<void> save(LastActivity lastActivity) async {
    var box = await _open();

    box.put(lastActivity.uid, lastActivity);
  }

  static String _key() => "last-activity";

  static Future<Box<LastActivity>> _open() =>
      Hive.openBox<LastActivity>(_key());
}
