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
  VideoPlayerService videoPlayerService = GetIt.I.get<VideoPlayerService>();
  BehaviorSubject<bool> isPlaySubject = BehaviorSubject.seeded(false);
  double currentPosition = 0.0;

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
        VideoPlayer(videoPlayerService.videoPlayerController),
        // Positioned(child: Icon(Icons.more_vert), top: 5, right: 0),
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
                            currentPosition = (await videoPlayerService
                                    .videoPlayerController.position)
                                .inSeconds
                                .toDouble();
                            if (currentPosition != null &&
                                currentPosition > 0.0) setState(() {});
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
            child: StreamBuilder<Duration>(
              stream:
                  videoPlayerService.videoPlayerController.position.asStream(),
              builder: (c, s) {
                if (s.hasData)
                  return Slider(
                      value: currentPosition,
                      min: 0.0,
                      max: widget.duration,
                      onChanged: (double value) {
                        videoPlayerService.videoPlayerController
                            .seekTo(Duration(seconds: value.toInt()));
                        currentPosition = value;
                        setState(() {});
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
