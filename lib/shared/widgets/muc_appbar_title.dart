import 'package:deliver/localization/i18n.dart';
import 'package:deliver/box/muc.dart';
import 'package:deliver/repository/mucRepo.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/widgets/circle_avatar.dart';
import 'package:deliver/shared/widgets/title_status.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';

class MucAppbarTitle extends StatelessWidget {
  final _routingService = GetIt.I.get<RoutingService>();
  final _mucRepo = GetIt.I.get<MucRepo>();
  final String mucUid;

  MucAppbarTitle({Key key, this.mucUid}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    I18N i18n = I18N.of(context);
    return Container(
        color: Theme.of(context).appBarTheme.color,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            child: Row(
              children: [
                CircleAvatarWidget(mucUid.asUid(), 23),
                SizedBox(
                  width: 16,
                ),
                Expanded(
                  child: StreamBuilder<Muc>(
                      stream: _mucRepo.watchMuc(mucUid),
                      builder: (context, snapshot) {
                        if (snapshot.hasData)
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                snapshot.data.name,
                                maxLines: 1,
                                overflow: TextOverflow.fade,
                                softWrap: false,
                                style: Theme.of(context).textTheme.subtitle1,
                              ),
                              TitleStatus(
                                style: Theme.of(context).textTheme.caption,
                                normalConditionWidget: Text(
                                  "${snapshot.data.population} ${i18n.get("members")}",
                                  maxLines: 1,
                                  overflow: TextOverflow.fade,
                                  softWrap: false,
                                  style: Theme.of(context).textTheme.caption,
                                ),
                                currentRoomUid: mucUid.asUid(),
                              )
                            ],
                          );
                        else
                          return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                    width: 200,
                                    height: 20,
                                    decoration: BoxDecoration(
                                        color: Theme.of(context).brightness ==
                                                Brightness.light
                                            ? Colors.grey[200]
                                            : Colors.grey[800])),
                                SizedBox(height: 6),
                                Container(
                                    width: 100,
                                    height: 11,
                                    decoration: BoxDecoration(
                                        color: Theme.of(context).brightness ==
                                                Brightness.light
                                            ? Colors.grey[200]
                                            : Colors.grey[800])),
                              ]);
                      }),
                )
              ],
            ),
            onTap: () {
              _routingService.openProfile(mucUid);
            },
          ),
        ));
  }
}
