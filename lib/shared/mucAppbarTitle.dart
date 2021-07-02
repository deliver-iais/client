import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/box/dao/muc_dao.dart';
import 'package:deliver_flutter/box/muc.dart';
import 'package:deliver_flutter/services/routing_service.dart';
import 'package:deliver_flutter/shared/circleAvatar.dart';
import 'package:deliver_flutter/shared/title_status.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';

class MucAppbarTitle extends StatelessWidget {
  final _routingService = GetIt.I.get<RoutingService>();
  final _mucDao = GetIt.I.get<MucDao>();
  final String mucUid;

  MucAppbarTitle({Key key, this.mucUid}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppLocalization appLocalization = AppLocalization.of(context);
    return Container(
        color: Theme.of(context).appBarTheme.color,
        child: GestureDetector(
          child: Row(
            children: [
              CircleAvatarWidget(mucUid.uid, 23),
              SizedBox(
                width: 20,
              ),
              StreamBuilder<Muc>(
                  stream: _mucDao.watch(mucUid),
                  builder: (context, snapshot) {
                    if (snapshot.hasData)
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            snapshot.data.name,
                            style: Theme.of(context).textTheme.headline2,
                          ),
                          TitleStatus(
                            normalConditionWidget: Text(
                              "${snapshot.data.population} ${appLocalization.getTraslateValue("members")}",
                              style: TextStyle(
                                  fontSize: 11,
                                  color: ExtraTheme.of(context).textDetails),
                            ),
                            currentRoomUid: mucUid.uid,
                          )
                        ],
                      );
                    else
                      return FutureBuilder<Muc>(
                          future: _mucDao.get(mucUid),
                          builder: (c, s) {
                            if (s.hasData && s.data != null) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    s.data.name,
                                    style:
                                        Theme.of(context).textTheme.headline2,
                                  ),
                                  TitleStatus(
                                    normalConditionWidget: Text(
                                      "${s.data.population} ${appLocalization.getTraslateValue("members")}",
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: ExtraTheme.of(context)
                                              .textDetails),
                                    ),
                                    currentRoomUid: mucUid.uid,
                                  )
                                ],
                              );
                            } else {
                              return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        AppLocalization.of(context)
                                            .getTraslateValue("loading"),
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: ExtraTheme.of(context)
                                                .textDetails))
                                  ]);
                            }
                          });
                  })
            ],
          ),
          onTap: () {
            _routingService.openProfile(mucUid);
          },
        ));
  }
}
