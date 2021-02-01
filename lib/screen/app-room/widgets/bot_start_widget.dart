import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/repository/messageRepo.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class BotStartWidget extends StatelessWidget{
 final Uid botUid;
 BotStartWidget({this.botUid});
 var _messageRepo = GetIt.I.get<MessageRepo>();

  @override
  Widget build(BuildContext context) {
    AppLocalization appLocalization = AppLocalization.of(context);
    return Container(
      height: 45,
      color: Colors.blue,
      child: Center(
        child: GestureDetector(
          child: Text(appLocalization.getTraslateValue("start"),style: TextStyle(fontSize: 18,),),
          onTap: (){
            _messageRepo.sendTextMessage(botUid, "/start");
          },
        ),
      ),
    );
  }

}