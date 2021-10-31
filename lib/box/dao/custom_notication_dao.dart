import 'package:hive/hive.dart';

abstract class CustomNotificatonDao {
  Future<bool> isHaveCustomNotif(String uid);

  Future<void> setCustomNotif(String uid, String fileName);

  Future<String> getCustomNotif(String uid);
}

class CustomNotificatonDaoImpl implements CustomNotificatonDao {
  static String _key() => "customnotification";

  static Future<Box<String>> _open() => Hive.openBox<String>(_key());

  @override
  Future<bool> isHaveCustomNotif(String uid) async {
    var box = await _open();
    if (box.get(uid) == null)
      return false;
    else
      return true;
  }

  @override
  Future<void> setCustomNotif(String uid, String fileName) async {
    var box = await _open();

    box.put(uid, fileName);
  }

  @override
  Future<String> getCustomNotif(String uid) async {
    var box = await _open();
    if (box.get(uid) != null)
      return box.get(uid);
    else
      return "-";
  }
}
