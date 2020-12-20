import 'package:audioplayers/audioplayers.dart';
import 'package:deliver_flutter/repository/fileRepo.dart';
import 'package:deliver_flutter/services/audio_player_service.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart' as filePb;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'dart:io';

class PlayAudioStatus extends StatefulWidget {
 // final filePb.File file;
 final String fileId;
 final String fileName;
  //final int dbId;
  const PlayAudioStatus({Key key, this.fileId,this.fileName}) : super(key: key);

  @override
  _PlayAudioStatusState createState() => _PlayAudioStatusState();
}

class _PlayAudioStatusState extends State<PlayAudioStatus> {
  AudioPlayerService audioPlayerService = GetIt.I.get<AudioPlayerService>();
  var fileRepo = GetIt.I.get<FileRepo>();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<File>(
        future: fileRepo.getFileIfExist(widget.fileId, widget.fileName),
        builder: (context, audio) {
          return Padding(
            padding: EdgeInsets.only(left: 2),
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ExtraTheme.of(context).text,
              ),
              child: StreamBuilder<AudioPlayerState>(
                  stream: audioPlayerService.audioPlayerState(widget.fileId),
                  builder: (context, snapshot) {
                    if (snapshot.data == AudioPlayerState.PLAYING || audioPlayerService.CURRENT_AUDIO_ID.contains(widget.fileId)) {
                      return IconButton(
                        padding: EdgeInsets.all(0),
                        alignment: Alignment.center,
                        icon: Icon(
                          Icons.pause,
                          color: Theme.of(context).primaryColor,
                          size: 40,
                        ),
                        onPressed: () {
                          setState(() {
                            audioPlayerService.onPause(widget.fileId);
                          });
                        },
                      );
                    } else {
                      return IconButton(
                          padding: EdgeInsets.all(0),
                          alignment: Alignment.center,
                          icon: Icon(
                            Icons.play_arrow,
                            color: Theme.of(context).primaryColor,
                            size: 40,
                          ),
                          onPressed: () {
                            setState(() {
                              audioPlayerService.onPlay(
                                audio.data.path,
                                widget.fileId,
                                widget.fileName,
                              );
                            });
                          });
                    }
                  }),
            ),
          );
        });
  }
}
