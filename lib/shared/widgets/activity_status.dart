import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/shared/widgets/dot_animation/dot_animation.dart';
import 'package:deliver/shared/widgets/room_name.dart';
import 'package:deliver_public_protocol/pub/v1/models/activity.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pbenum.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ActivityStatus extends StatelessWidget {
  static final _roomRepo = GetIt.I.get<RoomRepo>();
  static final _i18n = GetIt.I.get<I18N>();

  final Activity activity;
  final Uid roomUid;

  const ActivityStatus({
    super.key,
    required this.activity,
    required this.roomUid,
  });

  TextStyle textStyle(BuildContext context) {
    return TextStyle(fontSize: 14, color: Theme.of(context).primaryColor);
  }

  @override
  Widget build(BuildContext context) {
    if (activity.typeOfActivity == ActivityType.TYPING) {
      if (roomUid.category == Categories.GROUP) {
        return FutureBuilder<String>(
          future: _roomRepo.getName(activity.from),
          builder: (c, s) => RoomName(
            shouldShowDotAnimation: true,
            uid: activity.from,
            name: "${s.data ?? ""} ${_i18n.get('is_typing')}",
            style: textStyle(context),
          ),
        );
      } else {
        return Row(
          children: [
            Text(
              _i18n.get("is_typing"),
              style: textStyle(context),
            ),
            DotAnimation(dotsColor: Theme.of(context).primaryColor),
          ],
        );
      }
    } else if (activity.typeOfActivity == ActivityType.RECORDING_VOICE) {
      if (roomUid.category == Categories.GROUP) {
        return FutureBuilder<String>(
          future: _roomRepo.getName(activity.from),
          builder: (c, s) => RoomName(
            uid: activity.from,
            name: "${s.data ?? ""} ${_i18n.get("record_audio_activity")}",
            style: textStyle(context),
          ),
        );
      }
      return Text(
        _i18n.get("record_audio_activity"),
        style: textStyle(context),
      );
    } else if (activity.typeOfActivity == ActivityType.SENDING_FILE) {
      if (roomUid.category == Categories.GROUP) {
        return FutureBuilder<String>(
          future: _roomRepo.getName(activity.from),
          builder: (c, s) => RoomName(
            uid: activity.from,
            name: "${s.data ?? ""} ${_i18n.get('sending_file_activity')}",
            style: textStyle(context),
          ),
        );
      } else {
        return Text(
          _i18n.get("sending_file_activity"),
          style: textStyle(context),
        );
      }
    } else {
      return const SizedBox.shrink();
    }
  }
}
