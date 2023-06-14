import 'package:deliver/box/box_info.dart';
import 'package:deliver/box/db_manager.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:idb_shim/idb_browser.dart';
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
      if (isWeb) {
        final box = await Hive.openBox(key);
        return box.deleteFromDisk();
      } else {
        return Hive.deleteBoxFromDisk(key);
      }
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
      if (deleteSharedDao ||
          boxInfo.dbKey != TableInfo.SHARED_TABLE_NAME.name) {
        await deleteBox(boxInfo.dbKey);
      }
    });
    return deleteBox(_key());
  }

  static Future<void> deleteAllBoxNativeInWeb({
    bool deleteSharedDao = true,
  }) async {
    final idbFactory = getIdbFactory();
    final box = await Hive.openBox<BoxInfo>(_key());
    box.values.toList().forEach((boxInfo) async {
      await idbFactory?.deleteDatabase(boxInfo.dbKey);
    });

    await idbFactory?.deleteDatabase(_key());
  }

  static Future<void> removeOldDb() async {
    final box = await Hive.openBox<String>(_oldKey());
    box.values.toList().forEach((key) async {
      await deleteBox(key);
    });
    return deleteBox(_key());
  }
}
