import 'package:date_time_format/date_time_format.dart';
import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/box/dao/muc_dao.dart';
import 'package:deliver_flutter/box/muc.dart';
import 'package:deliver_flutter/repository/messageRepo.dart';
import 'package:deliver_flutter/repository/mucRepo.dart';
import 'package:deliver_flutter/screen/app-room/widgets/share_uid_message_widget.dart';
import 'package:deliver_flutter/services/routing_service.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pbenum.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';

import 'circleAvatar.dart';
import 'constants.dart';

bool isOnline(int time) {
  return DateTime.now().millisecondsSinceEpoch - time < ONLINE_TIME;
}

DateTime date(int time) {
  return DateTime.fromMillisecondsSinceEpoch(time);
}

String dateTimeFormat(DateTime time) {
  var now = DateTime.now();
  var difference = now.difference(time);
  if (difference.inMinutes <= 2) {
    return "just now";
  } else if (difference.inDays < 1 && time.day == now.day) {
    return DateTimeFormat.format(time, format: 'H:i');
  } else if (difference.inDays <= 7)
    return DateTimeFormat.format(time, format: 'D');
  else
    return DateTimeFormat.format(time, format: 'M j');
}

String buildName(String firstName, String lastName) {
  var res = "";
  if (firstName != null && firstName.isNotEmpty) res += firstName;
  if (lastName != null && lastName.isNotEmpty) res += lastName;
  return res.trim();
}

Future<void> handleUri(String initialLink, BuildContext context) async {
  var _mucDao = GetIt.I.get<MucDao>();
  var _messageRepo = GetIt.I.get<MessageRepo>();
  var _mucRepo = GetIt.I.get<MucRepo>();
  final _routingService = GetIt.I.get<RoutingService>();
  var m = initialLink.toString().split("/");

  Uid mucUid;
  if (m[4].toString().contains("GROUP")) {
    mucUid = Uid.create()
      ..node = m[5].toString()
      ..category = Categories.GROUP;
  } else if (m[4].toString().contains("CHANNEL")) {
    mucUid = Uid.create()
      ..node = m[5].toString()
      ..category = Categories.CHANNEL;
  }
  if (mucUid != null) {
    var muc = await _mucDao.get(mucUid.asString());
    if (muc != null) {
      _routingService.openRoom(mucUid.asString());
    } else {
      showFloatingModalBottomSheet(
        context: context,
        builder: (context) => Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              CircleAvatarWidget(mucUid, 40,
                  forceText: "un"),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(AppLocalization.of(context)
                          .getTraslateValue("skip"))),
                  ElevatedButton(
                    onPressed: () async {
                      if (mucUid.category == Categories.GROUP) {
                        Muc  muc =
                            await _mucRepo.joinGroup(mucUid, m[6].toString());
                        if (muc != null) {
                          _messageRepo.updateNewMuc(mucUid,muc.lastMessageId);
                          _routingService.openRoom(mucUid.asString());
                          Navigator.of(context).pop();
                        }
                      } else {
                        Muc muc = await _mucRepo.joinChannel(mucUid, m[6]);
                        if (muc != null) {
                          _messageRepo.updateNewMuc(mucUid,muc.lastMessageId);
                          _routingService.openRoom(mucUid.asString());
                          Navigator.of(context).pop();
                        }
                      }
                    },
                    child: Text(
                        AppLocalization.of(context).getTraslateValue("join")),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }
  }
}
