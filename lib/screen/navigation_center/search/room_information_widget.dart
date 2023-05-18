import 'package:clock/clock.dart';
import 'package:deliver/box/dao/recent_search_dao.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/widgets/circle_avatar.dart';
import 'package:deliver/shared/widgets/room_name.dart';
import 'package:deliver/shared/widgets/title_status.dart';
import 'package:deliver/theme/theme.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class RoomInformationWidget extends StatefulWidget {
  final Uid uid;

  const RoomInformationWidget({Key? key, required this.uid}) : super(key: key);

  @override
  State<RoomInformationWidget> createState() => _RoomInformationWidgetState();
}

class _RoomInformationWidgetState extends State<RoomInformationWidget> {
  final _recentSearch = GetIt.I.get<RecentSearchDao>();
  final _i18n = GetIt.I.get<I18N>();
  final _routingService = GetIt.I.get<RoutingService>();
  final _roomRepo = GetIt.I.get<RoomRepo>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8.0, start: 8.0, top: 8.0),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            _roomRepo.createRoomIfNotExist(widget.uid);
            _recentSearch.addRecentSearch(
              widget.uid.asString(),
              clock.now().millisecondsSinceEpoch,
            );
            _routingService.openRoom(widget.uid.asString());
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                CircleAvatarWidget(
                  widget.uid,
                  26,
                  showSavedMessageLogoIfNeeded: true,
                ),
                const SizedBox(
                  width: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 200,
                      child: RoomName(
                        uid: widget.uid,
                        forceToReturnSavedMessage: true,
                      ),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    _buildRoomStatus(
                      widget.uid,
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoomStatus(Uid uid) {
    switch (uid.category) {
      case Categories.BOT:
        return _buildRoomStatusText(_i18n.get("bot"));
      case Categories.CHANNEL:
        return _buildRoomStatusText(_i18n.get("channel"));
      case Categories.BROADCAST:
        return _buildRoomStatusText(_i18n.get("broadcast"));
      case Categories.GROUP:
        return _buildRoomStatusText(_i18n.get("group"));
      case Categories.STORE:
        return _buildRoomStatusText(_i18n.get("store"));
      case Categories.SYSTEM:
        return _buildRoomStatusText(_i18n.get("system"));
      case Categories.USER:
        return TitleStatus(
          style: getFadeTextStyle(context).copyWith(
            fontSize: 12,
          ),
          currentRoomUid: uid,
          color: Theme.of(context).colorScheme.onSurface.withAlpha(130),
        );
    }
    return const SizedBox();
  }

  Widget _buildRoomStatusText(String text) {
    return Text(
      text,
      style: getFadeTextStyle(context).copyWith(
        fontSize: 12,
      ),
    );
  }
}
