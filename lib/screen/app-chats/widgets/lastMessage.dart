import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/box/message.dart';
import 'package:deliver_flutter/box/message_type.dart';
import 'package:deliver_flutter/repository/authRepo.dart';
import 'package:deliver_flutter/repository/roomRepo.dart';
import 'package:deliver_flutter/screen/app-chats/widgets/unread_message_counter.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/persistent_event_message.dart/persistent_event_message.dart';
import 'package:deliver_flutter/shared/seenStatus.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pbenum.dart';
import 'package:flutter/material.dart';
import 'package:deliver_flutter/shared/extensions/jsonExtension.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';
import 'package:get_it/get_it.dart';

class LastMessage extends StatelessWidget {
  final Message message;
  final int lastMessageId;
  final bool hasMentioned;
  final _roomRepo = GetIt.I.get<RoomRepo>();
  final _authRepo = GetIt.I.get<AuthRepo>();

  LastMessage({Key key, this.message, this.lastMessageId, this.hasMentioned})
      : super(key: key);

  messageText(BuildContext context) {
    I18N _i18n = I18N.of(context);
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
        var file = this.message.json.toFile();
        return file.name;
      case MessageType.LOCATION:
        return _i18n.get("location");
      case MessageType.SHARE_UID:
        if (message.json.toShareUid().uid.category == Categories.USER)
          return message.json.toShareUid().name;
        else
          return _i18n.get("invite_link") +
              " " +
              message.json.toShareUid().name;
        break;
      default:
        return "Message";
    }
  }

  @override
  Widget build(BuildContext context) {
    I18N _i18n = I18N.of(context);
    String oneLine = messageText(context);
    bool shouldHighlight = message.type != MessageType.TEXT;

    var isReceivedMessage = !_authRepo.isCurrentUser(message.from);

    return Row(
      // crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isReceivedMessage)
          Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: SeenStatus(message),
          ),
        if (message.roomUid.asUid().category == Categories.GROUP &&
            message.type != MessageType.PERSISTENT_EVENT)
          !isReceivedMessage
              ? _fromDisplayName(
                  _i18n.get("you"), context)
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
        message.type == MessageType.PERSISTENT_EVENT
            ? Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: PersistentEventMessage(
                    message: message,
                    showLastMessage: true,
                  ),
                ),
              )
            : Expanded(
                child: Text(
                  oneLine,
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  style: TextStyle(
                    color: shouldHighlight
                        ? ExtraTheme.of(context).username
                        : ExtraTheme.of(context).chatOrContactItemDetails,
                    fontSize: 14,
                  ),
                ),
              ),
        SizedBox.shrink(),
        if (hasMentioned)
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
                color: Theme.of(context).primaryColor, shape: BoxShape.circle),
            child: Icon(
              Icons.alternate_email,
              size: 15,
            ),
          ),
        if (!_authRepo.isCurrentUser(message.from))
          Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: UnreadMessageCounterWidget(message.roomUid, lastMessageId),
          )
      ],
    );
  }

  Widget _fromDisplayName(String from, BuildContext context) {
    return Text(
      "$from: ",
      style: TextStyle(
          color: ExtraTheme.of(context).username,
          fontSize: 14,
          fontWeight: FontWeight.w500),
    );
  }
}
