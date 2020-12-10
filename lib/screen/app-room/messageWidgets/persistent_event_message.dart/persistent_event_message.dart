import 'dart:convert';

import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/repository/roomRepo.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';

class PersistentEventMessage extends StatelessWidget {
  final Message message;
  final bool showLastMessage;
  final _roomRepo = GetIt.I.get<RoomRepo>();
  final _accountRepo = GetIt.I.get<AccountRepo>();

  PersistentEventMessage({Key key, this.message, this.showLastMessage})
      : super(key: key);

  AppLocalization _appLocalization;

  @override
  Widget build(BuildContext context) {
    _appLocalization = AppLocalization.of(context);
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Container(
        decoration: BoxDecoration(
          color: showLastMessage
              ? Theme.of(context).backgroundColor
              : ExtraTheme.of(context).details,
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
            child: FutureBuilder(
              future: getMessage(message.json),
              builder: (c, s) {
                if (s.hasData) {
                  return Text(
                    s.data,
                    style: TextStyle(
                        color: ExtraTheme.of(context).infoChat, fontSize: 12),
                  );
                } else {
                  return Text(
                    "...",
                    style: TextStyle(
                        color: ExtraTheme.of(context).secondColor,
                        fontSize: 12),
                  );
                }
              },
            )),
      ),
    );
  }

  Future<String> getMessage(String content) async {
    String type = jsonDecode(content)["type"];
    switch (type) {
      case "ADMIN_EVENT":
        String user = await _roomRepo.getRoomDisplayName(message.from.uid);
        return "$user ${_appLocalization.getTraslateValue("new_contact_add")}";
      case "MUC_EVENT":
        String issueType = jsonDecode(content)["issueType"];
        String issuer = jsonDecode(content)["issuer"];
        String assignee = jsonDecode(content)["assignee"];
        String issuerName = "";
        String assigneeName = "";
        try {
          issuerName = issuer.contains(_accountRepo.currentUserUid.asString())
              ? _appLocalization.getTraslateValue("you")
              : await _roomRepo.getRoomDisplayName(issuer.uid);
          assigneeName = assignee.contains(_accountRepo.currentUserUid.asString())
              ? _appLocalization.getTraslateValue("you")
              : await _roomRepo.getRoomDisplayName(assignee.uid);
        } catch (e) {
          print(e);
        }

        switch (issueType) {
          case "ADD_USER":
            return "$issuerName  ${_appLocalization.getTraslateValue("add_user_to_muc")} $assigneeName";
          case "AVATAR_CHANGED":
            return message.from.uid.category == Categories.CHANNEL
                ? "$issuerName  ${_appLocalization.getTraslateValue("change_channel_avatar")}"
                : "$issuerName  ${_appLocalization.getTraslateValue("change_group_avatar")}";
          case "MUC_CREATED":
            return message.from.uid.category == Categories.CHANNEL
                ? "$issuerName  ${_appLocalization.getTraslateValue("create_channel")}"
                : "$issuerName  ${_appLocalization.getTraslateValue("create_group")}";
          case "LEAVE_USER":
            return "$issuerName  ${_appLocalization.getTraslateValue("leave_muc")}";
          case "NAME_CHANGED":
            return "$issuerName  ${_appLocalization.getTraslateValue("change_muc_name")}";
          case "PIN_MESSAGE":
            return "$issuerName  ${_appLocalization.getTraslateValue("pin_message")}";
          case "KICK_USER":
            return "$issuerName ، $assigneeName ${_appLocalization.getTraslateValue("kick_from_muc")}";
        }

        return "";
        break;
    }
  }
}
