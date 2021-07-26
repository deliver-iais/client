import 'package:deliver_flutter/Localization/i18n.dart';
import 'package:deliver_flutter/box/last_activity.dart';
import 'package:deliver_flutter/repository/lastActivityRepo.dart';
import 'package:deliver_flutter/repository/messageRepo.dart';
import 'package:deliver_flutter/repository/roomRepo.dart';
import 'package:deliver_flutter/shared/widgets/activity_status.dart';
import 'package:deliver_flutter/shared/methods/time.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:deliver_public_protocol/pub/v1/models/activity.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/activity.pbenum.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';
import 'package:deliver_flutter/shared/extensions/cap_extension.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class TitleStatus extends StatefulWidget {
  final TextStyle style;
  final Widget normalConditionWidget;
  final Uid currentRoomUid;

  TitleStatus(
      {this.style,
      this.normalConditionWidget = const SizedBox.shrink(),
      this.currentRoomUid});

  @override
  _TitleStatusState createState() => _TitleStatusState();
}

class _TitleStatusState extends State<TitleStatus> {
  final _messageRepo = GetIt.I.get<MessageRepo>();
  final _roomRepo = GetIt.I.get<RoomRepo>();
  final _lastActivityRepo = GetIt.I.get<LastActivityRepo>();

  I18N i18n;

  @override
  void initState() {
    if (widget.currentRoomUid.category == Categories.USER)
      _lastActivityRepo.updateLastActivity(widget.currentRoomUid);
    _roomRepo.initActivity(widget.currentRoomUid.node);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    i18n = I18N.of(context);
    return StreamBuilder<TitleStatusConditions>(
        stream: _messageRepo.updatingStatus.stream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            switch (snapshot.data) {
              case TitleStatusConditions.Normal:
                if (widget.currentRoomUid.category == Categories.BOT)
                  return Text(title(i18n, snapshot.data),
                      maxLines: 1,
                      overflow: TextOverflow.fade,
                      softWrap: false,
                      style: TextStyle(
                          fontSize: 12,
                          color: ExtraTheme.of(context).textDetails));
                else
                  return activityWidget();
                break;
              case TitleStatusConditions.Updating:
              case TitleStatusConditions.Disconnected:
              case TitleStatusConditions.Connecting:
                return Text(title(i18n, snapshot.data),
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    style: TextStyle(
                        fontSize: 12,
                        color: ExtraTheme.of(context).textDetails));
                break;
            }
            if (snapshot.data == TitleStatusConditions.Normal &&
                this.widget.normalConditionWidget != null) {
              return this.widget.normalConditionWidget;
            } else {
              return Text(title(i18n, snapshot.data),
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  style: this.widget.style);
            }
          }
          return widget.normalConditionWidget;
        });
  }

  title(
      I18N i18n, TitleStatusConditions statusConditions) {
    switch (statusConditions) {
      case TitleStatusConditions.Disconnected:
        return i18n.get("disconnected").capitalCase;
      case TitleStatusConditions.Connecting:
        return i18n.get("connecting").capitalCase;
      case TitleStatusConditions.Updating:
        return i18n.get("updating").capitalCase;
      case TitleStatusConditions.Normal:
        if (widget.currentRoomUid.category == Categories.BOT)
          return i18n.get("bot").capitalCase;
        return i18n.get("connected");
    }
  }

  Widget activityWidget() {
    return StreamBuilder<Activity>(
        stream: _roomRepo.activityObject[widget.currentRoomUid.node],
        builder: (c, activity) {
          if (activity.hasData && activity.data != null) {
            if (activity.data.typeOfActivity == ActivityType.NO_ACTIVITY) {
              return normalActivity();
            } else
              return ActivityStatus(
                activity: activity.data,
                roomUid: widget.currentRoomUid,
                style: widget.style,
              );
          } else {
            return normalActivity();
          }
        });
  }

  Widget normalActivity() {
    if (widget.currentRoomUid.category == Categories.USER) {
      return StreamBuilder<LastActivity>(
          stream: _lastActivityRepo.watch(widget.currentRoomUid.asString()),
          builder: (c, userInfo) {
            if (userInfo.hasData &&
                userInfo.data != null &&
                userInfo.data.time != null) {
              if (isOnline(userInfo.data.time)) {
                return Text(
                  i18n.get("online"),
                  style: TextStyle(
                      fontSize: 14, color: ExtraTheme.of(context).titleStatus),
                );
              } else {
                String lastActivityTime =
                    dateTimeFormat(date(userInfo.data.time));
                return Text(
                  "${i18n.get("last_seen")} ${lastActivityTime.contains("just now") ? i18n.get("just_now") : lastActivityTime} ",
                  style: TextStyle(
                      fontSize: 12, color: ExtraTheme.of(context).titleStatus),
                );
              }
            }
            return SizedBox.shrink();
          });
    } else {
      return widget.normalConditionWidget;
    }
  }
}
