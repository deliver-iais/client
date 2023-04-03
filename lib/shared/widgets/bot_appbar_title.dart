import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/widgets/circle_avatar.dart';
import 'package:deliver/shared/widgets/room_name.dart';
import 'package:deliver/shared/widgets/title_status.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class BotAppbarTitle extends StatelessWidget {
  static final _routingService = GetIt.I.get<RoutingService>();
  static final _roomRepo = GetIt.I.get<RoomRepo>();

  final Uid botUid;

  const BotAppbarTitle({super.key, required this.botUid});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        child: Row(
          children: [
            CircleAvatarWidget(botUid, 20),
            const SizedBox(
              width: 16,
            ),
            Expanded(
              child: FutureBuilder<String>(
                future: _roomRepo.getName(botUid),
                builder: (c, name) {
                  if (name.hasData && name.data != null) {
                    return buildColumn(name.data!, context);
                  } else {
                    return buildColumn(botUid.node, context);
                  }
                },
              ),
            )
          ],
        ),
        onTap: () {
          _routingService.openProfile(botUid.asString());
        },
      ),
    );
  }

  Column buildColumn(String name, BuildContext context) {
    final theme = Theme.of(context);
    final i18n = GetIt.I.get<I18N>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RoomName(uid: botUid, name: name, style: theme.textTheme.titleMedium),
        TitleStatus(
          currentRoomUid: botUid,
          style: theme.textTheme.bodySmall!,
          normalConditionWidget: Text(
            i18n.get("bot"),
            maxLines: 1,
            overflow: TextOverflow.fade,
            softWrap: false,
            style: theme.textTheme.bodySmall,
          ),
        )
      ],
    );
  }
}
