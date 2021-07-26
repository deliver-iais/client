import 'package:deliver_flutter/Localization/i18n.dart';
import 'package:deliver_flutter/repository/roomRepo.dart';
import 'package:deliver_public_protocol/pub/v1/models/activity.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pbenum.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ActivityStatus extends StatelessWidget {
  final Activity activity;
  final TextStyle style;
  final Uid roomUid;
  final _roomRepo = GetIt.I.get<RoomRepo>();

  ActivityStatus({this.activity, this.style, this.roomUid});
  
  TextStyle textStyle(BuildContext context) {
    return TextStyle(fontSize: 14, color: Theme.of(context).primaryColor);
  }

  @override
  Widget build(BuildContext context) {
    var i18n = I18N.of(context);
    if (activity.typeOfActivity == ActivityType.TYPING) {
      if (roomUid.category == Categories.GROUP) {
        return FutureBuilder<String>(
            future: _roomRepo.getName(activity.from),
            builder: (c, s) {
              if (s.hasData && s.data != null) {
                return Text(
                  "${s.data} ${i18n.get('is_typing')}",
                  style: textStyle(context),
                );
              } else {
                return Text(
                  "unKnown ${i18n.get("is_typing")}",
                  style: textStyle(context),
                );
              }
            });
      } else {
        return Text(
          i18n.get("is_typing"),
          style: textStyle(context),
        );
      }
    } else if (activity.typeOfActivity == ActivityType.RECORDING_VOICE) {
      if (roomUid.category == Categories.GROUP) {
        return FutureBuilder<String>(
            future: _roomRepo.getName(activity.from),
            builder: (c, s) {
              if (s.hasData && s.data != null) {
                return Text(
                  "${s.data} ${i18n.get('record_audio_activity')} ",
                  style: textStyle(context),
                );
              } else {
                return Text(
                  "unKnown ${i18n.get("record_audio_activity")}",
                  style: textStyle(context),
                );
              }
            });
      }
      return Text(
        i18n.get("record_audio_activity"),
        style: textStyle(context),
      );
    } else if (activity.typeOfActivity == ActivityType.SENDING_FILE) {
      if (roomUid.category == Categories.GROUP) {
        return FutureBuilder<String>(
            future: _roomRepo.getName(activity.from),
            builder: (c, s) {
              if (s.hasData && s.data != null) {
                return Text(
                  "${s.data} ${i18n.get('sending_file_activity')} ",
                  style: textStyle(context),
                );
              } else {
                return Text(
                  "unKnown ${i18n.get("sending_file_activity")}",
                  style: textStyle(context),
                );
              }
            });
      } else {
        return Text(
          i18n.get("sending_file_activity"),
          style: textStyle(context),
        );
      }
    } else {
      return SizedBox.shrink();
    }
  }
}
