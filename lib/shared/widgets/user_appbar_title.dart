import 'package:deliver/debug/commons_widgets.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/widgets/circle_avatar.dart';
import 'package:deliver/shared/widgets/room_name.dart';
import 'package:deliver/shared/widgets/title_status.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class UserAppbarTitle extends StatelessWidget {
  final _routingService = GetIt.I.get<RoutingService>();
  final _roomRepo = GetIt.I.get<RoomRepo>();
  final _authRepo = GetIt.I.get<AuthRepo>();
  final _i18n = GetIt.I.get<I18N>();

  final Uid userUid;

  UserAppbarTitle({Key? key, required this.userUid}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        child: Row(
          children: [
            if (isDebugEnabled())
              DebugC(
                children: [Debug(userUid.asString(), label: "uid")],
              ),
            CircleAvatarWidget(
              userUid,
              23,
              showSavedMessageLogoIfNeeded: true,
            ),
            const SizedBox(
              width: 16,
            ),
            _authRepo.isCurrentUser(userUid.asString())
                ? Expanded(
                    child: Text(
                      _i18n.get("saved_message"),
                      maxLines: 1,
                      overflow: TextOverflow.fade,
                      softWrap: false,
                      style: theme.textTheme.subtitle1,
                    ),
                  )
                : Expanded(
                    child: FutureBuilder<String>(
                      future: _roomRepo.getName(userUid),
                      builder: (context, snapshot) {
                        if (snapshot.data != null) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RoomName(
                                  uid: userUid,
                                  name: (snapshot.data)!.trim(),
                                  style: theme.textTheme.subtitle1),
                              TitleStatus(
                                currentRoomUid: userUid,
                                style: theme.textTheme.caption!,
                                normalConditionWidget:
                                    userUid.category == Categories.SYSTEM
                                        ? Text("Notification Service",
                                            maxLines: 1,
                                            overflow: TextOverflow.fade,
                                            softWrap: false,
                                            style: theme.textTheme.caption)
                                        : const SizedBox(),
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
                                        color:
                                            theme.brightness == Brightness.light
                                                ? Colors.grey[200]
                                                : Colors.grey[800])),
                                const SizedBox(height: 6),
                                Container(
                                    width: 100,
                                    height: 11,
                                    decoration: BoxDecoration(
                                        color:
                                            theme.brightness == Brightness.light
                                                ? Colors.grey[200]
                                                : Colors.grey[800])),
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
      ),
    );
  }
}
