import 'dart:async';
import 'dart:io';

import 'package:deliver/services/vlc_video_progress_indicator.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart' as pb;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:rxdart/rxdart.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatefulWidget {
  final double duration;
  final File videoFile;
  final pb.File video;

  const VideoPlayerWidget(
      {Key? key,
      required this.duration,
      required this.videoFile,
      required this.video})
      : super(key: key);

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  final BehaviorSubject<bool> _isPlaySubject = BehaviorSubject.seeded(true);

  final BehaviorSubject<bool> _showIconPlayer = BehaviorSubject.seeded(true);

  late VideoPlayerController _controller;

  @override
  void initState() {
    _init();
    Timer(const Duration(seconds: 2), () {
      _showIconPlayer.add(false);
    });
    super.initState();
  }

  _init() async {
    _controller = VideoPlayerController.file(widget.videoFile);
    await _controller.initialize();
    _controller.play();
    setState(() {});
  }

  @override
  void dispose() {
    //  _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: GestureDetector(
        onTap: () => _showIconPlayer.add(true),
        child: Container(
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Stack(
                children: [
                  Center(
                    child: _controller.value.isInitialized
                        ? AspectRatio(
                            aspectRatio: _controller.value.aspectRatio,
                            child: VideoPlayer(_controller))
                        : CircularPercentIndicator(
                            radius: 10,
                          ),
                  ),
                  Positioned(
                    bottom: 40,
                    left: 2,
                    right: 2,
                    child: VlcVideoProgressIndicator(
                      videoPlayerController: _controller,
                      color: Colors.blue,
                      duration: widget.video.duration,
                    ),
                  ),
                  StreamBuilder<bool>(
                      stream: _showIconPlayer.stream,
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data!) {
                          return Center(
                            child: StreamBuilder<bool>(
                              stream: _isPlaySubject.stream,
                              builder: (c, s) {
                                if (s.hasData) {
                                  return Container(
                                    width: 40,
                                    height: 40,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      //  color: Colors.black.withOpacity(0.5),
                                    ),
                                    child: s.data!
                                        ? IconButton(
                                            icon: const Icon(
                                              Icons.pause_circle_filled,
                                              color: Colors.blue,
                                              size: 50,
                                            ),
                                            onPressed: () {
                                              _isPlaySubject.add(false);
                                              _controller.pause();
                                              _showIconPlayer.add(true);
                                            })
                                        : IconButton(
                                            icon: const Icon(
                                              Icons.play_circle_fill,
                                              size: 50,
                                              color: Colors.blue,
                                            ),
                                            onPressed: () {
                                              _controller.play();
                                              _isPlaySubject.add(true);
                                              Timer(const Duration(seconds: 1),
                                                  () {
                                                _showIconPlayer.add(false);
                                              });
                                            }),
                                  );
                                } else {
                                  return Container();
                                }
                              },
                            ),
                          );
                        } else {
                          return const SizedBox.shrink();
                        }
                      }),
                ],
              ),
            )),
      ),
    );
  }
}
