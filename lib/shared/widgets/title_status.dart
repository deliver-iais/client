import 'package:deliver/box/last_activity.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/lastActivityRepo.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/time.dart';
import 'package:deliver/shared/widgets/activity_status.dart';
import 'package:deliver_public_protocol/pub/v1/models/activity.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:random_string/random_string.dart';

class TitleStatus extends StatefulWidget {
  final TextStyle style;
  final Widget normalConditionWidget;
  final Uid? currentRoomUid;

  const TitleStatus(
      {Key? key,
      required this.style,
      this.normalConditionWidget = const SizedBox.shrink(),
      this.currentRoomUid})
      : super(key: key);

  @override
  _TitleStatusState createState() => _TitleStatusState();
}

class _TitleStatusState extends State<TitleStatus> {
  final _roomRepo = GetIt.I.get<RoomRepo>();
  final _lastActivityRepo = GetIt.I.get<LastActivityRepo>();
  final _key = GlobalKey();

  I18N i18n = GetIt.I.get<I18N>();

  @override
  void initState() {
    if (widget.currentRoomUid != null) {
      if (widget.currentRoomUid!.category == Categories.USER) {
        _lastActivityRepo.updateLastActivity(widget.currentRoomUid!);
      }
      _roomRepo.initActivity(widget.currentRoomUid!.node);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.currentRoomUid != null) {
      return activityWidget();
    } else {
      return widget.normalConditionWidget;
    }
  }

  Widget activityWidget() {
    return StreamBuilder<Activity>(
        key: _key,
        stream: _roomRepo.activityObject[widget.currentRoomUid!.node],
        builder: (c, activity) {
          if (activity.hasData && activity.data != null) {
            if (activity.data!.typeOfActivity == ActivityType.NO_ACTIVITY) {
              return normalActivity();
            } else {
              return ActivityStatus(
                activity: activity.data!,
                roomUid: widget.currentRoomUid!,
              );
            }
          } else {
            return normalActivity();
          }
        });
  }

  Widget normalActivity() {
    final theme = Theme.of(context);
    if (widget.currentRoomUid!.category == Categories.USER) {
      return StreamBuilder<LastActivity?>(
          stream: _lastActivityRepo.watch(widget.currentRoomUid!.asString()),
          builder: (c, userInfo) {
            if (userInfo.hasData && userInfo.data != null) {
              if (isOnline(userInfo.data!.time)) {
                return Text(
                  i18n.get("online"),
                  maxLines: 1,
                  key: ValueKey(randomString(10)),
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  style: widget.style.copyWith(color: theme.primaryColor),
                );
              } else {
                final lastActivityTime =
                    dateTimeFormat(date(userInfo.data!.time));
                return Text(
                    "${i18n.get("last_seen")} ${lastActivityTime.contains("just now") ? i18n.get("just_now") : lastActivityTime} ",
                    maxLines: 1,
                    key: ValueKey(randomString(10)),
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    style: widget.style.copyWith(color: theme.primaryColor));
              }
            }
            return const SizedBox.shrink();
          });
    } else {
      return widget.normalConditionWidget;
    }
  }
}
