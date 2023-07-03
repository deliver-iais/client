import 'package:deliver/box/muc.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/mucRepo.dart';
import 'package:deliver/screen/muc/methods/muc_helper_service.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/widgets/circle_avatar.dart';
import 'package:deliver/shared/widgets/room_name.dart';
import 'package:deliver/shared/widgets/title_status.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

const NOTIFICATION_SERVICE = "Notification Service";

class RoomAppbarTitle extends StatelessWidget {
  static final _routingService = GetIt.I.get<RoutingService>();
  static final _i18n = GetIt.I.get<I18N>();
  static final _mucRepo = GetIt.I.get<MucRepo>();
  static final _mucHelper = GetIt.I.get<MucHelperService>();
  final Uid uid;

  const RoomAppbarTitle({super.key, required this.uid});

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
              uid,
              20,
              showSavedMessageLogoIfNeeded: true,
            ),
            const SizedBox(
              width: 16,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RoomName(
                    uid: uid,
                    style: theme.textTheme.titleMedium,
                    showMuteIcon: true,
                    forceToReturnSavedMessage: true,
                  ),
                  _buildTitleStatus(context)
                ],
              ),
            )
          ],
        ),
        onTap: () {
          _routingService.openProfile(uid.asString());
        },
      ),
    );
  }

  Widget _normalConditionText(String text, BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.fade,
      softWrap: false,
      style: theme.textTheme.bodySmall,
    );
  }

  Widget _buildTitleStatus(BuildContext context) {
    final theme = Theme.of(context);
    if (uid.isMuc()) {
      return StreamBuilder<Muc?>(
        stream: _mucRepo.watchMuc(uid),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const SizedBox();
          }
          return _normalConditionText(
            "${snapshot.data!.population} ${_mucHelper.mucAppBarMemberTitle(snapshot.data!.uid)}",
            context,
          );
        },
      );
    } else if (uid.isBot()) {
      return _normalConditionText(_i18n.get("bot"), context);
    } else if (uid.isSystem()) {
      return _normalConditionText(NOTIFICATION_SERVICE, context);
    } else if (uid.isUser()) {
      return TitleStatus(
        currentRoomUid: uid,
        style: theme.textTheme.bodySmall!,
      );
    }
    return const SizedBox();
  }
}
