import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:logger/logger.dart';

class BoxInfo {
  static Future<void> addBox(String key) async {
    try {
      final box = await Hive.openBox<String>(_key());
      return box.put(key, key);
    } catch (_) {
      //  _logger.e(e);
    }
  }

  static Future<void> deleteBox(String key) async {
    try {
      return Hive.deleteBoxFromDisk(key);
    } catch (e) {
      GetIt.I.get<Logger>().e(e);
    }
  }

  static String _key() => "box_info";

  static Future<void> deleteAllBox({bool deleteSharedDao = true}) async {
    final box = await Hive.openBox<String>(_key());
    box.values.toList().forEach((key) async {
      if (deleteSharedDao || key != 'shared') {
        await deleteBox(key);
      }
    });
    return deleteBox(_key());
  }
}
