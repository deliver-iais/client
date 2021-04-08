import 'dart:io';

import 'package:deliver_flutter/screen/app-room/messageWidgets/timeAndSeenStatus.dart';
import 'package:deliver_flutter/services/video_player_service.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';
import 'package:video_player/video_player.dart';

class VideoUi extends StatefulWidget {
  final File video;
  final double duration;
  final bool showSlider;

  VideoUi({Key key, this.video, this.duration, this.showSlider})
      : super(key: key);

  @override
  _VideoUiState createState() => _VideoUiState();
}

class _VideoUiState extends State<VideoUi> {
  VideoPlayerService videoPlayerService = new VideoPlayerService();
  BehaviorSubject<bool> isPlaySubject = BehaviorSubject.seeded(false);
  BehaviorSubject<double> _currentPositionSubject;
  bool isPlaying = false;

  @override
  void dispose() {
    videoPlayerService.videoPlayerController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _currentPositionSubject = BehaviorSubject.seeded(0.0);
    videoPlayerService.videoControllerInitialization(widget.video);
    videoPlayerService.videoPlayerController.addListener(() async {
      _currentPositionSubject.add(
          (await videoPlayerService.videoPlayerController.position)
              .inSeconds
              .toDouble());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: FittedBox(
            fit: BoxFit.fitWidth,
            child: Stack(
              children: [
                Center(
                  child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height / 2,
                      child: VideoPlayer(
                          videoPlayerService.videoPlayerController)),
                ),
                if (isPlaying == true)
                  Positioned(
                    top: 100,
                    left: 0.0,
                    bottom: 0.0,
                    right: 0.0,
                    child: SliderTheme(
                      data: SliderThemeData(
                        thumbColor: ExtraTheme.of(context).active,
                        trackHeight: 2.25,
                        activeTrackColor: ExtraTheme.of(context).active,
                        inactiveTrackColor: ExtraTheme.of(context).text,
                        thumbShape:
                            RoundSliderThumbShape(enabledThumbRadius: 4.5),
                      ),
                      child: StreamBuilder<double>(
                        stream: _currentPositionSubject.stream,
                        builder: (c, s) {
                          if (s.hasData)
                            return Slider(
                                value: s.data,
                                min: 0.0,
                                max: widget.duration,
                                onChanged: (double value) {
                                  videoPlayerService.videoPlayerController
                                      .seekTo(Duration(seconds: value.toInt()));
                                });
                          else
                            return Container();
                        },
                      ),
                    ),
                  ),

              ],
            ),
          ),
        ),
        if (widget.showSlider)
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
                            isPlaySubject.add(false);
                            videoPlayerService.videoPlayerController.pause();
                          })
                      : IconButton(
                          icon: Icon(Icons.play_arrow),
                          onPressed: () async {
                            setState(() {
                              isPlaying = true;
                            });
                            isPlaySubject.add(true);
                            videoPlayerService.videoPlayerController.play();
                          }),
                );
              } else {
                return Container();
              }
            },
          )),
      ],
    );
  }
}
