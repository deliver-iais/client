import 'dart:convert';

import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/box/message.dart';
import 'package:deliver_flutter/box/message_type.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/repository/roomRepo.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver_flutter/shared/extensions/jsonExtension.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';

class SenderAndContent extends StatelessWidget {
  final List<Message> messages;
  final bool inBox;
  final _roomRepo = GetIt.I.get<RoomRepo>();
  final _accountRepo = GetIt.I.get<AccountRepo>();

  SenderAndContent({Key key, this.messages, this.inBox}) : super(key: key);

  String generateTitle() {
    List<String> names = [];
    for (var i = 0; i < messages.length; i++) {
      if (!names.contains(messages[i].from.length > 3
          ? messages[i].from.substring(0, 3)
          : messages[i].from))
        names.add(messages[i].from.length > 3
            ? messages[i].from.substring(0, 3)
            : messages[i].from);
    }
    String title = names[0];
    for (var i = 1; i < names.length; i++) {
      title = title + ' ,' + names[i];
    }
    return title;
  }

  @override
  Widget build(BuildContext context) {
    var appLocalization = AppLocalization.of(context);
    String content = messages.length > 1
        ? '${messages.length} ' +
            appLocalization.getTraslateValue("ForwardedMessages")
        : getContent(context, messages[0]);

    return Container(
      width: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!messages[0]
              .from
              .asUid()
              .isSameEntity(_accountRepo.currentUserUid.asString()))
            FutureBuilder<String>(
                future: _roomRepo.getName(messages[0].from.asUid()),
                builder: (ctx, AsyncSnapshot<String> s) {
                  if (s.hasData && s.data != null) {
                    return showName(s.data, context);
                  } else {
                    return showName("UnKnown", context);
                  }
                }),
          SizedBox(height: 3),
          inBox == true || messages.length == 0
              ? messages[0].type == MessageType.TEXT
                  ? Text(
                      content,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      style: TextStyle(
                          fontSize: 15,
                          color: ExtraTheme.of(context).textMessage),
                    )
                  : messages[0].type == MessageType.FILE
                      ? Text(
                          (jsonDecode(messages[0].json))["type"] == 'image'
                              ? 'Image'
                              : (jsonDecode(messages[0].json))["type"] ==
                                      'video'
                                  ? 'Video'
                                  : 'File',
                          maxLines: 1,
                          style: TextStyle(
                              fontSize: 15,
                              color: ExtraTheme.of(context).messageDetails),
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                        )
                      : Container()
              : Text(
                  getContent(context, messages[0]),
                  maxLines: 1,
                  style: TextStyle(
                      fontSize: 15, color: ExtraTheme.of(context).textMessage),
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                ),
        ],
      ),
    );
  }

  getContent(BuildContext context, Message message) {
    var appLocalization = AppLocalization.of(context);

    switch (message.type) {
      case MessageType.TEXT:
        return message.json.toText().text;
        break;
      case MessageType.FILE:
        return appLocalization.getTraslateValue("file");
        break;
      case MessageType.STICKER:
        return appLocalization.getTraslateValue("Sticker");
        break;
      case MessageType.LOCATION:
        return "Location";
        break;
      case MessageType.LIVE_LOCATION:
        return "Location";
        break;
      case MessageType.POLL:
        return "Poll";
        break;
      case MessageType.FORM:
        return "Form";
        break;
      case MessageType.PERSISTENT_EVENT:
        return "\t";
        break;
      case MessageType.NOT_SET:
        return "\t";
        break;
      case MessageType.BUTTONS:
        return "Form";
        break;
      case MessageType.SHARE_UID:
        return message.json.toShareUid().name;
        break;
      case MessageType.FORM_RESULT:
        return "Form";
        break;
      case MessageType.SHARE_PRIVATE_DATA_REQUEST:
        return "Request";
        break;
      case MessageType.SHARE_PRIVATE_DATA_ACCEPTANCE:
        return "Request";
        break;
    }
  }

  Text showName(String s, BuildContext context) {
    return Text(
      s,
      style: TextStyle(
        color: inBox == true
            ? Theme.of(context).primaryColor.withGreen(70)
            : Theme.of(context).primaryColor,
        // ? ExtraTheme.of(context).messageDetails
        //   : Theme.of(context).primaryColor,
        fontWeight: FontWeight.bold, fontSize: 15,
      ),
      maxLines: 1,
      softWrap: false,
      overflow: TextOverflow.ellipsis,
    );
  }
}
