import 'dart:io';

import 'package:deliver_flutter/services/video_player_service.dart';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:video_player/video_player.dart';

class VideoPlayingDetails extends StatefulWidget {
  final File video;

  const VideoPlayingDetails({Key key, this.video}) : super(key: key);

  @override
  _VideoPlayingDetailsState createState() => _VideoPlayingDetailsState();
}

class _VideoPlayingDetailsState extends State<VideoPlayingDetails> {
  VideoPlayerService videoPlayerService = GetIt.I.get<VideoPlayerService>();

  @override
  void dispose() {
    videoPlayerService.videoControllerDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: videoPlayerService.videoControllerInitialization(widget.video),
        builder: (context, snapshot2) {
          videoPlayerService.videoPlayerController.play();

          return VideoPlayer(videoPlayerService.videoPlayerController);

        });
  }
}
