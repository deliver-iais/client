import 'dart:io';

import 'package:deliver_flutter/repository/fileRepo.dart';
import 'package:deliver_flutter/services/video_player_service.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart' as file;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:video_player/video_player.dart';

class VideoUi extends StatefulWidget {
  final file.File video;

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
    var fileRepo = GetIt.I.get<FileRepo>();

    return FutureBuilder<File>(
      future: fileRepo.getFile(widget.video.uuid, widget.video.name),
      builder: (context, snapshot1) {
        if (snapshot1.hasData) {
          return FutureBuilder(
              future: videoPlayerService
                  .videoControllerInitialization(snapshot1.data),
              builder: (context, snapshot2) {
                if (snapshot2.connectionState == ConnectionState.active) {
                  return VideoPlayer(videoPlayerService.videoPlayerController);
                } else {
                  return CircularProgressIndicator();
                }
              });
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }
}
