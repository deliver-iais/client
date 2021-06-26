import 'dart:convert';

import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/db/dao/MemberDao.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/services/ux_service.dart';
import 'package:deliver_flutter/shared/methods/isPersian.dart';
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
  final _uxService = GetIt.I.get<UxService>();

  PersistentEventMessage({Key key, this.message, this.showLastMessage})
      : super(key: key);

  AppLocalization _appLocalization;

  @override
  Widget build(BuildContext context) {
    PersistentEvent persistentEventMessage = message.json.toPersistentEvent();
    _appLocalization = AppLocalization.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: showLastMessage
            ? ExtraTheme.of(context).persistentEventMessage
            : Theme.of(context).primaryColor,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: FutureBuilder(
        future: getPersistentMessage(persistentEventMessage),
        builder: (c, s) {
          if (s.hasData) {
            return Directionality(
                textDirection:
                    _uxService.isPersian ? TextDirection.rtl : TextDirection.ltr,
                child: Text(
                  s.data,
                  style: TextStyle(
                      color: showLastMessage
                          ? ExtraTheme.of(context).textMessage
                          : Colors.white,
                      fontSize: 14),
                ));
          } else {
            return SizedBox.shrink();
          }
        },
      ),
    );
  }

  Future<String> getPersistentMessage(
      PersistentEvent persistentEventMessage) async {
    switch (persistentEventMessage.whichType()) {
      case PersistentEvent_Type.mucSpecificPersistentEvent:
        String issuer = await getName(
            persistentEventMessage.mucSpecificPersistentEvent.issuer,
            message.to.getUid());
        String assignee = persistentEventMessage.mucSpecificPersistentEvent.issue !=   MucSpecificPersistentEvent_Issue.PIN_MESSAGE?
        await getName(
            persistentEventMessage.mucSpecificPersistentEvent.assignee,
            message.to.getUid()):"";
        bool isMe = persistentEventMessage.mucSpecificPersistentEvent.issuer
            .isSameEntity(_accountRepo.currentUserUid.asString());
        switch (persistentEventMessage.mucSpecificPersistentEvent.issue) {
          case MucSpecificPersistentEvent_Issue.PIN_MESSAGE:
            return "$issuer ${_appLocalization.getTraslateValue("pin_message")}";
            break;
          case MucSpecificPersistentEvent_Issue.ADD_USER:
            return " $issuer ${isMe ? _appLocalization.getTraslateValue("you_add_user_to_muc") : _appLocalization.getTraslateValue("add_user_to_muc")} $assignee";

          case MucSpecificPersistentEvent_Issue.AVATAR_CHANGED:
            return message.from.uid.category == Categories.CHANNEL
                ? "$issuer } ${_appLocalization.getTraslateValue("change_channel_avatar")}"
                : "$issuer  ${_appLocalization.getTraslateValue("change_group_avatar")}";
          case MucSpecificPersistentEvent_Issue.JOINED_USER:
            return "$issuer ${_appLocalization.getTraslateValue("joint_to_group")}";
            break;

          case MucSpecificPersistentEvent_Issue.KICK_USER:
            return "$issuer ،  ${_appLocalization.getTraslateValue("kick_from_muc")} $assignee";
            break;
          case MucSpecificPersistentEvent_Issue.LEAVE_USER:
            return "$issuer ${_appLocalization.getTraslateValue("left_the_group")}";
            break;
          case MucSpecificPersistentEvent_Issue.MUC_CREATED:
            return message.from.uid.category == Categories.CHANNEL
                ? "$issuer  ${isMe ? _appLocalization.getTraslateValue("you_create_channel") : _appLocalization.getTraslateValue("create_channel")}"
                : "$issuer  ${isMe ? _appLocalization.getTraslateValue("you_create_group") : _appLocalization.getTraslateValue("create_group")}";
            break;
          case MucSpecificPersistentEvent_Issue.NAME_CHANGED:
            return "$issuer  ${_appLocalization.getTraslateValue("change_muc_name")}";
            break;

        }

        break;
      case PersistentEvent_Type.messageManipulationPersistentEvent:
        break;
      case PersistentEvent_Type.adminSpecificPersistentEvent:
        var user = await _roomRepo.getRoomDisplayName(message.from.uid,
            roomUid: message.to);
        return "${user} ${_appLocalization.getTraslateValue("new_contact_add")}";
        break;
      case PersistentEvent_Type.notSet:
        // TODO: Handle this case.
        break;
    }
    ;
  }

  Future<String> getName(Uid uid, Uid to) async {
    if (uid == null) return "";
    if (uid.isSameEntity(_accountRepo.currentUserUid.asString()))
      return _appLocalization.getTraslateValue("you");
    else {
      var name = _roomRepo.getRoomDisplayName(uid, roomUid: to.asString());
      return name;
    }
  }
}
