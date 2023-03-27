import 'dart:async';

import 'package:deliver/box/db_manager.dart';
import 'package:deliver/box/hive_plus.dart';
import 'package:hive/hive.dart';

abstract class ScrollPositionDao {
  Future<String?> get(String key);
  Future<void> put(String key, String value);
}

class ScrollPositionDaoImpl extends ScrollPositionDao {
  @override
  Future<String?> get(String key) async {
    final box = await _open();

    return box.get(key);
  }

  @override
  Future<void> put(String key, String value) async {
    final box = await _open();

    return box.put(key, value);
  }

  static String _key() => "scroll_position";

  Future<BoxPlus> _open() {
    DBManager.open(_key(), TableInfo.SCROLL_POSITION_TABLE_NAME);
    return gen(Hive.openBox(_key()));
  }
}
