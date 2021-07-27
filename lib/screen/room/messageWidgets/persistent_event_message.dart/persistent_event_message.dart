import 'package:deliver_flutter/localization/i18n.dart';
import 'package:deliver_flutter/box/message.dart';
import 'package:deliver_flutter/repository/authRepo.dart';
import 'package:deliver_flutter/repository/roomRepo.dart';
import 'package:deliver_flutter/shared/methods/message.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/persistent_event.pb.dart';

import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';
import 'package:deliver_flutter/shared/extensions/json_extension.dart';

class PersistentEventMessage extends StatelessWidget {
  final Message message;
  final bool showLastMessage;
  final _roomRepo = GetIt.I.get<RoomRepo>();
  final _authRepo = GetIt.I.get<AuthRepo>();
  final _i18n = GetIt.I.get<I18N>();

  PersistentEventMessage({Key key, this.message, this.showLastMessage})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    PersistentEvent persistentEventMessage = message.json.toPersistentEvent();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: showLastMessage
            ? ExtraTheme.of(context).persistentEventMessage
            : Theme.of(context).primaryColor,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: FutureBuilder<String>(
        future: getPersistentMessage(context, persistentEventMessage),
        builder: (c, s) {
          if (s.hasData) {
            return Directionality(
                textDirection:
                    _i18n.isPersian ? TextDirection.rtl : TextDirection.ltr,
                child: Text(
                  s.data,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
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
      BuildContext context, PersistentEvent persistentEventMessage) async {
    switch (persistentEventMessage.whichType()) {
      case PersistentEvent_Type.mucSpecificPersistentEvent:
        String issuer =
            (persistentEventMessage.mucSpecificPersistentEvent.issue ==
                        MucSpecificPersistentEvent_Issue.PIN_MESSAGE) &&
                    message.to.asUid().category == Categories.CHANNEL
                ? ""
                : await _roomRepo.getSlangName(
                    persistentEventMessage.mucSpecificPersistentEvent.issuer);
        String assignee =
            persistentEventMessage.mucSpecificPersistentEvent.issue !=
                    MucSpecificPersistentEvent_Issue.PIN_MESSAGE
                ? await _roomRepo.getSlangName(
                    persistentEventMessage.mucSpecificPersistentEvent.assignee)
                : "";
        bool isMe = persistentEventMessage.mucSpecificPersistentEvent.issuer
            .isSameEntity(_authRepo.currentUserUid.asString());
        switch (persistentEventMessage.mucSpecificPersistentEvent.issue) {
          case MucSpecificPersistentEvent_Issue.PIN_MESSAGE:
            return "$issuer ${_i18n.get("pin_message")}";
            break;
          case MucSpecificPersistentEvent_Issue.ADD_USER:
            return " $issuer ${isMe ? _i18n.get("you_add_user_to_muc") : _i18n.get("add_user_to_muc")} $assignee";

          case MucSpecificPersistentEvent_Issue.AVATAR_CHANGED:
            return message.from.asUid().category == Categories.CHANNEL
                ? "$issuer } ${_i18n.get("change_channel_avatar")}"
                : "$issuer  ${_i18n.get("change_group_avatar")}";
          case MucSpecificPersistentEvent_Issue.JOINED_USER:
            return "$issuer ${_i18n.get("joined_to_group")}";
            break;

          case MucSpecificPersistentEvent_Issue.KICK_USER:
            return "$issuer ،  ${_i18n.get("kick_from_muc")} $assignee";
            break;
          case MucSpecificPersistentEvent_Issue.LEAVE_USER:
            return "$issuer ${_i18n.get("left_the_group")}";
            break;
          case MucSpecificPersistentEvent_Issue.MUC_CREATED:
            return message.from.asUid().category == Categories.CHANNEL
                ? "$issuer  ${isMe ? _i18n.get("you_create_channel") : _i18n.get("create_channel")}"
                : "$issuer  ${isMe ? _i18n.get("you_create_group") : _i18n.get("create_group")}";
            break;
          case MucSpecificPersistentEvent_Issue.NAME_CHANGED:
            return "$issuer  ${_i18n.get("change_muc_name")}";
            break;
        }

        break;
      case PersistentEvent_Type.messageManipulationPersistentEvent:
        break;
      case PersistentEvent_Type.adminSpecificPersistentEvent:
        var user = await _roomRepo.getName(message.from.asUid());
        return "$user ${_i18n.get("new_contact_add")}";
        break;
      case PersistentEvent_Type.notSet:
        break;
    }
    return "";
  }
}
