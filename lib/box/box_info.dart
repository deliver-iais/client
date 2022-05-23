import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:logger/logger.dart';

class BoxInfo {
  static final Logger _logger = GetIt.I.get<Logger>();

  static Future<void> addBox(String key) async {
    try {
      final box = await Hive.openBox<String>(_key());
      return box.put(key, key);
    } catch (_) {
      //  _logger.e(e);
    }
  }

  static Future<void> _deleteBox(String key) async {
    try {
      return Hive.deleteBoxFromDisk(key);
    } catch (e) {
      _logger.e(e);
    }
  }

  static String _key() => "box_info";

  static Future<void> deleteAllBox({bool deleteSharedDao=true}) async {
    final box = await Hive.openBox<String>(_key());
    box.values.toList().forEach((key) async {
      if(deleteSharedDao || key != 'shared') {
        await _deleteBox(key);
      }
    });
    return _deleteBox(_key());
  }
}
