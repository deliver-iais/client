import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/db/dao/RoomDao.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/repository/messageRepo.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:moor/moor.dart';

class BotStartWidget extends StatelessWidget{
 final Uid botUid;
 BotStartWidget({this.botUid});
 var _messageRepo = GetIt.I.get<MessageRepo>();
 var _roomDao = GetIt.I.get<RoomDao>();
  @override
  Widget build(BuildContext context) {
    AppLocalization appLocalization = AppLocalization.of(context);
    return Container(
      height: 45,
      color: Theme.of(context).primaryColor,
      child: Center(
        child: GestureDetector(
          child: Text(appLocalization.getTraslateValue("start"),style: TextStyle(fontSize: 18,),),
          onTap: (){
            // _roomDao.insertRoomCompanion(
            //     RoomsCompanion(roomId: Value(botUid.toString())));
            _messageRepo.sendTextMessage(botUid, "/start");
          },
        ),
      ),
    );
  }

}