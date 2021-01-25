import 'dart:io';

import 'package:deliver_flutter/services/video_player_service.dart';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:video_player/video_player.dart';

class VideoUi extends StatefulWidget {
  final File video;

  const VideoUi({Key key, this.video}) : super(key: key);

  @override
  _VideoUiState createState() => _VideoUiState();
}

class _VideoUiState extends State<VideoUi> {
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
          return Stack(
            children: [
              VideoPlayer(videoPlayerService.videoPlayerController),
             Positioned(child: Icon(Icons.more_vert), top: 5, right: 0),
              Center(
                  child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withOpacity(0.5),
                ),
                child: IconButton(
                    icon: Icon(Icons.play_arrow),
                    onPressed: () {
                      videoPlayerService.videoPlayerController.play();
                    }),
              ))
            ],
          );

        });
  }
}
