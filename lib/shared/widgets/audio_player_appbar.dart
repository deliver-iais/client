import 'package:we/services/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:marquee/marquee.dart';

class AudioPlayerAppBar extends StatelessWidget {
  final audioPlayerService = GetIt.I.get<AudioService>();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
        stream: audioPlayerService.audioCenterIsOn,
        builder: (c, s) {
          if (s.hasData && s.data) {
            return Container(
              height: 45,
              decoration: BoxDecoration(
                color: Theme.of(context).appBarTheme.backgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).dividerColor,
                    blurRadius: 2,
                    offset: Offset(1, 1), // Shadow position
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  StreamBuilder<AudioPlayerState>(
                      stream: audioPlayerService.audioCurrentState(),
                      builder: (c, cs) {
                        if (cs.hasData && cs.data == AudioPlayerState.PLAYING) {
                          return IconButton(
                              onPressed: () {
                                audioPlayerService.pause();
                              },
                              icon: Icon(Icons.pause));
                        } else
                          return IconButton(
                              onPressed: () async {
                                audioPlayerService.resume();
                              },
                              icon: Icon(Icons.play_arrow));
                      }),
                  Expanded(
                    child: Center(
                      child: Container(
                        height: 20,
                        child: LayoutBuilder(
                            builder: (BuildContext context,
                                    BoxConstraints constraints) =>
                                RepaintBoundary(
                                  child: audioPlayerService.audioName.length >
                                          (constraints.maxWidth / 10)
                                      ? Marquee(
                                          text: audioPlayerService.audioName,
                                          style: TextStyle(fontSize: 16),
                                          scrollAxis: Axis.horizontal,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          blankSpace: constraints.maxWidth / 2,
                                          velocity: 100.0,
                                          pauseAfterRound: Duration(seconds: 1),
                                          accelerationDuration:
                                              Duration(seconds: 1),
                                          // accelerationCurve: Curves.linear,
                                          decelerationDuration:
                                              Duration(milliseconds: 500),
                                          // decelerationCurve: Curves.easeOut,
                                        )
                                      : Container(
                                          width: double.infinity,
                                          child: Text(
                                              audioPlayerService.audioName,
                                              maxLines: 1,
                                              overflow: TextOverflow.fade,
                                              softWrap: false,
                                              style: TextStyle(fontSize: 16)),
                                        ),
                                )),
                      ),
                    ),
                  ),
                  IconButton(
                      onPressed: () {
                        audioPlayerService.close();
                      },
                      icon: Icon(Icons.close))
                ],
              ),
            );
          } else {
            return SizedBox.shrink();
          }
        });
  }
}
