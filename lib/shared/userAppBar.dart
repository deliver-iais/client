import 'dart:ui';

import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/repository/roomRepo.dart';
import 'package:deliver_flutter/services/audioPlayerAppBar.dart';
import 'package:deliver_flutter/services/routing_service.dart';
import 'package:deliver_flutter/shared/circleAvatar.dart';
import 'package:deliver_flutter/shared/title_status.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';

class UserAppbar extends StatelessWidget {
  final _routingService = GetIt.I.get<RoutingService>();
  final _roomRepo = GetIt.I.get<RoomRepo>();
  final _accountRepo = GetIt.I.get<AccountRepo>();

  final Uid userUid;

  UserAppbar({Key key, this.userUid}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppLocalization i18n = AppLocalization.of(context);
    return Container(
        color: Theme.of(context).appBarTheme.color,
        child: GestureDetector(
          child: Row(
            children: [
              CircleAvatarWidget(userUid, 23),
              SizedBox(
                width: 15,
              ),
              userUid
                      .toString()
                      .contains(_accountRepo.currentUserUid.toString())
                  ? Text(
                      i18n.getTraslateValue("saved_message"),
                      style: TextStyle(fontSize: 14),
                    )
                  : FutureBuilder<String>(
                      future: _roomRepo.getRoomDisplayName(userUid),
                      builder: (BuildContext context,
                          AsyncSnapshot<String> snapshot) {
                        if (snapshot.data != null) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                snapshot.data,
                                style: Theme.of(context).textTheme.headline2,
                              ),
                              TitleStatus(
                                currentRoomUid:userUid ,
                                  )
                            ],
                          );
                        } else {
                          return Text("Unknown");
                        }
                      },
                    )
            ],
          ),
          onTap: () {
            userUid.toString().contains(_accountRepo.currentUserUid.toString())
                ? _routingService.openSettings()
                : _routingService.openProfile(userUid.asString());
          },
        ));
  }
}
