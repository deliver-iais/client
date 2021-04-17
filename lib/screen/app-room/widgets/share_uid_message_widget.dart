import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/timeAndSeenStatus.dart';
import 'package:deliver_flutter/services/routing_service.dart';
import 'package:deliver_flutter/shared/seenStatus.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart' as proto;
import 'package:flutter/cupertino.dart';
import 'package:deliver_flutter/shared/extensions/jsonExtension.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';

import 'msgTime.dart';

class ShareUidMessageWidget extends StatelessWidget {
  final Message message;
  final bool isSender;
  final bool isSeen;

  ShareUidMessageWidget({this.message, this.isSender, this.isSeen});

  var _routingServices = GetIt.I.get<RoutingService>();

  proto.ShareUid _shareUid;

  @override
  Widget build(BuildContext context) {
    _shareUid = message.json.toShareUid();
    return Row(
      children: [
        GestureDetector(
          child: Text(
            _shareUid.name,
            style: TextStyle(
              fontSize: 16,
              color: Colors.amber,
            ),
          ),
          onTap: () {
            _routingServices.openRoom(_shareUid.uid.asString(),
                joinToMuc: (_shareUid.uid.category == Categories.GROUP ||
                    _shareUid.uid.category == Categories.CHANNEL));
          },
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0, top: 5),
          child: MsgTime(
            time: message.time,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 3.0, top: 5),
          child: SeenStatus(
            message,
            isSeen: isSeen,
          ),
        ),
      ],
    );
  }
}
