import 'dart:convert';

import 'package:deliver_flutter/db/dao/BotInfoDao.dart';
import 'package:deliver_flutter/db/database.dart';

import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_public_protocol/pub/v1/bot.pbgrpc.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:deliver_public_protocol/pub/v1/query.pbgrpc.dart';
import 'package:get_it/get_it.dart';
import 'package:grpc/grpc.dart';

class BotRepo{


 BotServiceClient _botServiceClient = GetIt.I.get<BotServiceClient>();

 var _accountRepo = GetIt.I.get<AccountRepo>();
 var _botInfoDao = GetIt.I.get<BotInfoDao>();



  Future featchBotInfo(Uid botUid)async{
   var result = await _botServiceClient.getInfo(GetInfoReq()..bot= botUid,options: CallOptions(
    metadata: {"access_token" : await _accountRepo.getAccessToken()}
   ));
  _botInfoDao.saveBotInfo( BotInfo( description: result.description, username: botUid.node,name: result.name, commands:json.decode(result.commands.toString())));
  }

  Future<BotInfo> getBotInfo(Uid botUid)async{
   return await _botInfoDao.getBotInfo(botUid.node);

  }

  Future<List<Uid>> searchBotByName(String name)async {
   var result = await _botServiceClient.searchByName(SearchByNameReq()..name = name,options: CallOptions(
    metadata: {"access_token" : await _accountRepo.getAccessToken()}
   ));
   List<Uid> searchInBots = List();
   for(var bot in result.bot){
    searchInBots.add(bot.bot);
   }
   return searchInBots;

  }
}