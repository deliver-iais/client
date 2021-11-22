import 'package:deliver/localization/i18n.dart';
import 'package:deliver/box/last_activity.dart';
import 'package:deliver/repository/lastActivityRepo.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/shared/widgets/activity_status.dart';
import 'package:deliver/shared/methods/time.dart';
import 'package:deliver_public_protocol/pub/v1/models/activity.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/activity.pbenum.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/extensions/cap_extension.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:random_string/random_string.dart';

class TitleStatus extends StatefulWidget {
  final TextStyle style;
  final Widget normalConditionWidget;
  final Uid currentRoomUid;

  TitleStatus(
      {required this.style,
      this.normalConditionWidget = const SizedBox.shrink(),
      required this.currentRoomUid});

  @override
  _TitleStatusState createState() => _TitleStatusState();
}

class _TitleStatusState extends State<TitleStatus> {
  final _messageRepo = GetIt.I.get<MessageRepo>();
  final _roomRepo = GetIt.I.get<RoomRepo>();
  final _lastActivityRepo = GetIt.I.get<LastActivityRepo>();

  I18N i18n = GetIt.I.get<I18N>();

  @override
  void initState() {
    if (widget.currentRoomUid != null) {
      if (widget.currentRoomUid.category == Categories.USER)
        _lastActivityRepo.updateLastActivity(widget.currentRoomUid);
      _roomRepo.initActivity(widget.currentRoomUid.node);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<TitleStatusConditions>(
        stream: _messageRepo.updatingStatus.stream,
        builder: (context, snapshot) {
          return AnimatedSwitcher(
              layoutBuilder: (currentChild, previousChildren) {
                return Container(
                  height: widget.style.fontSize! * 1.5,
                  child: Stack(
                    children: <Widget>[
                      ...previousChildren,
                      if (currentChild != null) currentChild,
                    ],
                    alignment: Alignment.centerLeft,
                  ),
                );
              },
              transitionBuilder: (child, animation) {
                return FadeTransition(
                    opacity: animation,
                    child: SizeTransition(sizeFactor: animation, child: child));
              },
              duration: Duration(milliseconds: 150),
              reverseDuration: Duration(milliseconds: 150),
              child: buildTitle(snapshot));
        });
  }

  Widget buildTitle(AsyncSnapshot<TitleStatusConditions> snapshot) {
    if (snapshot.hasData) {
      switch (snapshot.data) {
        case TitleStatusConditions.Updating:
        case TitleStatusConditions.Disconnected:
        case TitleStatusConditions.Connecting:
          return Text(title(i18n, snapshot.data!),
              maxLines: 1,
              key: ValueKey(randomString(10)),
              overflow: TextOverflow.fade,
              softWrap: false,
              style: widget.style);
          break;
        case TitleStatusConditions.Normal:
          if (widget.currentRoomUid != null)
            return activityWidget();
          else
            return this.widget.normalConditionWidget;
          break;
      }
    }
    return widget.normalConditionWidget;
  }

  title(I18N i18n, TitleStatusConditions statusConditions) {
    switch (statusConditions) {
      case TitleStatusConditions.Disconnected:
        return i18n.get("disconnected").capitalCase;
      case TitleStatusConditions.Connecting:
        return i18n.get("connecting").capitalCase;
      case TitleStatusConditions.Updating:
        return i18n.get("updating").capitalCase;
      case TitleStatusConditions.Normal:
        return i18n.get("connected");
    }
  }

  Widget activityWidget() {
    return StreamBuilder<Activity>(
        key: ValueKey(randomString(10)),
        stream: _roomRepo.activityObject[widget.currentRoomUid.node],
        builder: (c, activity) {
          if (activity.hasData && activity.data != null) {
            if (activity.data!.typeOfActivity == ActivityType.NO_ACTIVITY) {
              return normalActivity();
            } else
              return ActivityStatus(
                activity: activity.data!,
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
      return StreamBuilder<LastActivity?>(
          stream: _lastActivityRepo.watch(widget.currentRoomUid.asString()),
          builder: (c, userInfo) {
            if (userInfo.hasData &&
                userInfo.data != null &&
                userInfo.data!.time != null) {
              if (isOnline(userInfo.data!.time)) {
                return Text(
                  i18n.get("online"),
                  maxLines: 1,
                  key: ValueKey(randomString(10)),
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  style: widget.style
                      .copyWith(color: Theme.of(context).primaryColor),
                );
              } else {
                String lastActivityTime =
                    dateTimeFormat(date(userInfo.data!.time));
                return Text(
                    "${i18n.get("last_seen")} ${lastActivityTime.contains("just now") ? i18n.get("just_now") : lastActivityTime} ",
                    maxLines: 1,
                    key: ValueKey(randomString(10)),
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    style: widget.style
                        .copyWith(color: Theme.of(context).primaryColor));
              }
            }
            return SizedBox.shrink();
          });
    } else {
      return widget.normalConditionWidget;
    }
  }
}
