import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/services/audio_service.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'package:open_file/open_file.dart';

class PlayAudioStatus extends StatefulWidget {
  final String fileId;
  final String fileName;
  final String filePath;
  final Color backgroundColor;
  final Color foregroundColor;

  const PlayAudioStatus(
      {Key? key,
      required this.fileId,
      required this.fileName,
      required this.filePath,
      required this.backgroundColor,
      required this.foregroundColor})
      : super(key: key);

  @override
  _PlayAudioStatusState createState() => _PlayAudioStatusState();
}

class _PlayAudioStatusState extends State<PlayAudioStatus> {
  AudioService audioPlayerService = GetIt.I.get<AudioService>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 2),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.backgroundColor,
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
                            color: widget.foregroundColor,
                            size: 40,
                          ),
                          onPressed: () {
                            audioPlayerService.pause();
                          },
                        );
                      } else {
                        return buildPlay(context, widget.filePath);
                      }
                    });
              } else {
                return buildPlay(context, widget.filePath);
              }
            }),
      ),
    );
  }

  IconButton buildPlay(BuildContext context, String audioPath) {
    return IconButton(
        padding: EdgeInsets.zero,
        alignment: Alignment.center,
        icon: Icon(
          Icons.play_arrow,
          color: widget.foregroundColor,
          size: 42,
        ),
        onPressed: () {
          if (isAndroid() || isIOS()) {
            audioPlayerService.play(
              audioPath,
              widget.fileId,
              widget.fileName,
            );
          } else {
            OpenFile.open(audioPath);
          }
        });
  }
}
