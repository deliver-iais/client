import 'package:deliver/box/message.dart';
import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/screen/room/messageWidgets/audio_message/play_audio_status.dart';
import 'package:deliver/screen/room/messageWidgets/file_message.dart/open_file_status.dart';
import 'package:deliver/screen/room/messageWidgets/load_file_status.dart';
import 'package:deliver/services/file_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class CircularFileStatusIndicator extends StatefulWidget {
  final Message message;
  final Color backgroundColor;
  final Color foregroundColor;

  const CircularFileStatusIndicator({
    super.key,
    required this.message,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  @override
  State<CircularFileStatusIndicator> createState() =>
      _CircularFileStatusIndicatorState();
}

class _CircularFileStatusIndicatorState
    extends State<CircularFileStatusIndicator> {
  static final _fileServices = GetIt.I.get<FileService>();
  static final _fileRepo = GetIt.I.get<FileRepo>();

  @override
  void initState() {
    _fileServices.initProgressBar(widget.message.json.toFile().uuid);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final file = widget.message.json.toFile();
    return FutureBuilder<String?>(
      future: _fileRepo.getFileIfExist(file.uuid, file.name),
      builder: (c, fileSnapShot) {
        if (fileSnapShot.hasData &&
            fileSnapShot.data != null &&
            widget.message.id != null) {
          return showExitFile(file, fileSnapShot.data!);
        } else {
          return StreamBuilder<double>(
            stream: _fileServices.filesProgressBarStatus[file.uuid],
            builder: (context, snapshot) {
              if (snapshot.hasData &&
                  snapshot.data != null &&
                  snapshot.data == DOWNLOAD_COMPLETE) {
                return FutureBuilder<String?>(
                  future: _fileRepo.getFileIfExist(file.uuid, file.name),
                  builder: (c, s) {
                    if (s.hasData && s.data != null) {
                      return showExitFile(file, s.data!);
                    } else {
                      return LoadFileStatus(
                        fileId: file.uuid,
                        fileName: file.name,
                        isPendingMessage: widget.message.id == null,
                        messagePacketId: widget.message.packetId,
                        onPressed: () async {
                          await _fileRepo.getFile(file.uuid, file.name);
                          setState(() {});
                        },
                        background: widget.backgroundColor,
                        foreground: widget.foregroundColor,
                      );
                    }
                  },
                );
              } else {
                return LoadFileStatus(
                  fileId: file.uuid,
                  isPendingMessage: widget.message.id == null,
                  fileName: file.name,
                  messagePacketId: widget.message.packetId,
                  onPressed: () async {
                    await _fileRepo.getFile(file.uuid, file.name);
                    setState(() {});
                  },
                  background: widget.backgroundColor,
                  foreground: widget.foregroundColor,
                );
              }
            },
          );
        }
      },
    );
  }

  Widget showExitFile(File file, String filePath) {
    return file.type.contains("audio")
        ? PlayAudioStatus(
            fileId: file.uuid,
            filePath: filePath,
            fileName: file.name,
            backgroundColor: widget.backgroundColor,
            foregroundColor: widget.foregroundColor,
          )
        : OpenFileStatus(
            filePath: filePath,
            file: file,
            backgroundColor: widget.backgroundColor,
            foregroundColor: widget.foregroundColor,
          );
  }
}
