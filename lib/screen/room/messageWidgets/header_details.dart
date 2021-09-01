import 'package:we/screen/room/messageWidgets/audio_message/audio_play_progress.dart';
import 'package:we/screen/room/messageWidgets/size_formater.dart';
import 'package:we/shared/methods/find_file_type.dart';
import 'package:we/theme/extra_theme.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart';
import 'package:flutter/material.dart';

class HeaderDetails extends StatelessWidget {
  final File file;

  const HeaderDetails({Key key, this.file}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return file.type.contains("audio")
        ? AudioPlayProgress(
            audio: file,
            audioUuid: file.uuid,
          )
        : Padding(
            padding: const EdgeInsets.only(top: 26.0, left: 20),
            child: Text(
              sizeFormater(file.size.toInt()) + " " + findFileType(file.name),
              style: TextStyle(
                  fontSize: 10, color: ExtraTheme.of(context).textMessage),
            ),
          );
  }
}
