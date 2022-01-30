import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/services/audio_service.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/theme/color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'package:open_file/open_file.dart';

class PlayAudioStatus extends StatefulWidget {
  final String fileId;
  final String fileName;
  final bool isSender;

  const PlayAudioStatus(
      {Key? key,
      required this.fileId,
      required this.fileName,
      this.isSender = false})
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
                color: lowlight(widget.isSender, context),
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
                                  color: highlight(widget.isSender, context),
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
        padding: EdgeInsets.zero,
        alignment: Alignment.center,
        icon: Icon(
          Icons.play_arrow,
          color: highlight(widget.isSender, context),
          size: 42,
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
