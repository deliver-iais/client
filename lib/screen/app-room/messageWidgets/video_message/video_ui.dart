import 'dart:io';

import 'package:deliver_flutter/services/video_player_service.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';
import 'package:video_player/video_player.dart';

class VideoUi extends StatefulWidget {
  final File video;
  final double duration;

  const VideoUi({Key key, this.video, this.duration}) : super(key: key);

  @override
  _VideoUiState createState() => _VideoUiState();
}

class _VideoUiState extends State<VideoUi> {
  VideoPlayerService videoPlayerService = new  VideoPlayerService();
  BehaviorSubject<bool> isPlaySubject = BehaviorSubject.seeded(false);
  double currentPosition = 0.0;
  BehaviorSubject<double> _currentPositionSubject = BehaviorSubject.seeded(0.0);

  @override
  void dispose() {
    videoPlayerService.videoPlayerController.addListener(() {});
    videoPlayerService.videoPlayerController.pause();
    super.dispose();
  }

  @override
  void initState() {
    videoPlayerService.videoControllerInitialization(widget.video);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width:   MediaQuery.of(context).size.width,
          height:  MediaQuery.of(context).size.height,
          child: FittedBox(
              fit: BoxFit.fitWidth,
              child:
              Center(
                child: SizedBox(
                    width:   MediaQuery.of(context).size.width,
                    height:  MediaQuery.of(context).size.height/2,
                    child: VideoPlayer(videoPlayerService.videoPlayerController)),
              ),
    ),
        ),
        Center(
            child: StreamBuilder<bool>(
          stream: isPlaySubject.stream,
          builder: (c, s) {
            if (s.hasData) {
              return Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withOpacity(0.5),
                ),
                child: s.data
                    ? IconButton(
                        icon: Icon(Icons.pause),
                        onPressed: () {
                          videoPlayerService.videoPlayerController.pause();
                          isPlaySubject.add(false);
                          videoPlayerService.videoPlayerController
                              .addListener(() {});
                        })
                    : IconButton(
                        icon: Icon(Icons.play_arrow),
                        onPressed: () {
                          videoPlayerService.videoPlayerController.play();
                          videoPlayerService.videoPlayerController
                              .addListener(() async {
                            _currentPositionSubject.add((await videoPlayerService
                                    .videoPlayerController.position)
                                .inSeconds
                                .toDouble());
                          });
                          isPlaySubject.add(true);
                        }),
              );
            } else {
              return Container();
            }
          },
        )),
        Column(mainAxisAlignment: MainAxisAlignment.end, children: [
          SliderTheme(
            data: SliderThemeData(
              thumbColor: ExtraTheme.of(context).active,
              trackHeight: 2.25,
              activeTrackColor: ExtraTheme.of(context).active,
              inactiveTrackColor: ExtraTheme.of(context).text,
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 4.5),
            ),
            child: StreamBuilder<double>(
              stream:
                  _currentPositionSubject.stream,
              builder: (c, s) {
                if (s.hasData)
                  return Slider(
                      value: s.data,
                      min: 0.0,
                      max: widget.duration,
                      onChanged: (double value) {
                        videoPlayerService.videoPlayerController
                            .seekTo(Duration(seconds: value.toInt()));
                        currentPosition = value;
                      });
                else
                  return Container();
              },
            ),
          ),
        ]),
      ],
    );
  }
}
