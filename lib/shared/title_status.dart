import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/db/dao/RoomDao.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/repository/messageRepo.dart';
import 'package:deliver_flutter/repository/roomRepo.dart';
import 'package:deliver_flutter/shared/activityStatuse.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/event.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/event.pbenum.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';
import 'package:deliver_flutter/shared/methods/dateTimeFormat.dart';
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

  final _roomDao = GetIt.I.get<RoomDao>();

  AppLocalization appLocalization;

  @override
  void initState() {
    _messageRepo.getLastActivityTime(widget.currentRoomUid);
  }

  @override
  Widget build(BuildContext context) {
    appLocalization = AppLocalization.of(context);
    return StreamBuilder<TitleStatusConditions>(
        stream: _messageRepo.updatingStatus.stream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            switch (snapshot.data) {
              case TitleStatusConditions.Normal:
                return activityWidget();
                break;
              case TitleStatusConditions.Updating:
              case TitleStatusConditions.Disconnected:
              case TitleStatusConditions.Connecting:
                return Text(title(appLocalization, snapshot.data),
                    style: this.widget.style);
                break;
            }
            if (snapshot.data == TitleStatusConditions.Normal &&
                this.widget.normalConditionWidget != null) {
              return this.widget.normalConditionWidget;
            } else {
              return Text(title(appLocalization, snapshot.data),
                  style: this.widget.style);
            }
          }
          return widget.normalConditionWidget;
        });
  }

  title(
      AppLocalization appLocalization, TitleStatusConditions statusConditions) {
    switch (statusConditions) {
      case TitleStatusConditions.Disconnected:
        return appLocalization.getTraslateValue("disconnected");
      case TitleStatusConditions.Connecting:
        return appLocalization.getTraslateValue("connecting");
      case TitleStatusConditions.Updating:
        return appLocalization.getTraslateValue("updating");
      case TitleStatusConditions.Normal:
        if (_roomRepo.activityObject[widget.currentRoomUid] != null) {
          _roomRepo.activityObject[widget.currentRoomUid].listen((activity) {
            switch (activity.typeOfActivity) {
              case ActivityType.NO_ACTIVITY:
                return _showLastActivity();
                break;
              case ActivityType.TYPING:
                break;

              case ActivityType.RECORDING_VOICE:
                break;

              case ActivityType.SENDING_FILE:
                break;
            }
          });
        } else {
          return appLocalization.getTraslateValue("connected");
        }
    }
  }

  Future<String> _showLastActivity() async {
    Room room =
        await _roomDao.getByRoomIdFuture(widget.currentRoomUid.asString());
    if (room != null) {
      return room.toString();
    } else {
      return appLocalization.getTraslateValue("connected");
    }
  }

  Widget activityWidget() {
    return StreamBuilder<Activity>(
        stream: _roomRepo.activityObject[widget.currentRoomUid],
        builder: (c, activity) {
          if (activity.hasData && activity.data != null) {
            if (activity.data.typeOfActivity == ActivityType.NO_ACTIVITY) {
              return normalActivity();
            }else
              return ActivityStatuse(activity: activity.data,roomUid: widget.currentRoomUid,style: widget.style,);
          } else {
            return normalActivity();
          }
        });
  }

  Widget normalActivity() {
    if (widget.currentRoomUid.category == Categories.USER) {
      return StreamBuilder<Room>(
          stream: _roomDao.getByRoomId(widget.currentRoomUid.asString()),
          builder: (c, room) {
            if (room.hasData &&
                room.data != null &&
                room.data.lastActivity != null) {
              String lastActivityTime = room.data.lastActivity.dateTimeFormat();
              return Text(
                  "${appLocalization.getTraslateValue('lastSeen')} ${lastActivityTime} ");
            }
            return SizedBox.shrink();
          });
    } else {
      return widget.normalConditionWidget;
    }
  }
}
