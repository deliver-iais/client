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
  final bool withColor;

  FileDetails({
    super.key,
    required this.file,
    required this.colorScheme,
    required this.maxWidth,
    required this.withColor,
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
              stream: _fileService.watchFileStatus(),
              builder: (context, snapshot) {
                if (snapshot.hasData &&
                    snapshot.data != null &&
                    snapshot.data![file.uuid] == FileStatus.STARTED) {
                  return StreamBuilder<Map<String, double>>(
                    initialData: const {},
                    stream: _fileService.filesProgressBarStatus.stream,
                    builder: (c, map) {
                      final progress = map.data![file.uuid] ?? 0;
                      return _buildText(
                        "${sizeFormatter((progress * file.size.toInt()).toInt())} / ${sizeFormatter(file.size.toInt())}",
                        context,
                      );
                    },
                  );
                } else {
                  return _buildText(
                    "${sizeFormatter(file.size.toInt())}  ${findFileType(file.name)}",
                    context,
                  );
                }
              },
            ),
          );
  }

  Widget _buildText(String text, BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.only(left: 3, right: 3, top: 1, bottom: 1),
        decoration: BoxDecoration(
          color: withColor
              ? Theme.of(context).colorScheme.surface.withOpacity(0.7)
              : null,
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Text(
          text,
          textDirection: TextDirection.ltr,
          style: withColor
              ? Theme.of(context).textTheme.bodySmall!.copyWith(
                    fontSize: 10,
                  )
              : const TextStyle(fontSize: 10),
        ),
      ),
    );
  }
}
