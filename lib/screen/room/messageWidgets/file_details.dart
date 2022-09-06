import 'package:deliver/screen/room/messageWidgets/audio_message/audio_play_progress.dart';
import 'package:deliver/screen/room/messageWidgets/size_formatter.dart';
import 'package:deliver/shared/methods/find_file_type.dart';
import 'package:deliver/theme/color_scheme.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart';
import 'package:flutter/material.dart';

class FileDetails extends StatelessWidget {
  final File file;
  final double maxWidth;
  final CustomColorScheme colorScheme;

  const FileDetails({
    super.key,
    required this.file,
    required this.colorScheme,
    required this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    return file.type.contains("audio")
        ? AudioPlayProgress(
            maxWidth: maxWidth,
            audio: file,
            audioUuid: file.uuid,
            colorScheme: colorScheme,
          )
        : SizedBox(
            height: 40,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "${sizeFormatter(file.size.toInt())} ${findFileType(file.name)}",
                style: const TextStyle(fontSize: 10),
              ),
            ),
          );
  }
}
