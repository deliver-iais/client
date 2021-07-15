import 'package:deliver_flutter/box/bot_info.dart';
import 'package:deliver_flutter/box/dao/bot_dao.dart';

import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_public_protocol/pub/v1/bot.pbgrpc.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';
import 'package:get_it/get_it.dart';
import 'package:grpc/grpc.dart';
import 'package:logger/logger.dart';

class BotRepo {
  final _logger = Logger();
  final _botServiceClient = GetIt.I.get<BotServiceClient>();
  final _accountRepo = GetIt.I.get<AccountRepo>();
  final _botDao = GetIt.I.get<BotDao>();

  Future<BotInfo> fetchBotInfo(Uid botUid) async {
    var result = await _botServiceClient.getInfo(GetInfoReq()..bot = botUid,
        options: CallOptions(
            metadata: {"access_token": await _accountRepo.getAccessToken()}));

    var botInfo = BotInfo(
        description: result.description,
        uid: botUid.asString(),
        name: result.name,
        commands: result.commands);

    _botDao.save(botInfo);

    return botInfo;
  }

  Future<BotInfo> getBotInfo(Uid botUid) async {
    var botInfo = await _botDao.get(botUid.asString());
    // TODO add lastUpdate field in model and check it later in here!
    if (botInfo != null) {
      return botInfo;
    }

    return fetchBotInfo(botUid);
  }

  Future<List<Uid>> searchBotByName(String name) async {
    //Todo complete search in bot
    // var result = await _botServiceClient.searchByName(SearchByNameReq()..name = name,options: CallOptions(
    //  metadata: {"access_token" : await _accountRepo.getAccessToken()},timeout: Duration(seconds: 2)
    // ));
    List<Uid> searchInBots = [];
    if (name.contains("father")) {
      Uid uid = Uid();
      uid.category = Categories.BOT;
      uid.node = "father_bot";
      searchInBots.add(uid);
    }

    _logger.d(searchInBots.toString());
    // for(var bot in result.bot){
    //  searchInBots.add(bot.bot);
    // }
    return searchInBots;
  }
}
