import 'package:audioplayer/audioplayer.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:marquee/marquee.dart';

import 'audio_player_service.dart';

class AudioPlayerAppBar extends StatelessWidget {
  final audioPlayerService = GetIt.I.get<AudioPlayerService>();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).accentColor.withAlpha(50),
      child: StreamBuilder(
          stream: audioPlayerService.isOn,
          builder: (c, s) {
            if (s.hasData && s.data) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
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
                  Expanded(
                    child: Center(
                      child: Container(
                        height: 20,
                        child: RepaintBoundary(
                          child: Marquee(
                            text: audioPlayerService.audioName,
                            style: TextStyle(fontSize: 17),
                            scrollAxis: Axis.horizontal,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            blankSpace: 20.0,
                            velocity: 100.0,
                            pauseAfterRound: Duration(seconds: 1),
                            accelerationDuration: Duration(seconds: 1),
                            accelerationCurve: Curves.linear,
                            decelerationDuration: Duration(milliseconds: 500),
                            decelerationCurve: Curves.easeOut,
                          ),
                        ),
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
