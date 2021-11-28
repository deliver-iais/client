import 'package:deliver/box/message.dart';
import 'package:deliver/screen/room/messageWidgets/audio_message/play_audio_status.dart';
import 'package:deliver/screen/room/messageWidgets/file_message.dart/open_file_status.dart';
import 'package:deliver/screen/room/messageWidgets/load_file_status.dart';
import 'package:deliver/theme/extra_theme.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart';
import 'package:flutter/material.dart';

class CircularFileStatusIndicator extends StatelessWidget {
  final bool? isExist;
  final bool isPending;
  final File file;
  final Message msg;
  final Function onPressed;

  const CircularFileStatusIndicator(
      {Key? key,
      this.isExist,
      this.isPending = false,
      required this.file,
      required this.msg,
      required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isExist != null) {
      if (isExist! && msg.id != null) {
        return file.type.contains("audio")
            ? PlayAudioStatus(
                fileId: file.uuid,
                fileName: file.name,
              )
            : OpenFileStatus(
                file: file,
              );
      } else {
        return LoadFileStatus(
          fileId: file.uuid,
          fileName: file.name,
          messageId: msg.id,
          messagePacketId: msg.packetId,
          roomUid: msg.roomUid,
          onPressed: onPressed,
        );
      }
    }
    return Padding(
      padding: const EdgeInsets.only(left: 3, top: 4),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: ExtraTheme.of(context).circularFileStatus),
        child: Icon(
          Icons.arrow_downward,
          color: ExtraTheme.of(context).fileMessageDetails,
          size: 35,
        ),
      ),
    );
  }
}
