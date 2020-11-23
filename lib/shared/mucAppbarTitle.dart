import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/db/dao/MucDao.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/services/routing_service.dart';
import 'package:deliver_flutter/shared/circleAvatar.dart';
import 'package:deliver_flutter/shared/title_status.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';

class MucAppbarTitle extends StatelessWidget {
  final String mucUid;

  MucAppbarTitle({Key key, this.mucUid}) : super(key: key);

  var _routingService = GetIt.I.get<RoutingService>();
  var _mucDao = GetIt.I.get<MucDao>();

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
                  stream: _mucDao.getByUid(mucUid),
                  builder: (context, snapshot) {
                    if (snapshot.hasData)
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            snapshot.data.name,
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          DefaultTextStyle(
                            style: TextStyle(fontSize: 11),
                            child: TitleStatus(
                                normalConditionWidget: Text(
                              '${snapshot.data.members} ' +
                                  appLocalization.getTraslateValue("members"),
                            )),
                          )
                        ],
                      );
                    else
                      return Container();
                  })
            ],
          ),
          onTap: () {
            _routingService.openProfile(mucUid);
          },
        ));
  }
}
