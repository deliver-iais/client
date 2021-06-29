import 'package:deliver_flutter/box/last_activity.dart';
import 'package:hive/hive.dart';

abstract class LastActivityDao {
  Future<LastActivity> get(String uid);

  Future<void> save(LastActivity lastActivity);
}

class LastActivityDaoImpl implements LastActivityDao {
  Future<LastActivity> get(String uid) async {
    var box = await _open();

    return box.get(uid);
  }

  Future<void> save(LastActivity lastActivity) async {
    var box = await _open();

    box.put(lastActivity.uid, lastActivity);
  }

  static String _key() => "last-activity";

  static Future<Box<LastActivity>> _open() =>
      Hive.openBox<LastActivity>(_key());
}
