import 'package:deliver/box/db_manage.dart';
import 'package:deliver/box/hive_plus.dart';
import 'package:deliver/box/last_activity.dart';
import 'package:hive/hive.dart';

abstract class LastActivityDao extends DBManager {
  Future<LastActivity?> get(String uid);

  Stream<LastActivity?> watch(String uid);

  Future<void> save(LastActivity lastActivity);
}

class LastActivityDaoImpl extends LastActivityDao {
  @override
  Future<LastActivity?> get(String uid) async {
    final box = await _open();

    return box.get(uid);
  }

  @override
  Stream<LastActivity?> watch(String uid) async* {
    final box = await _open();

    yield box.get(uid);

    yield* box.watch(key: uid).map((event) => box.get(uid));
  }

  @override
  Future<void> save(LastActivity lastActivity) async {
    final box = await _open();

    return box.put(lastActivity.uid, lastActivity);
  }

  static String _key() => "last-activity";

  Future<BoxPlus<LastActivity>> _open() {
    super.open(_key(), LAST_ACTIVITY_TABLE_NAME);
    return gen(Hive.openBox<LastActivity>(_key()));
  }
}
