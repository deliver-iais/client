import 'package:deliver_flutter/localization/i18n.dart';
import 'package:deliver_flutter/repository/authRepo.dart';
import 'package:deliver_flutter/repository/roomRepo.dart';
import 'package:deliver_flutter/services/routing_service.dart';
import 'package:deliver_flutter/shared/widgets/circle_avatar.dart';
import 'package:deliver_flutter/shared/widgets/title_status.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';

class UserAppbar extends StatelessWidget {
  final _routingService = GetIt.I.get<RoutingService>();
  final _roomRepo = GetIt.I.get<RoomRepo>();
  final _authRepo = GetIt.I.get<AuthRepo>();

  final Uid userUid;

  UserAppbar({Key key, this.userUid}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    I18N i18n = I18N.of(context);
    return Expanded(
      child: Container(
          color: Theme.of(context).appBarTheme.color,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            child: Row(
              children: [
                CircleAvatarWidget(
                  userUid,
                  23,
                  showSavedMessageLogoIfNeeded: true,
                ),
                SizedBox(
                  width: 15,
                ),
                _authRepo.isCurrentUser(userUid.asString())
                    ? Expanded(
                      child: Text(
                          i18n.get("saved_message"),
                          maxLines: 1,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                          style: Theme.of(context).textTheme.headline3,
                        ),
                    )
                    : Expanded(
                        child: FutureBuilder<String>(
                          future: _roomRepo.getName(userUid),
                          builder: (BuildContext context,
                              AsyncSnapshot<String> snapshot) {
                            if (snapshot.data != null) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    (snapshot.data).trim(),
                                    maxLines: 1,
                                    overflow: TextOverflow.fade,
                                    softWrap: false,
                                    style:
                                        Theme.of(context).textTheme.headline2,
                                  ),
                                  TitleStatus(
                                    currentRoomUid: userUid,
                                    normalConditionWidget: userUid.category ==
                                            Categories.SYSTEM
                                        ? Text("Notification Service",
                                            maxLines: 1,
                                            overflow: TextOverflow.fade,
                                            softWrap: false,
                                            style: TextStyle(
                                                fontSize: 11,
                                                color: ExtraTheme.of(context)
                                                    .textDetails))
                                        : const SizedBox.shrink(),
                                  )
                                ],
                              );
                            } else {
                              return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                        width: 200,
                                        height: 20,
                                        decoration: BoxDecoration(
                                            color: Theme.of(context).brightness == Brightness.light
                                                ? Colors.grey[200]
                                                : Colors.grey[800])
                                    ),
                                    SizedBox(height: 6),
                                    Container(
                                        width: 100,
                                        height: 11,
                                        decoration: BoxDecoration(
                                            color: Theme.of(context).brightness == Brightness.light
                                                ? Colors.grey[200]
                                                : Colors.grey[800])
                                    ),
                                  ]);
                            }
                          },
                        ),
                      )
              ],
            ),
            onTap: () {
              _routingService.openProfile(userUid.asString());
            },
          )),
    );
  }
}
