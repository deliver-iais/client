import 'package:deliver/box/bot_info.dart';
import 'package:deliver/box/box_info.dart';
import 'package:hive/hive.dart';

abstract class BotDao {
  Future<BotInfo?> get(String uid);

  Future<void> save(BotInfo uid);
}

class BotDaoImpl implements BotDao {
  @override
  Future<BotInfo?> get(String uid) async {
    var box = await _open();

    return box.get(uid);
  }

  @override
  Future<void> save(BotInfo botInfo) async {
    var box = await _open();

    box.put(botInfo.uid, botInfo);
  }

  static String _key() => "bot";

  static Future<Box<BotInfo>> _open() {
    BoxInfo.addBox(_key());
    return Hive.openBox<BotInfo>(_key());
  }
}
