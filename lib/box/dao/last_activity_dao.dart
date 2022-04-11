import 'package:deliver/box/box_info.dart';
import 'package:deliver/box/hive_plus.dart';
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

    box.put(lastActivity.uid, lastActivity);
  }

  static String _key() => "last-activity";

  static Future<BoxPlus<LastActivity>> _open() {
    BoxInfo.addBox(_key());
    return gen(Hive.openBox<LastActivity>(_key()));
  }
}
