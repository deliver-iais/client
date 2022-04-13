// ignore_for_file: file_names

import 'dart:async';

import 'package:deliver/box/bot_info.dart';
import 'package:deliver/box/dao/bot_dao.dart';
import 'package:deliver/box/dao/uid_id_name_dao.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver_public_protocol/pub/v1/bot.pbgrpc.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

class BotRepo {
  final _logger = GetIt.I.get<Logger>();
  final _botServiceClient = GetIt.I.get<BotServiceClient>();
  final _botDao = GetIt.I.get<BotDao>();
  final _uidIdNameDao = GetIt.I.get<UidIdNameDao>();

  Future<BotInfo> fetchBotInfo(Uid botUid) async {
    final result = await _botServiceClient.getInfo(GetInfoReq()..bot = botUid);
    final botInfo = BotInfo(
      description: result.description,
      uid: botUid.asString(),
      name: result.name,
      commands: result.commands,
      isOwner: result.isOwner,
    );

    unawaited(
      _uidIdNameDao.update(
        botUid.asString(),
        name: result.name,
        id: botUid.asString(),
      ),
    );

    roomNameCache.set(botUid.asString(), result.name);

    unawaited(_botDao.save(botInfo));

    return botInfo;
  }

  Future<BotInfo?> getBotInfo(Uid botUid) async {
    if (!botUid.isBot()) return null;
    final botInfo = await _botDao.get(botUid.asString());
    // TODO(hasan): add lastUpdate field in model and check it later in here!, https://gitlab.iais.co/deliver/wiki/-/issues/415
    if (botInfo != null) {
      return botInfo;
    }
    return fetchBotInfo(botUid);
  }

  Future<List<Uid>> searchBotByName(String name) async {
    if (name.isEmpty) {
      return [];
    }

    //Todo complete search in bot
    // var result = await _botServiceClient.searchByName(SearchByNameReq()..name = name);
    final searchInBots = <Uid>[];
    if (name.contains("father")) {
      final uid = Uid()
        ..category = Categories.BOT
        ..node = "father_bot";
      searchInBots.add(uid);
    }

    _logger.d(searchInBots.toString());
    // for(var bot in result.bot){
    //  searchInBots.add(bot.bot);
    // }
    return searchInBots;
  }
}
