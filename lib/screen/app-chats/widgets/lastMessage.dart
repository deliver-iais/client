import 'dart:convert';

import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/models/messageType.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/repository/roomRepo.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/persistent_event_message.dart/persistent_event_message.dart';
import 'package:deliver_flutter/shared/methods/isPersian.dart';
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

  @override
  Widget build(BuildContext context) {
    AppLocalization _appLocalization = AppLocalization.of(context);
    String data;
    TextDirection td;
    String oneLine = message.type == MessageType.TEXT
        ? (message.json.toText().text.split('\n'))[0]
        : message.type == MessageType.PERSISTENT_EVENT
            ? message.json.toPersistentEvent().mucSpecificPersistentEvent.issue.name
            : message.type == MessageType.FILE ?_appLocalization.getTraslateValue("file"): message.type == MessageType.LOCATION?_appLocalization.getTraslateValue("location"):"message"
    ;
    if (oneLine.isPersian()) {
      td = TextDirection.rtl;
    } else
      td = TextDirection.ltr;
    data = oneLine;
    if (message.roomId.uid.category == Categories.GROUP &&
        message.type != MessageType.PERSISTENT_EVENT) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          message.from.contains(_accountRepo.currentUserUid.asString())
              ? _fromDisplayName(
                  _appLocalization.getTraslateValue("you"), context)
              : FutureBuilder<String>(
                  future: _roomRepo.getRoomDisplayName(message.from.uid),
                  builder:
                      (BuildContext context, AsyncSnapshot<String> snapshot) {
                    if (snapshot.data != null) {
                      return _fromDisplayName(snapshot.data, context);
                    } else {
                      return _fromDisplayName("Unknown", context);
                    }
                  },
                ),
          Text(
            oneLine.length > 20 ? oneLine.substring(0, 20) : oneLine,
            maxLines: 1,
            textDirection: td,
            overflow: TextOverflow.fade,
            style: TextStyle(
              // color:
              //     : ExtraTheme.of(context).infoChat,
              fontSize: 13,
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
              data,
              maxLines: 1,
              textDirection: td,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              style: TextStyle(
                color: ExtraTheme.of(context).infoChat,
                fontSize: 11,
              ),
            ),
          );
  }

  Widget _fromDisplayName(String from, BuildContext context) {
    return Text(
      "$from :",
      style: TextStyle(
        color: Theme.of(context).primaryColor,
        fontSize: 13,
      ),
    );
  }
}
