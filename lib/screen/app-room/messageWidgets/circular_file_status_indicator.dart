import 'package:deliver_flutter/box/message.dart';
import 'package:deliver_flutter/models/sending_status.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/audio_message/play_audio_status.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/file_message.dart/open_file_status.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/load-file-status.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart';
import 'package:flutter/material.dart';

class CircularFileStatusIndicator extends StatelessWidget {
  final bool isExist;
  final SendingStatus sendingStatus;
  final File file;
  final Message msg;
  final Function onPressed;

  const CircularFileStatusIndicator(
      {Key key,
      this.isExist,
      this.sendingStatus,
      this.file,
      this.msg,
      this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isExist != null) {
      if (isExist && sendingStatus == null) {
        return file.type.contains("audio") || file.type.contains("mp3")
            ? PlayAudioStatus(
                fileId: file.uuid,
                fileName: file.name,
                // dbId: messageDbId,
              )
            : OpenFileStatus(
                file: file,
              );
      } else {
        return new LoadFileStatus(
          //file: file,
          fileId: file.uuid,
          fileName: file.name,
          msg: msg,
          onPressed: onPressed,
        );
      }
    }
    return Padding(
      padding: EdgeInsets.only(left: 3, top: 4),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
            shape: BoxShape.circle, color: ExtraTheme.of(context).circularFileStatus),
        child: Icon(
          Icons.arrow_downward,
          color: ExtraTheme.of(context).fileMessageDetails,
          size: 35,
        ),
      ),
    );
  }
}
