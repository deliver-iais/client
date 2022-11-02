import 'package:deliver/box/db_manager.dart';
import 'package:deliver/box/hive_plus.dart';
import 'package:hive/hive.dart';

abstract class CustomNotificationDao extends DBManager {
  Future<bool> HaveCustomNotificationSound(String uid);

  Future<void> setCustomNotificationSound(String uid, String fileName);

  Stream<String?> watchCustomNotificationSound(String uid);

  Future<String?> getCustomNotificationSound(String uid);
}

class CustomNotificationDaoImpl extends CustomNotificationDao {
  static String _key() => "customNotification";

  Future<BoxPlus<String>> _open() {
    super.open(_key(), TableInfo.CUSTOM_NOTIFICATION_TABLE_NAME);
    return gen(Hive.openBox<String>(_key()));
  }

  @override
  Future<bool> HaveCustomNotificationSound(String uid) async {
    final box = await _open();
    if (box.get(uid) == null) {
      return false;
    } else {
      return true;
    }
  }

  @override
  Future<void> setCustomNotificationSound(String uid, String fileName) async {
    final box = await _open();

    return box.put(uid, fileName);
  }

  @override
  Future<String?> getCustomNotificationSound(String uid) async {
    final box = await _open();
    if (box.get(uid) != null) {
      return box.get(uid);
    } else {
      return "-";
    }
  }

  @override
  Stream<String?> watchCustomNotificationSound(String uid) async* {
    final box = await _open();
    yield box.get(uid) ?? "-";
    yield* box.watch(key: uid).map((event) => box.get(uid) ?? "-");
  }
}
