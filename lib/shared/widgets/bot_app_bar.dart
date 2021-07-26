import 'package:deliver_flutter/repository/roomRepo.dart';
import 'package:deliver_flutter/services/routing_service.dart';
import 'package:deliver_flutter/shared/widgets/circle_avatar.dart';
import 'package:deliver_flutter/shared/widgets/title_status.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';

class BotAppbar extends StatelessWidget {
  final _routingService = GetIt.I.get<RoutingService>();
  final Uid botUid;

  final _roomRepo = GetIt.I.get<RoomRepo>();

  BotAppbar({Key key, this.botUid}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Theme.of(context).appBarTheme.color,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          child: Row(
            children: [
              CircleAvatarWidget(botUid, 23),
              SizedBox(
                width: 15,
              ),
              Expanded(
                child: FutureBuilder<String>(
                    future: _roomRepo.getName(botUid),
                    builder: (c, name) {
                      if (name.hasData && name.data != null)
                        return buildColumn(name.data, context);
                      else {
                        return buildColumn(botUid.node, context);
                      }
                    }),
              )
            ],
          ),
          onTap: () {
            _routingService.openProfile(botUid.asString());
          },
        ));
  }

  Column buildColumn(String name, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.fade,
          softWrap: false,
          style: Theme.of(context).textTheme.headline2,
        ),
        TitleStatus(
          currentRoomUid: botUid,
        )
      ],
    );
  }
}
