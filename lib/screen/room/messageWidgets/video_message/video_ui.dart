import 'dart:async';
import 'dart:io';

import 'package:deliver/services/video_player_service.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/theme/extra_theme.dart';

import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
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
  BehaviorSubject<double> _currentPositionSubject;

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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            if (isDesktop()) {
              OpenFile.open(widget.video.path);
            } else {
              _showVideoDialog();
            }
          },
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: 100,
            child: FittedBox(
              fit: BoxFit.fitWidth,
              child: Center(
                child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height / 2,
                    child: VideoPlayer(
                        videoPlayerService.thumbnailVideoPlayerController)),
              ),
            ),
          ),
        ),
        Center(
          child: IconButton(
            icon: Icon(Icons.play_circle_fill),
            iconSize: 40,
            color: Colors.cyanAccent,
            onPressed: () {
              if (isDesktop()) {
                OpenFile.open(widget.video.path);
              } else {
                _showVideoDialog();
              }
            },
          ),
        )
      ],
    );
  }

  _showVideoDialog() {

    BehaviorSubject<bool> _isPlaySubject = BehaviorSubject.seeded(true);
    BehaviorSubject<bool> _showSliderSubject = BehaviorSubject.seeded(true);
    videoPlayerService.videoPlayerController.play();
    showDialog(
        context: context,
        builder: (c) {
          return  AlertDialog(
            contentPadding: EdgeInsets.only(top: 0, bottom: 0),
            content: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: ExtraTheme.of(context).sentMessageBox),
                height: 350,
                width: 400,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(5, 20, 5, 20),
                  child: Stack(
                    children: [
                      GestureDetector(
                          onTap: () {
                            _showSliderSubject.add(true);
                          },
                          child: VideoPlayer(
                              videoPlayerService.videoPlayerController)),
                      StreamBuilder<bool>(
                          stream: _showSliderSubject.stream,
                          builder: (c, s) {
                            if (s.hasData && s.data)
                              return Positioned(
                                left: 0.0,
                                bottom: 25,
                                right: 0.0,
                                child: StreamBuilder<double>(
                                  stream: _currentPositionSubject.stream,
                                  builder: (c, s) {
                                    if (s.hasData)
                                      return Slider(
                                          value: s.data,
                                          min: 0.0,
                                          max: widget.duration,
                                          onChanged: (double value) {
                                            videoPlayerService
                                                .videoPlayerController
                                                .seekTo(Duration(
                                                    seconds: value.toInt()));
                                          });
                                    else
                                      return Container();
                                  },
                                ),
                              );
                            else
                              return SizedBox.shrink();
                          }),
                      Center(
                          child: StreamBuilder<bool>(
                        stream: _isPlaySubject.stream,
                        builder: (c, s) {
                          if (s.hasData) {
                            return Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                //  color: Colors.black.withOpacity(0.5),
                              ),
                              child: s.data
                                  ? IconButton(
                                      icon: Icon(
                                        Icons.pause_circle_filled,
                                        color: Colors.cyanAccent,
                                        size: 40,
                                      ),
                                      onPressed: () {
                                        _isPlaySubject.add(false);
                                        videoPlayerService.videoPlayerController
                                            .pause();
                                      })
                                  : IconButton(
                                      icon: Icon(
                                        Icons.play_circle_fill,
                                        size: 40,
                                        color: Colors.cyanAccent,
                                      ),
                                      onPressed: () {
                                        videoPlayerService.videoPlayerController
                                            .play();
                                        _isPlaySubject.add(true);
                                        Timer(
                                            Duration(seconds: 1),
                                            () =>
                                                _showSliderSubject.add(false));
                                      }),
                            );
                          } else {
                            return Container();
                          }
                        },
                      )),
                    ],
                  ),
                )),
          );
        });
  }
}
