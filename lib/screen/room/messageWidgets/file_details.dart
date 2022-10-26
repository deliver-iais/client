import 'package:deliver/screen/room/messageWidgets/audio_message/audio_play_progress.dart';
import 'package:deliver/screen/room/messageWidgets/size_formatter.dart';
import 'package:deliver/services/file_service.dart';
import 'package:deliver/shared/methods/find_file_type.dart';
import 'package:deliver/theme/color_scheme.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class FileDetails extends StatelessWidget {
  final File file;
  final double maxWidth;
  final CustomColorScheme colorScheme;

  FileDetails({
    super.key,
    required this.file,
    required this.colorScheme,
    required this.maxWidth,
  });

  final _fileService = GetIt.I.get<FileService>();

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
            height: 15,
            child: StreamBuilder<Map<String, FileStatus>>(
              stream: _fileService.fileStatus.stream,
              builder: (context, snapshot) {
                if (snapshot.hasData &&
                    snapshot.data != null &&
                    snapshot.data![file.uuid] == FileStatus.STARTED) {
                  return StreamBuilder<Map<String, double>>(
                    initialData: const {},
                    stream: _fileService.filesProgressBarStatus.stream,
                    builder: (c, map) {
                      final progress = map.data![file.uuid] ?? 0.001;
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "${sizeFormatter((progress * file.size.toInt()).toInt())} / ${sizeFormatter(file.size.toInt())}",
                          style: const TextStyle(fontSize: 10),
                        ),
                      );
                    },
                  );
                }
                return Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "${sizeFormatter(file.size.toInt())} ${findFileType(file.name)}",
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          );
  }
}
