import 'package:deliver/screen/room/messageWidgets/audio_message/audio_play_progress.dart';
import 'package:deliver/screen/room/messageWidgets/size_formater.dart';
import 'package:deliver/shared/methods/find_file_type.dart';
import 'package:deliver/theme/extra_theme.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart';
import 'package:flutter/material.dart';

class HeaderDetails extends StatelessWidget {
  final File file;

  const HeaderDetails({Key? key, required this.file}) : super(key: key);

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
              sizeFormatter(file.size.toInt()) + " " + findFileType(file.name),
              style: TextStyle(
                  fontSize: 10, color: ExtraTheme.of(context).textMessage),
            ),
          );
  }
}
