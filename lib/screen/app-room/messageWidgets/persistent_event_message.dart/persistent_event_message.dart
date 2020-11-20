import 'dart:convert';
import 'dart:html';

import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/repository/roomRepo.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';

class PersistentEventMessage extends StatelessWidget {
  final Message message;

  PersistentEventMessage({Key key, this.message}) : super(key: key);

  var _roomRepo = GetIt.I.get<RoomRepo>();
  AppLocalization _appLocalization;
  @override
  Widget build(BuildContext context) {
    _appLocalization = AppLocalization.of(context);
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Container(
        decoration: BoxDecoration(
          color: ExtraTheme.of(context).details,
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
          child: FutureBuilder(
            future: getMessage(message.json),
            builder: (c,s){
              return Text(
              s.data,
                style: TextStyle(
                    color: ExtraTheme.of(context).secondColor, fontSize: 12),
              );
            },
          )
        ),
      ),
    );
  }

  Future<String> getMessage(String content) async{
    String type = jsonDecode(content)["type"];
    switch(type){
      case "ADMIN_EVENT":
        String user = await _roomRepo.getRoomDisplayName(message.from.uid);
        return " $user ${_appLocalization.getTraslateValue("new_contact_add")}" ;
        break;
      case "MUC_EVENT":
        String issueType = jsonDecode(content)["type"];
        switch(issueType){

        }
        return"";
       break;

    }

  }
}
