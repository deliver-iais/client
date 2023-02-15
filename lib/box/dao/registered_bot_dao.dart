import 'dart:async';

import 'package:deliver/box/db_manager.dart';
import 'package:deliver/box/hive_plus.dart';

import 'package:hive/hive.dart';

abstract class RegisteredBotDao {
  Future<bool> botIsRegistered(String botUid);

  Future<void> saveRegisteredBot(String botUid);
}

class RegisteredBotDaoImpl extends RegisteredBotDao {
  static String _key() => "registered_bot";

  Future<BoxPlus<String>> _open() async {
    try {
      DBManager.open(_key(), TableInfo.REGISTERED_BOT_TABLE_NAME);
      return gen(Hive.openBox<String>(_key()));
    } catch (e) {
      await Hive.deleteBoxFromDisk(_key());
      return gen(Hive.openBox<String>(_key()));
    }
  }

  @override
  Future<bool> botIsRegistered(String botUid) async =>
      (await _open()).get(botUid) != null;

  @override
  Future<void> saveRegisteredBot(String botUid) async =>
      (await _open()).put(botUid, botUid);
}
