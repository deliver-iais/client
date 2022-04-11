import 'package:deliver/box/box_info.dart';
import 'package:deliver/box/hive_plus.dart';
import 'package:hive/hive.dart';

abstract class CustomNotificationDao {
  Future<bool> isHaveCustomNotif(String uid);

  Future<void> setCustomNotif(String uid, String fileName);

  Future<String?> getCustomNotif(String uid);
}

class CustomNotificationDaoImpl implements CustomNotificationDao {
  static String _key() => "customnotification";

  static Future<BoxPlus<String>> _open() {
    BoxInfo.addBox(_key());
    return gen(Hive.openBox<String>(_key()));
  }

  @override
  Future<bool> isHaveCustomNotif(String uid) async {
    final box = await _open();
    if (box.get(uid) == null) {
      return false;
    } else {
      return true;
    }
  }

  @override
  Future<void> setCustomNotif(String uid, String fileName) async {
    final box = await _open();

    box.put(uid, fileName);
  }

  @override
  Future<String?> getCustomNotif(String uid) async {
    final box = await _open();
    if (box.get(uid) != null) {
      return box.get(uid);
    } else {
      return "-";
    }
  }
}
