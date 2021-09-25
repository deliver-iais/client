import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/services/audio_service.dart';
import 'package:deliver/theme/extra_theme.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'dart:io';

class PlayAudioStatus extends StatefulWidget {
  final String fileId;
  final String fileName;

  const PlayAudioStatus({Key key, this.fileId, this.fileName})
      : super(key: key);

  @override
  _PlayAudioStatusState createState() => _PlayAudioStatusState();
}

class _PlayAudioStatusState extends State<PlayAudioStatus> {
  AudioService audioPlayerService = GetIt.I.get<AudioService>();
  var fileRepo = GetIt.I.get<FileRepo>();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
        future: fileRepo.getFileIfExist(widget.fileId, widget.fileName),
        builder: (context, audio) {
          return Padding(
            padding: EdgeInsets.only(left: 2),
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
                                uuid.data.toString().contains(widget.fileId))
                              return IconButton(
                                padding: EdgeInsets.all(0),
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
                            else
                              return buildPlay(context, audio.data);
                          });
                    } else {
                      return buildPlay(context, audio.data);
                    }
                  }),
            ),
          );
        });
  }

  IconButton buildPlay(BuildContext context, String  audioPath) {
    return IconButton(
        padding: EdgeInsets.all(0),
        alignment: Alignment.center,
        icon: Icon(
          Icons.play_arrow,
          color: ExtraTheme.of(context).fileMessageDetails,
          size: 40,
        ),
        onPressed: () {
          audioPlayerService.play(
            audioPath,
            widget.fileId,
            widget.fileName,
          );
        });
  }
}
