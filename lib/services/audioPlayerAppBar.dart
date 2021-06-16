import 'package:audioplayer/audioplayer.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'audio_player_service.dart';

class AudioPlayerAppBar extends StatelessWidget {
  AudioPlayerService audioPlayerService = GetIt.I.get<AudioPlayerService>();

  @override
  Widget build(BuildContext context) {
    return Container(
      color:  Theme.of(context).accentColor.withAlpha(50),
      child: StreamBuilder(
          stream: audioPlayerService.isOn,
          builder: (c, s) {
            if (s.hasData && s.data) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  StreamBuilder<AudioPlayerState>(
                      stream: audioPlayerService.currentState.stream,
                      builder: (c, cs) {
                        if (cs.hasData && cs.data == AudioPlayerState.PLAYING) {
                          return IconButton(
                              onPressed: () {
                                audioPlayerService
                                    .onPause(audioPlayerService.audioUuid);
                              },
                              icon: Icon(Icons.pause));
                        } else
                          return IconButton(
                              onPressed: () {
                                audioPlayerService.onPlay(
                                    audioPlayerService.audioPath,
                                    audioPlayerService.audioUuid,
                                    audioPlayerService.audioName);
                              },
                              icon: Icon(Icons.play_arrow));
                      }),
                  Container(
                    width: 150,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Text(
                        audioPlayerService.audioName,
                        overflow: TextOverflow.clip,
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                        softWrap: false,
                        maxLines: 1,
                      ),
                    ),
                  ),

                  IconButton(
                      onPressed: () {
                        audioPlayerService.onStop(audioPlayerService.audioUuid);
                      },
                      icon: Icon(Icons.close))
                ],
              );
            } else
              return SizedBox.shrink();
          }),
    );
  }
}
