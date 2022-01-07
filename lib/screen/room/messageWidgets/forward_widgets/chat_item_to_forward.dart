import 'package:deliver/box/message.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/widgets/circle_avatar.dart';
import 'package:deliver/theme/extra_theme.dart';
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart' as proto;
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:get_it/get_it.dart';

class ChatItemToForward extends StatelessWidget {
  final Uid uid;
  final List<Message>? forwardedMessages;
  final proto.ShareUid? shareUid;

  ChatItemToForward(
      {Key? key, required this.uid, this.forwardedMessages, this.shareUid})
      : super(key: key);
  final _roomRepo = GetIt.I.get<RoomRepo>();
  final _routingService = GetIt.I.get<RoutingService>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0.0),
      child: SizedBox(
        height: 50,
        child: Row(
          children: <Widget>[
            const SizedBox(
              width: 12,
            ),
            CircleAvatarWidget(uid, 30),
            // ContactPic(true, uid),
            const SizedBox(
              width: 12,
            ),
            GestureDetector(
              child: FutureBuilder(
                  future: _roomRepo.getName(uid),
                  builder: (BuildContext c, AsyncSnapshot<String> snaps) {
                    if (snaps.hasData && snaps.data != null) {
                      return Text(
                        snaps.data!,
                        style: TextStyle(
                          color:
                              ExtraTheme.of(context).chatOrContactItemDetails,
                          fontSize: 18,
                        ),
                      );
                    } else {
                      return Text(
                        "unKnown",
                        style: TextStyle(
                          color:
                              ExtraTheme.of(context).chatOrContactItemDetails,
                          fontSize: 18,
                        ),
                      );
                    }
                  }),
              onTap: () {
                _routingService.openRoom(uid.asString(),
                    forwardedMessages: forwardedMessages??[],
                    shareUid: shareUid);
              },
            ),

            const Spacer(),
          ],
        ),
      ),
    );
  }
}
