import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/repository/roomRepo.dart';
import 'package:deliver_flutter/services/routing_service.dart';
import 'package:deliver_flutter/shared/circleAvatar.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart' as proto;
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';
import 'package:get_it/get_it.dart';

class ChatItemToForward extends StatelessWidget {
  final Uid uid;
  final List<Message> forwardedMessages;
  final proto.ShareUid shareUid;

  ChatItemToForward({Key key, this.uid, this.forwardedMessages, this.shareUid})
      : super(key: key);
  final _roomRepo = GetIt.I.get<RoomRepo>();
  final _routingService = GetIt.I.get<RoutingService>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0.0),
      child: Container(
        height: 50,
        child: Row(
          children: <Widget>[
            SizedBox(
              width: 12,
            ),
            CircleAvatarWidget(this.uid, 30),
            // ContactPic(true, uid),
            SizedBox(
              width: 12,
            ),
            GestureDetector(
              child: FutureBuilder(
                  future: _roomRepo.getRoomDisplayName(uid),
                  builder: (BuildContext c, AsyncSnapshot<String> snaps) {
                    if (snaps.hasData && snaps.data != null) {
                      return Text(
                        snaps.data,
                        style: TextStyle(
                          color: ExtraTheme.of(context).infoChat,
                          fontSize: 18,
                        ),
                      );
                    } else {
                      return Text(
                        "unKnown",
                        style: TextStyle(
                          color: ExtraTheme.of(context).infoChat,
                          fontSize: 18,
                        ),
                      );
                    }
                  }),
              onTap: () {
                _routingService.openRoom(uid.asString(),
                    forwardedMessages: forwardedMessages, shareUid: shareUid);
//                ExtendedNavigator.of(context).push(Routes.roomPage,
//                    arguments: RoomPageArguments(
//                        roomId: uid.asString(),
//                        forwardedMessages: forwardedMessages));
              },
            ),

            Spacer(),
          ],
        ),
      ),
    );
  }
}
