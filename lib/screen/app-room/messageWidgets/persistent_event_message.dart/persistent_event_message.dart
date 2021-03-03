import 'dart:convert';

import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/repository/roomRepo.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/persistent_event.pb.dart';

import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';
import 'package:deliver_flutter/shared/extensions/jsonExtension.dart';

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
    PersistentEvent persistentEventMessage = message.json.toPersistentEvent();
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
              future: getPersistentMessage(persistentEventMessage),
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

  Future<String> getPersistentMessage(PersistentEvent  persistentEventMessage) async {
    switch (persistentEventMessage.whichType()) {
      case PersistentEvent_Type.mucSpecificPersistentEvent:
        String issuer = await getName(
            persistentEventMessage.mucSpecificPersistentEvent.issuer);
        String assignee = await getName(
            persistentEventMessage.mucSpecificPersistentEvent.assignee);
        switch (persistentEventMessage.mucSpecificPersistentEvent.issue) {
          case MucSpecificPersistentEvent_Issue.ADD_USER:
            return " $issuer  ${_appLocalization.getTraslateValue("add_user_to_muc")} $assignee";
          case MucSpecificPersistentEvent_Issue.AVATAR_CHANGED:
            return message.from.uid.category == Categories.CHANNEL
                ? "$issuer } ${_appLocalization.getTraslateValue("change_channel_avatar")}"
                : "$issuer  ${_appLocalization.getTraslateValue("change_group_avatar")}";
          case MucSpecificPersistentEvent_Issue.JOINED_USER:
            return "$issuer ${_appLocalization.getTraslateValue("joint_to_group")}";

          case MucSpecificPersistentEvent_Issue.KICK_USER:
            return "$issuer ، $assignee ${_appLocalization.getTraslateValue("kick_from_muc")}";
          case MucSpecificPersistentEvent_Issue.LEAVE_USER:
            return "$issuer ${_appLocalization.getTraslateValue("left_the_group")}";
          case MucSpecificPersistentEvent_Issue.MUC_CREATED:
            return message.from.uid.category == Categories.CHANNEL
                ? "$issuer  ${_appLocalization.getTraslateValue("create_channel")}"
                : "$issuer  ${_appLocalization.getTraslateValue("create_group")}";
          case MucSpecificPersistentEvent_Issue.NAME_CHANGED:
            return "$issuer  ${_appLocalization.getTraslateValue("change_muc_name")}";
          case MucSpecificPersistentEvent_Issue.PIN_MESSAGE:
            return "$issuer ${_appLocalization.getTraslateValue("pin_message")}";
        }

        break;
      case PersistentEvent_Type.messageManipulationPersistentEvent:
        break;
      case PersistentEvent_Type.adminSpecificPersistentEvent:
        String user = await _roomRepo.getRoomDisplayName(message.from.uid);
        return "$user ${_appLocalization.getTraslateValue("new_contact_add")}";
        break;
      case PersistentEvent_Type.notSet:
        // TODO: Handle this case.
        break;
    }
    ;
  }

  Future<String> getName(Uid uid) async {
    if (uid == null) return "";
    String name = uid.isSameEntity(_accountRepo.currentUserUid.asString())
        ? _appLocalization.getTraslateValue("you")
        : await _roomRepo.getRoomDisplayName(uid);
    return name;
  }
}
