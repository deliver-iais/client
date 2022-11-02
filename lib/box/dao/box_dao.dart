import 'package:deliver/box/box_info.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:logger/logger.dart';

class BoxDao {
  static Future<void> addBox(String key, BoxInfo boxInfo) async {
    try {
      final box = await Hive.openBox<BoxInfo>(_key());
      return box.put(key, boxInfo);
    } catch (_) {}
  }

  static Future<void> deleteBox(String key) async {
    try {
      return Hive.deleteBoxFromDisk(key);
    } catch (e) {
      GetIt.I.get<Logger>().e(e);
    }
  }

  static Future<List<BoxInfo>> getAll() async {
    try {
      final box = await Hive.openBox<BoxInfo>(_key());
      return box.values.toList();
    } catch (_) {
      return [];
    }
  }

  static String _key() => "box_information";

  static String _oldKey() => "box_info";

  static Future<void> deleteAllBox({bool deleteSharedDao = true}) async {
    final box = await Hive.openBox<BoxInfo>(_key());
    box.values.toList().forEach((boxInfo) async {
      if (deleteSharedDao || boxInfo.dbKey != 'shared') {
        await deleteBox(boxInfo.dbKey);
      }
    });
    return deleteBox(_key());
  }

  static Future<void> removeOldDb({bool deleteSharedDao = true}) async {
    final box = await Hive.openBox<String>(_oldKey());
    box.values.toList().forEach((key) async {
      if (deleteSharedDao || key != 'shared') {
        await deleteBox(key);
      }
    });
    return deleteBox(_key());
  }
}
