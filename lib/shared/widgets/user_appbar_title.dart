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

const NOTIFICATION_SERVICE = "Notification Service";

class UserAppbarTitle extends StatelessWidget {
  static final _routingService = GetIt.I.get<RoutingService>();
  static final _roomRepo = GetIt.I.get<RoomRepo>();
  static final _authRepo = GetIt.I.get<AuthRepo>();
  static final _i18n = GetIt.I.get<I18N>();

  final Uid userUid;
  final Future<String> _name;

  UserAppbarTitle({super.key, required this.userUid})
      : _name = _getName(userUid);

  static Future<String> _getName(Uid uid) =>
      _authRepo.isCurrentUser(uid.asString())
          ? Future.value(_i18n.get("saved_message"))
          : _roomRepo.getName(uid);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        child: Row(
          children: [
            CircleAvatarWidget(
              userUid,
              23,
              showSavedMessageLogoIfNeeded: true,
            ),
            const SizedBox(
              width: 16,
            ),
            Expanded(
              child: FutureBuilder<String>(
                future: _name,
                builder: (context, snapshot) {
                  if (snapshot.data != null) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RoomName(
                          uid: userUid,
                          name: (snapshot.data)!.trim(),
                          style: theme.textTheme.subtitle1,
                        ),
                        TitleStatus(
                          currentRoomUid: userUid,
                          style: theme.textTheme.caption!,
                          normalConditionWidget:
                              userUid.category == Categories.SYSTEM
                                  ? Text(
                                      NOTIFICATION_SERVICE,
                                      maxLines: 1,
                                      overflow: TextOverflow.fade,
                                      softWrap: false,
                                      style: theme.textTheme.caption,
                                    )
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
                            color: theme.brightness == Brightness.light
                                ? Colors.grey[200]
                                : Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: 100,
                          height: 11,
                          decoration: BoxDecoration(
                            color: theme.brightness == Brightness.light
                                ? Colors.grey[200]
                                : Colors.grey[800],
                          ),
                        ),
                      ],
                    );
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
