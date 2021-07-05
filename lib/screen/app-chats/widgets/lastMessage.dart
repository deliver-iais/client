import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/box/message.dart';
import 'package:deliver_flutter/box/message_type.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/repository/roomRepo.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/persistent_event_message.dart/persistent_event_message.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pbenum.dart';
import 'package:flutter/material.dart';
import 'package:deliver_flutter/shared/extensions/jsonExtension.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';
import 'package:get_it/get_it.dart';

class LastMessage extends StatelessWidget {
  final Message message;
  final _roomRepo = GetIt.I.get<RoomRepo>();
  final _accountRepo = GetIt.I.get<AccountRepo>();

  LastMessage({Key key, this.message}) : super(key: key);

  messageText(BuildContext context) {
    AppLocalization _appLocalization = AppLocalization.of(context);
    switch (message.type) {
      case MessageType.TEXT:
        return (message.json.toText().text.trim().split('\n'))[0];
      case MessageType.PERSISTENT_EVENT:
        return message.json
            .toPersistentEvent()
            .mucSpecificPersistentEvent
            .issue
            .name;
      case MessageType.FILE:
        return _appLocalization.getTraslateValue("file");
      case MessageType.LOCATION:
        return _appLocalization.getTraslateValue("location");
      case MessageType.SHARE_UID:
        if (message.json.toShareUid().uid.category == Categories.USER)
          return message.json.toShareUid().name;
        else
          return _appLocalization.getTraslateValue("inviteLink") +
              " " +
              message.json.toShareUid().name;
        break;
      default:
        return "Message";
    }
  }

  @override
  Widget build(BuildContext context) {
    AppLocalization _appLocalization = AppLocalization.of(context);
    String oneLine = messageText(context);
    bool shouldHighlight = message.type != MessageType.TEXT;
    if (message.roomUid.asUid().category == Categories.GROUP &&
        message.type != MessageType.PERSISTENT_EVENT) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          message.from.contains(_accountRepo.currentUserUid.asString())
              ? _fromDisplayName(
                  _appLocalization.getTraslateValue("you"), context)
              : FutureBuilder<String>(
                  future: _roomRepo.getName(message.from.asUid()),
                  builder:
                      (BuildContext context, AsyncSnapshot<String> snapshot) {
                    if (snapshot.data != null) {
                      return _fromDisplayName(snapshot.data, context);
                    } else {
                      return _fromDisplayName("Unknown", context);
                    }
                  },
                ),
          Container(
            width: 100,
            child: Text(
              oneLine,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: shouldHighlight
                    ? ExtraTheme.of(context).username
                    : ExtraTheme.of(context).chatOrContactItemDetails,
                fontSize: 14,
              ),
            ),
          ),
        ],
      );
    }

    return message.type == MessageType.PERSISTENT_EVENT
        ? PersistentEventMessage(
            message: message,
            showLastMessage: true,
          )
        : Container(
            width: 230,
            child: Text(
              oneLine,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              style: TextStyle(
                color: shouldHighlight
                    ? ExtraTheme.of(context).username
                    : ExtraTheme.of(context).chatOrContactItemDetails,
                fontSize: 14,
              ),
            ),
          );
  }

  Widget _fromDisplayName(String from, BuildContext context) {
    return Text(
      "$from :",
      style: TextStyle(
        color: Theme.of(context).primaryColor,
        fontSize: 14,
      ),
    );
  }
}
