import 'package:deliver/box/bot_info.dart';
import 'package:deliver/box/db_manager.dart';
import 'package:deliver/box/hive_plus.dart';
import 'package:hive/hive.dart';

abstract class BotDao {
  Future<BotInfo?> get(String uid);

  Future<void> save(BotInfo botInfo);
}

class BotDaoImpl extends BotDao {
  @override
  Future<BotInfo?> get(String uid) async {
    final box = await _open();

    return box.get(uid);
  }

  @override
  Future<void> save(BotInfo botInfo) async {
    final box = await _open();

    return box.put(botInfo.uid, botInfo);
  }

  static String _key() => "bot";

  Future<BoxPlus<BotInfo>> _open() {
    DBManager.open(_key(), TableInfo.BOT_INFO_TABLE_NAME);
    return gen(Hive.openBox<BotInfo>(_key()));
  }
}
