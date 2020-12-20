import 'package:deliver_flutter/screen/app-room/messageWidgets/audio_message/audio_play_progress.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/size_formater.dart';
import 'package:deliver_flutter/shared/methods/find_file_type.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart';
import 'package:flutter/material.dart';

class HeaderDetails extends StatelessWidget {
  final String loadStatus;
  final double loadProgress;
  final File file;

  const HeaderDetails({Key key, this.loadStatus, this.loadProgress, this.file})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return loadStatus != 'loaded'
        ? Padding(
            padding: const EdgeInsets.only(top: 26.0, left: 20),
            child: Text(
              sizeFormater((loadProgress * file.size.toDouble()).round()) +
                  ' / ' +
                  sizeFormater(file.size.toInt()) +
                  " " +
                  findFileType(file.name),
              style: TextStyle(fontSize: 10),
            ),
          )
        : file.type == 'file'
            ? Padding(
                padding: const EdgeInsets.only(top: 26.0, left: 20),
                child: Text(
                  sizeFormater(file.size.toInt()) +
                      " " +
                      findFileType(file.name),
                  style: TextStyle(fontSize: 10),
                ),
              )
            : AudioPlayProgress(
                //audio: file,
                audioUuid: file.uuid,
              );
  }
}
