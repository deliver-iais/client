import 'dart:convert';

import 'package:deliver_flutter/db/dao/BotInfoDao.dart';
import 'package:deliver_flutter/db/database.dart';

import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_public_protocol/pub/v1/bot.pbgrpc.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
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
  _botInfoDao.saveBotInfo( BotInfo( description: result.description, username: botUid.node,name: result.name, commands: jsonEncode(result.commands)));
  }

  Future<BotInfo> getBotInfo(Uid botUid)async{
   return await _botInfoDao.getBotInfo(botUid.node);

  }

  Future<List<Uid>> searchBotByName(String name)async {
   //Todo complete search in bot
   // var result = await _botServiceClient.searchByName(SearchByNameReq()..name = name,options: CallOptions(
   //  metadata: {"access_token" : await _accountRepo.getAccessToken()},timeout: Duration(seconds: 2)
   // ));
   List<Uid> searchInBots = List();
   if(name.contains("father")){
    Uid uid = Uid();
    uid.category = Categories.BOT;
    uid.node = "father_bot";
    searchInBots.add(uid);
   }

   print(searchInBots.toString());
   // for(var bot in result.bot){
   //  searchInBots.add(bot.bot);
   // }
   return searchInBots;

  }
}