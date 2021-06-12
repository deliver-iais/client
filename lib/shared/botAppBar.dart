import 'dart:ui';

import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/repository/roomRepo.dart';
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

  @override
  Widget build(BuildContext context) {
    AppLocalization i18n = AppLocalization.of(context);
    return Container(
        color: Theme.of(context).appBarTheme.color,
        child: GestureDetector(
          child: Row(
            children: [
              CircleAvatarWidget(botUid, 23),
              SizedBox(
                width: 15,
              ),
              Column(
                      children: [
                        Text(
                          botUid.node,
                          style: TextStyle(fontSize: 20),
                        ),
                        // TitleStatus(
                        //   currentRoomUid:botUid,
                        //   // normalConditionWidget: Text("last seen",style: TextStyle(fontSize: 12),) //todo last seen,
                        // )
          Text('bot',
              style: TextStyle(fontSize: 12,color: ExtraTheme.of(context).textDetails))
                      ],
                    )
            ],
          ),
          onTap: () {
                _routingService.openProfile(botUid.asString());
          },
        ));
  }
}
