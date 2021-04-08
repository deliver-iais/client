import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/repository/roomRepo.dart';
import 'package:deliver_public_protocol/pub/v1/models/activity.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pbenum.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ActivityStatuse extends StatelessWidget {
  final Activity activity;
  final TextStyle style;
  final Uid roomUid;

  ActivityStatuse({this.activity, this.style, this.roomUid});

  var _roomRepo = GetIt.I.get<RoomRepo>();

  AppLocalization appLocalization;

  BuildContext buildContext;

  TextStyle textStyle(){
    return TextStyle(fontSize: 14,color: Theme.of(buildContext).primaryColor);
  }

  @override
  Widget build(BuildContext context) {
    buildContext = context;
    appLocalization = AppLocalization.of(context);
    if (activity.typeOfActivity == ActivityType.TYPING) {
      if (roomUid.category == Categories.GROUP) {
        return FutureBuilder<String>(
            future: _roomRepo.getRoomDisplayName(activity.from),
            builder: (c, s) {
              if (s.hasData && s.data != null) {
                return Text(
                  "${s.data} ${appLocalization.getTraslateValue('isTyping')} ",
                  style: textStyle(),
                );
              } else {
                return Text(
                  "unKnown ${appLocalization.getTraslateValue("isTyping")}",
                  style: textStyle(),
                );
              }
            });
      }
      return Text(
        appLocalization.getTraslateValue("isTyping"),
        style: textStyle(),
      );
    } else if (activity.typeOfActivity == ActivityType.RECORDING_VOICE) {
      if (roomUid.category == Categories.GROUP) {
        return FutureBuilder<String>(
            future: _roomRepo.getRoomDisplayName(activity.from),
            builder: (c, s) {
              if (s.hasData && s.data != null) {
                return Text(
                  "${s.data} ${appLocalization.getTraslateValue('recordAudioActivity')} ",
                  style: textStyle(),
                );
              } else {
                return Text(
                  "unKnown ${appLocalization.getTraslateValue("recordAudioActivity")}",
                  style: textStyle(),
                );
              }
            });
      }
      return Text(
        appLocalization.getTraslateValue("recordAudioActivity"),
        style: textStyle(),
      );
    } else if (activity.typeOfActivity == ActivityType.SENDING_FILE) {
      if (roomUid.category == Categories.GROUP) {
        return FutureBuilder<String>(
            future: _roomRepo.getRoomDisplayName(activity.from),
            builder: (c, s) {
              if (s.hasData && s.data != null) {
                return Text(
                  "${s.data} ${appLocalization.getTraslateValue('sendingFileActivity')} ",
                  style: textStyle(),
                );
              } else {
                return Text(
                  "unKnown ${appLocalization.getTraslateValue("sendingFileActivity")}",
                  style: textStyle(),
                );
              }
            });
      }else{
        return Text(
          appLocalization.getTraslateValue("sendingFileActivity"),
          style: textStyle(),
        );
      }
    }
  }
}
