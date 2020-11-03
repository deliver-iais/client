import 'dart:ui';

import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/db/dao/GroupDao.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/repository/contactRepo.dart';
import 'package:deliver_flutter/repository/roomRepo.dart';
import 'package:deliver_flutter/services/routing_service.dart';
import 'package:deliver_flutter/shared/circleAvatar.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/user.pb.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';

class UserAppbar extends StatelessWidget {
  final Uid userUid;

  UserAppbar({Key key, this.userUid}) : super(key: key);

  var _routingService = GetIt.I.get<RoutingService>();
  var _roomRepo = GetIt.I.get<RoomRepo>();
  var _contactRepo = GetIt.I.get<ContactRepo>();
  var _accountRepo = GetIt.I.get<AccountRepo>();
  AppLocalization _appLocalization;

  @override
  Widget build(BuildContext context) {
    _appLocalization = AppLocalization.of(context);
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
                      _appLocalization.getTraslateValue("saved_message"),
                      style: TextStyle(fontSize: 14),
                    )
                  : FutureBuilder<String>(
                      future: _roomRepo.getRoomDisplayName(userUid),
                      builder: (BuildContext context,
                          AsyncSnapshot<String> snapshot) {
                        if (snapshot.data != null) {
                          return Column(
                            children: [
                              Text(
                                snapshot.data,
                                style: TextStyle(fontSize: 14),
                              ),
                              //       Text("last seen",style: TextStyle(fontSize: 12),) //todo last seen
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
                : _routingService.openProfile(userUid.string);
          },
        ));
  }
}
