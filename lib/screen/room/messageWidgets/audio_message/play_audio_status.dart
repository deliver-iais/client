import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/services/audio_service.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/theme/extra_theme.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'package:open_file/open_file.dart';

class PlayAudioStatus extends StatefulWidget {
  final String fileId;
  final String fileName;

  const PlayAudioStatus(
      {Key? key, required this.fileId, required this.fileName})
      : super(key: key);

  @override
  _PlayAudioStatusState createState() => _PlayAudioStatusState();
}

class _PlayAudioStatusState extends State<PlayAudioStatus> {
  AudioService audioPlayerService = GetIt.I.get<AudioService>();
  var fileRepo = GetIt.I.get<FileRepo>();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
        future: fileRepo.getFileIfExist(widget.fileId, widget.fileName),
        builder: (context, audio) {
          return Padding(
            padding: const EdgeInsets.only(left: 2),
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ExtraTheme.of(context).circularFileStatus,
              ),
              child: StreamBuilder<AudioPlayerState>(
                  stream: audioPlayerService.audioCurrentState(),
                  builder: (context, snapshot) {
                    if (snapshot.data == AudioPlayerState.PLAYING) {
                      return StreamBuilder(
                          stream: audioPlayerService.audioUuid,
                          builder: (context, uuid) {
                            if (uuid.hasData &&
                                uuid.data.toString().isNotEmpty &&
                                uuid.data.toString().contains(widget.fileId)) {
                              return IconButton(
                                padding: const EdgeInsets.all(0),
                                alignment: Alignment.center,
                                icon: Icon(
                                  Icons.pause,
                                  color:
                                      ExtraTheme.of(context).fileMessageDetails,
                                  size: 40,
                                ),
                                onPressed: () {
                                  audioPlayerService.pause();
                                },
                              );
                            } else {
                              return buildPlay(context, audio);
                            }
                          });
                    } else {
                      return buildPlay(context, audio);
                    }
                  }),
            ),
          );
        });
  }

  IconButton buildPlay(BuildContext context, AsyncSnapshot<String?> audio) {
    return IconButton(
        padding: const EdgeInsets.all(0),
        alignment: Alignment.center,
        icon: Icon(
          Icons.play_arrow,
          color: ExtraTheme.of(context).fileMessageDetails,
          size: 40,
        ),
        onPressed: () {
          if (isAndroid() || isIOS()) {
            audioPlayerService.play(
              audio.data!,
              widget.fileId,
              widget.fileName,
            );
          } else {
            OpenFile.open(audio.data!);
          }
        });
  }
}
