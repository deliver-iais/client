import 'dart:async';

import 'package:deliver/box/db_manager.dart';
import 'package:deliver/box/hive_plus.dart';
import 'package:deliver/shared/constants.dart';
import 'package:hive/hive.dart';

abstract class SharedDao {
  Future<String?> get(SharedKeys key);

  Future<void> put(SharedKeys key, String value);
}

class SharedDaoImpl extends SharedDao {
  @override
  Future<String?> get(SharedKeys key) async {
    final box = await _open();

    return box.get(key.name);
  }

  @override
  Future<void> put(SharedKeys key, String value) async {
    final box = await _open();

    return box.put(key.name, value);
  }

  static String _key() => "shared";

  Future<BoxPlus> _open() {
    DBManager.open(_key(), TableInfo.SHARED_TABLE_NAME);
    return gen(Hive.openBox(_key()));
  }
}
