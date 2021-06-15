import 'package:audioplayers/audioplayers.dart';
import 'package:deliver_flutter/services/audio_player_service.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class AudioBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AudioPlayerService audioPlayerService = GetIt.I.get<AudioPlayerService>();
    return StreamBuilder<AudioPlayerState>(
        stream: audioPlayerService.audioPlayerState(""),
        builder: (context, snapshot) {
          if (snapshot.data == AudioPlayerState.PLAYING ||
              snapshot.data == AudioPlayerState.PAUSED ||
              (audioPlayerService.lastDur != null))
            return Container(
              alignment: Alignment.center,
              height: 35,
              color: Theme.of(context).accentColor,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    snapshot.data == AudioPlayerState.PLAYING
                        ? IconButton(
                            padding: EdgeInsets.all(0),
                            alignment: Alignment.center,
                            icon: Icon(
                              Icons.pause,
                              color: Theme.of(context).primaryColor,
                            ),
                            onPressed: audioPlayerService.onPause(""))
                        : IconButton(
                            padding: EdgeInsets.all(0),
                            alignment: Alignment.center,
                            icon: Icon(
                              Icons.play_arrow,
                              color: Theme.of(context).primaryColor,
                            ),
                            onPressed: () {
                              audioPlayerService.onPlay(
                                audioPlayerService.audioPath,
                                audioPlayerService.audioUuid,
                                audioPlayerService.audioName,
                              );
                            }),
                    Container(
                      width: 200,
                      child: Text(
                        audioPlayerService.description +
                            '\t_\t' +
                            audioPlayerService.audioName,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                        softWrap: false,
                        maxLines: 1,
                      ),
                    ),
                    Spacer(),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: ExtraTheme.of(context).centerPageDetails,
                        size: 20,
                      ),
                      onPressed: audioPlayerService.onStop(""),
                    ),
                  ],
                ),
              ),
            );
          else
            return Container();
        });
  }
}
