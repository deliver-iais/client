import 'package:deliver/screen/room/messageWidgets/audio_message/audio_play_progress.dart';
import 'package:deliver/screen/room/messageWidgets/size_formater.dart';
import 'package:deliver/shared/methods/find_file_type.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart';
import 'package:flutter/material.dart';

class FileDetails extends StatelessWidget {
  final File file;

  const FileDetails({Key? key, required this.file}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return file.type.contains("audio")
        ? AudioPlayProgress(
            audio: file,
            audioUuid: file.uuid,
          )
        : Text(
            sizeFormatter(file.size.toInt()) + " " + findFileType(file.name),
            style: const TextStyle(fontSize: 10),
          );
  }
}
