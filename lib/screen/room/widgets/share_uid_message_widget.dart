import 'package:deliver/box/message.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/mucRepo.dart';
import 'package:deliver/screen/room/messageWidgets/time_and_seen_status.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/url.dart';
import 'package:deliver/shared/widgets/circle_avatar.dart';
import 'package:deliver/theme/color_scheme.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ShareUidMessageWidget extends StatelessWidget {
  final Message message;
  final bool isSender;
  final bool isSeen;
  final CustomColorScheme colorScheme;

  final _mucRepo = GetIt.I.get<MucRepo>();
  final _routingServices = GetIt.I.get<RoutingService>();
  final _i18n = GetIt.I.get<I18N>();

  ShareUidMessageWidget({
    Key? key,
    required this.message,
    required this.isSender,
    required this.colorScheme,
    required this.isSeen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _shareUid = message.json.toShareUid();
    return Padding(
      padding: const EdgeInsets.only(top: 4.0, bottom: 2.0, left: 4, right: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(primary: colorScheme.primary),
            icon: Padding(
              padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
              child: CircleAvatarWidget(
                _shareUid.uid,
                14,
                forceText: _shareUid.name,
              ),
            ),
            label: Row(
              children: [
                if (_shareUid.uid.category == Categories.GROUP)
                  const Padding(
                    padding: EdgeInsets.only(left: 4.0),
                    child: Icon(
                      Icons.group_rounded,
                      size: 18,
                    ),
                  ),
                if (_shareUid.uid.category == Categories.CHANNEL)
                  const Padding(
                    padding: EdgeInsets.only(left: 4.0),
                    child: Icon(
                      Icons.rss_feed_rounded,
                      size: 18,
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(left: 4.0),
                  child: Text(
                    _shareUid.name +
                        (_shareUid.uid.category != Categories.USER
                            ? " ${_i18n.get("invite_link")}"
                            : ""),
                  ),
                ),
                const Icon(Icons.chevron_right, size: 18)
              ],
            ),
            onPressed: () async {
              if ((_shareUid.uid.category == Categories.GROUP ||
                  _shareUid.uid.category == Categories.CHANNEL)) {
                final muc = await _mucRepo.getMuc(_shareUid.uid.asString());
                if (muc != null) {
                  _routingServices.openRoom(_shareUid.uid.asString());
                } else {
                  // ignore: use_build_context_synchronously
                  await UrlHandler().handleJoin(
                    context,
                    _shareUid.uid,
                    _shareUid.joinToken,
                    name: _shareUid.name,
                  );
                }
              } else {
                _routingServices.openRoom(_shareUid.uid.asString());
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
