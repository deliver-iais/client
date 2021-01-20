import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/repository/roomRepo.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pbenum.dart';
import 'package:deliver_public_protocol/pub/v1/models/event.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';

class ActivityStatuse extends StatelessWidget {
  final Activity activity;
  final TextStyle style;
  final Uid roomUid;

  ActivityStatuse({this.activity, this.style, this.roomUid});

  var _roomRepo = GetIt.I.get<RoomRepo>();

  AppLocalization appLocalization;

  @override
  Widget build(BuildContext context) {
    appLocalization = AppLocalization.of(context);
    if (activity.typeOfActivity == ActivityType.TYPING) {
      if (roomUid.category == Categories.GROUP) {
        return FutureBuilder<String>(
            future: _roomRepo.getRoomDisplayName(activity.from),
            builder: (c, s) {
              if (s.hasData && s.data != null) {
                return Text(
                  "$s ${appLocalization.getTraslateValue('isTyping')} ",
                  style: style,
                );
              } else {
                return Text(
                  "unKnoun ${appLocalization.getTraslateValue("isTyping")}",
                  style: style,
                );
              }
            });
      }
      return Text(
        appLocalization.getTraslateValue("isTyping"),
        style: this.style,
      );
    } else if (activity.typeOfActivity == ActivityType.RECORDING_VOICE) {
      if (roomUid.category == Categories.GROUP) {
        return FutureBuilder<String>(
            future: _roomRepo.getRoomDisplayName(activity.from),
            builder: (c, s) {
              if (s.hasData && s.data != null) {
                return Text(
                  "$s ${appLocalization.getTraslateValue('recordAudioActivity')} ",
                  style: style,
                );
              } else {
                return Text(
                  "unKnoun ${appLocalization.getTraslateValue("recordAudioActivity")}",
                  style: style,
                );
              }
            });
      }
      return Text(
        appLocalization.getTraslateValue("recordAudioActivity"),
        style: this.style,
      );
    } else if (activity.typeOfActivity == ActivityType.SENDING_FILE) {
    } else {
      return FutureBuilder<String>(
          future: _roomRepo.getRoomDisplayName(activity.from),
          builder: (c, s) {
            if (s.hasData && s.data != null) {
              return Text(
                "$s ${appLocalization.getTraslateValue('sendingFileActivity')} ",
                style: style,
              );
            } else {
              return Text(
                "unKnoun ${appLocalization.getTraslateValue("sendingFileActivity")}",
                style: style,
              );
            }
          });
    }
    return Text(
      appLocalization.getTraslateValue("sendingFileActivity"),
      style: this.style,
    );
  }
}
