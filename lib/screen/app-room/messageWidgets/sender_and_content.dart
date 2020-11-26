import 'dart:convert';

import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/models/messageType.dart';
import 'package:deliver_flutter/repository/roomRepo.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';

class SenderAndContent extends StatelessWidget {
  final List<Message> messages;
  final bool inBox;
  final _roomRepo = GetIt.I.get<RoomRepo>();

  SenderAndContent({Key key, this.messages, this.inBox}) : super(key: key);

  String generateTitle() {
    List<String> names = List<String>();
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
    AppLocalization appLocalization = AppLocalization.of(context);
    String content = messages.length > 1
        ? '${messages.length} ' +
            appLocalization.getTraslateValue("ForwardedMessages")
        : messages[0].type == MessageType.TEXT
            ? (jsonDecode(messages[0].json))["text"]
            : "File";

    return Container(
      width: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FutureBuilder<String>(
              future: _roomRepo.getRoomDisplayName(messages[0].from.uid),
              builder: (ctx, AsyncSnapshot<String> s) {
                if (s.hasData && s.data != null) {
                  return Text(
                    s.data,
                    style: TextStyle(
                      color: inBox == true
                          ? ExtraTheme.of(context).secondColor
                          : Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                  );
                } else {
                  return Text(
                    "UnKnown",
                    style: TextStyle(
                      color: inBox == true
                          ? ExtraTheme.of(context).secondColor
                          : Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                  );
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
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                        )
                      : Container()
              : Text(
                  content,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                ),
        ],
      ),
    );
  }
}
