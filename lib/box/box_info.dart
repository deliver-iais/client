import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:logger/logger.dart';

class BoxInfo {
  static final Logger _logger = GetIt.I.get<Logger>();

  static addBox(String key) async {
    try{
      var box = await Hive.openBox<String>(_key());
      box.put(key, key);
    }catch(e){
      _logger.e(e);
    }

  }

  static _deleteBox(String key) async {
    try {
      await Hive.deleteBoxFromDisk(key);
    } catch (e) {
      _logger.e(e);
    }
  }

  static String _key() => "box_info";

  static deleteAllBox() async {
    var box = await Hive.openBox<String>(_key());
    box.values.toList().forEach((key) async {
      await _deleteBox(key);
    });
    _deleteBox(_key());
  }
}
