import 'package:deliver_flutter/db/Avatars.dart';
import 'package:deliver_flutter/db/BotInfos.dart';
import 'package:moor/moor.dart';
import '../database.dart';

part 'BotInfoDao.g.dart';

@UseDao(tables: [BotInfos])
class BotInfoDao extends DatabaseAccessor<Database> with _$BotInfoDaoMixin {
  final Database database;

  BotInfoDao(this.database) : super(database);
  
  Future saveBotInfo(BotInfo botInfo){
    into(botInfos).insertOnConflictUpdate(botInfo);
  }
  
  Future<BotInfo> getBotInfo(String username){
    return(select(botInfos)..where((botInfo) => botInfo.username.contains(username) )).getSingleOrNull();
  }


}
