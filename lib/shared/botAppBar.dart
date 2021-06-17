import 'dart:ui';

import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/repository/roomRepo.dart';
import 'package:deliver_flutter/services/audioPlayerAppBar.dart';
import 'package:deliver_flutter/services/routing_service.dart';
import 'package:deliver_flutter/shared/circleAvatar.dart';
import 'package:deliver_flutter/shared/title_status.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';

class BotAppbar extends StatelessWidget {
  final _routingService = GetIt.I.get<RoutingService>();
  final Uid botUid;

  BotAppbar({Key key, this.botUid}) : super(key: key);

  var _roomRepo = GetIt.I.get<RoomRepo>();

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Theme.of(context).appBarTheme.color,
        child: GestureDetector(
          child: Row(
            children: [
              CircleAvatarWidget(botUid, 23),
              SizedBox(
                width: 15,
              ),
              FutureBuilder<String>(
                  future: _roomRepo.getRoomDisplayName(botUid),
                  builder: (c, name) {
                    if (name.hasData && name.data != null)
                      return buildColumn(name.data, context);
                    else {
                      return buildColumn(botUid.node, context);
                    }
                  })
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
          style: Theme.of(context).textTheme.headline2,
        ),
        TitleStatus(
          currentRoomUid: botUid,
        )
      ],
    );
  }
}
