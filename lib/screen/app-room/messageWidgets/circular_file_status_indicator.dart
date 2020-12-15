import 'package:deliver_flutter/models/sending_status.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/audio_message/play_audio_status.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/file_message.dart/open_file_status.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/load-file-status.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart';
import 'package:flutter/material.dart';

class CircularFileStatusIndicator extends StatelessWidget {
  final bool isExist;
  final SendingStatus sendingStatus;
  final File file;
  final int messageDbId;
  final Function onPressed;

  const CircularFileStatusIndicator(
      {Key key,
      this.isExist,
      this.sendingStatus,
      this.file,
      this.messageDbId,
      this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isExist != null) {
      if (isExist && sendingStatus == null) {
        return file.type.contains("audio") || file.type.contains("mp3")
            ? PlayAudioStatus(
                file: file,
               // dbId: messageDbId,
              )
            : file.type == 'file'
                ? OpenFileStatus(
                    file: file,
                    dbId: messageDbId,
                  )
                : Container();
      } else {
        return new LoadFileStatus(
          file: file,
          dbId: messageDbId,
          onPressed: onPressed,
        );
      }
    }
    return Container();
  }
}
