import 'package:deliver/box/message.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/screen/room/messageWidgets/time_and_seen_status.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/services/url_handler_service.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:deliver/shared/widgets/circle_avatar.dart';
import 'package:deliver/theme/color_scheme.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ShareUidMessageWidget extends StatelessWidget {
  static final _urlHandlerService = GetIt.I.get<UrlHandlerService>();
  static final _roomRepo = GetIt.I.get<RoomRepo>();
  static final _routingServices = GetIt.I.get<RoutingService>();
  static final _i18n = GetIt.I.get<I18N>();

  final Message message;
  final bool isSender;
  final bool isSeen;
  final CustomColorScheme colorScheme;

  const ShareUidMessageWidget({
    super.key,
    required this.message,
    required this.isSender,
    required this.colorScheme,
    required this.isSeen,
  });

  @override
  Widget build(BuildContext context) {
    final shareUid = message.json.toShareUid();
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        top: 4.0,
        bottom: 2.0,
        end: 4,
        start: 4,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          ElevatedButton.icon(
            style:
                ElevatedButton.styleFrom(backgroundColor: colorScheme.primary),
            icon: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: CircleAvatarWidget(
                shareUid.uid,
                14,
                forceText: shareUid.name,
              ),
            ),
            label: Row(
              children: [
                if (shareUid.uid.category == Categories.GROUP)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(start: 4.0),
                    child: Icon(
                      Icons.group_rounded,
                      size: 18,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                if (shareUid.uid.category == Categories.CHANNEL)
                  const Padding(
                    padding: EdgeInsetsDirectional.only(start: 4.0),
                    child: Icon(
                      Icons.rss_feed_rounded,
                      size: 18,
                    ),
                  ),
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 4.0),
                  child: Text(
                    shareUid.name +
                        (shareUid.uid.category != Categories.USER
                            ? " ${_i18n.get("invite_link")}"
                            : ""),
                    style: TextStyle(color: colorScheme.onPrimary),
                  ),
                ),
                const Icon(Icons.chevron_right, size: 18)
              ],
            ),
            onPressed: () async {
              if ((shareUid.uid.category == Categories.GROUP ||
                  shareUid.uid.category == Categories.CHANNEL)) {
                final room = await _roomRepo.getRoom(shareUid.uid);
                if (room != null && !room.deleted) {
                  _routingServices.openRoom(shareUid.uid);
                } else {
                  await _urlHandlerService.handleJoin(
                    shareUid.uid,
                    shareUid.joinToken,
                    name: shareUid.name,
                  );
                }
              } else {
                _routingServices.openRoom(shareUid.uid);
              }
            },
          ),
          TimeAndSeenStatus(
            message,
            isSender: isSender,
            isSeen: isSeen,
            needsPositioned: false,
          ),
        ],
      ),
    );
  }
}
