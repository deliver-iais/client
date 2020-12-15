import 'package:audioplayers/audioplayers.dart';
import 'package:deliver_flutter/repository/fileRepo.dart';
import 'package:deliver_flutter/services/audio_player_service.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart' as filePb;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'dart:io';

class PlayAudioStatus extends StatefulWidget {
  final filePb.File file;
  //final int dbId;
  const PlayAudioStatus({Key key, this.file}) : super(key: key);

  @override
  _PlayAudioStatusState createState() => _PlayAudioStatusState();
}

class _PlayAudioStatusState extends State<PlayAudioStatus> {
  AudioPlayerService audioPlayerService = GetIt.I.get<AudioPlayerService>();
  var fileRepo = GetIt.I.get<FileRepo>();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<File>(
        future: fileRepo.getFileIfExist(widget.file.uuid, widget.file.name),
        builder: (context, audio) {
          return Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: ExtraTheme.of(context).text,
            ),
            child: StreamBuilder<AudioPlayerState>(
                stream: audioPlayerService.audioPlayerState(widget.file.uuid),
                builder: (context, snapshot) {
                  if (snapshot.data == AudioPlayerState.PLAYING || audioPlayerService.CURRENT_AUDIO_ID.contains(widget.file.uuid)) {
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
                          audioPlayerService.onPause(widget.file.uuid);
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
                              widget.file.uuid,
                              widget.file.name,
                            );
                          });
                        });
                  }
                }),
          );
        });
  }
}
