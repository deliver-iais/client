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
    return Directionality(
      textDirection: _i18n.defaultTextDirection,
      child: Align(
        alignment: Alignment.centerLeft,
        child: _buildStatusWidget(_getStatus(activity.typeOfActivity), context),
      ),
    );
  }

  String _getStatus(ActivityType typeOfActivity) {
    //todo add empty activities
    switch (typeOfActivity) {
      case ActivityType.CHOOSING_STICKER:
        return "";
      case ActivityType.NO_ACTIVITY:
        return "";
      case ActivityType.RECORDING_VIDEO:
        return "";
      case ActivityType.RECORDING_VOICE:
        return _i18n.get("record_audio_activity");
      case ActivityType.SENDING_FILE:
        return _i18n.get("sending_file_activity");
      case ActivityType.TYPING:
        return _i18n.get("is_typing");
      case ActivityType.SENDING_IMAGE:
        return _i18n.get("sending_image_activity");
      case ActivityType.SENDING_VIDEO:
        return _i18n.get("sending_video_activity");
      case ActivityType.SENDING_VOICE:
        return _i18n.get("sending_voice_activity");
    }
    return "";
  }

  Widget _buildStatusWidget(String status, BuildContext context) {
    if (status.isNotEmpty) {
      if (roomUid.category == Categories.GROUP) {
        return FutureBuilder<String>(
          future: _roomRepo.getName(activity.from),
          builder: (c, s) => RoomName(
            uid: activity.from,
            name: s.data ?? "",
            status: status,
            style: textStyle(context),
          ),
        );
      } else {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              status,
              style: textStyle(context),
            ),
            DotAnimation(dotsColor: Theme.of(context).primaryColor),
          ],
        );
      }
    } else {
      return const SizedBox.shrink();
    }
  }
}
