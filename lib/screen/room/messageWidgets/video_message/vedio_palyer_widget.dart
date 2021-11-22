import 'dart:async';
import 'dart:io';

import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart' as pb;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatefulWidget {
  final double duration;
  final File videoFile;
  final pb.File video;
  final VideoPlayerController videoPlayerController;

  VideoPlayerWidget(
      {required this.duration,
      required this.videoFile,
      required this.video,
      required this.videoPlayerController});

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  BehaviorSubject<bool> _isPlaySubject = BehaviorSubject.seeded(true);

  BehaviorSubject<bool> _showIconPlayer = BehaviorSubject.seeded(true);
  late double _h;

  @override
  void initState() {
    widget.videoPlayerController.play();
    Timer(Duration(seconds: 2), () {
      _showIconPlayer.add(false);
    });
    super.initState();
  }

  //
  @override
  void dispose() {
    widget.videoPlayerController.pause();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _h = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(),
      body: Container(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
            child: Stack(
              children: [
                Center(
                  child: AspectRatio(
                    aspectRatio: widget.video.width / widget.video.height,
                    child: VideoPlayer(widget.videoPlayerController),
                  ),
                ),
                VideoProgressIndicator(
                  widget.videoPlayerController,
                  allowScrubbing: true,
                  padding: EdgeInsets.only(
                      bottom: 50, top: _h - _h / 5, left: 5, right: 5),
                ),
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
                          child: s.data!
                              ? IconButton(
                                  icon: Icon(
                                    Icons.pause_circle_filled,
                                    color: Colors.blue,
                                    size: 50,
                                  ),
                                  onPressed: () {
                                    _isPlaySubject.add(false);
                                    widget.videoPlayerController.pause();
                                    _showIconPlayer.add(true);
                                  })
                              : IconButton(
                                  icon: Icon(
                                    Icons.play_circle_fill,
                                    size: 50,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () {
                                    widget.videoPlayerController.play();
                                    _isPlaySubject.add(true);
                                    Timer(Duration(seconds: 1), () {
                                      _showIconPlayer.add(false);
                                    });
                                  }),
                        );
                      } else {
                        return Container();
                      }
                    },
                  ),
                ),
              ],
            ),
          )),
    );
  }
}
